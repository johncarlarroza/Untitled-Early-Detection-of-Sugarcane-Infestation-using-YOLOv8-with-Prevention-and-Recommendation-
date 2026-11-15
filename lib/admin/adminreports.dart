import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});
  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  static const bg = Color(0xFFF7F9F7);
  static const panel = Colors.white;
  static const green = Color(0xFF24B75A);
  static const orange = Color(0xFFFF982F);
  static const muted = Color(0xFF647568);
  static const border = Color(0xFFE0E7E1);
  String period = '30 days';
  DateTimeRange? customRange;
  bool exporting = false;

  DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  DateTime? _recordDate(Map<String, dynamic> data) =>
      _date(data['timestamp']) ?? _date(data['createdAt']) ?? _date(data['date']);

  String _classify(Map<String, dynamic> data) {
    dynamic raw;
    for (final key in ['detectedClass', 'className', 'class', 'label',
      'pestName', 'diseaseName', 'detection', 'result', 'prediction',
      'detectedPest', 'pest', 'name']) {
      if (data[key] is String && (data[key] as String).trim().isNotEmpty) {
        raw = data[key];
        break;
      }
    }
    if (raw == null && data['detections'] is List &&
        (data['detections'] as List).isNotEmpty) {
      final first = (data['detections'] as List).first;
      if (first is String) raw = first;
      if (first is Map) raw = first['className'] ?? first['label'] ?? first['class'];
    }
    final value = (raw ?? '').toString().toLowerCase();
    if (value.contains('mealy')) return 'Mealybug';
    if (value.contains('mirid')) return 'Mirid';
    if (value.contains('borer')) return 'Pod Borer';
    if (value.contains('phytophthora') || value.contains('black pod')) return 'Phytophthora';
    if (value.contains('unclass') || value.contains('healthy') || value.contains('unknown') || value.contains('no pest')) return 'Unclassified';
    return value.trim().isEmpty ? 'Unspecified' : raw.toString().trim();
  }

  List<String> _allLabels(Map<String, dynamic> data) {
    final raw = data['labels'] ?? data['detections'];
    if (raw is List && raw.isNotEmpty) {
      final names = <String>{};
      for (final entry in raw) {
        final value = entry is Map
            ? (entry['className'] ?? entry['label'] ?? entry['class'] ?? '')
            : entry;
        final label = _classify({'label': value.toString()});
        if (label != 'Unclassified' && label != 'Unspecified') names.add(label);
      }
      if (names.isNotEmpty) return names.toList();
    }
    return [_classify(data)];
  }

  bool _inPeriod(DateTime? date) {
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (period == 'All time') return true;
    if (period == 'Custom') {
      if (customRange == null) return false;
      final start = DateTime(customRange!.start.year, customRange!.start.month, customRange!.start.day);
      final end = DateTime(customRange!.end.year, customRange!.end.month, customRange!.end.day);
      return !day.isBefore(start) && !day.isAfter(end);
    }
    final days = period == '7 days' ? 7 : 30;
    return !day.isBefore(today.subtract(Duration(days: days - 1))) && !day.isAfter(today);
  }

  String _category(String label) {
    if (label == 'Phytophthora') return 'Disease';
    if (['Mealybug', 'Mirid', 'Pod Borer'].contains(label)) return 'Pest';
    if (label == 'Unclassified') return 'Unclassified';
    return 'Other / Unverified';
  }

  Widget _card(Widget child, {EdgeInsets padding = const EdgeInsets.all(16)}) =>
      Container(padding: padding, decoration: BoxDecoration(color: panel,
        borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: child);

  Widget _metric(String label, String value, Color accent) =>
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(
        color: accent, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900)),
        ]));

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final chosen = await showDateRangePicker(context: context,
      firstDate: DateTime(2020), lastDate: now,
      initialDateRange: customRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 29)), end: now));
    if (chosen != null && mounted) setState(() { customRange = chosen; period = 'Custom'; });
  }

  Future<void> _export(List<Map<String, dynamic>> records,
      Map<String, int> breakdown, Map<String, int> categories,
      Map<DateTime, int> trend, int activeUsers) async {
    if (exporting) return;
    setState(() => exporting = true);
    try {
      final doc = pw.Document();
      final ordered = trend.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      doc.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32), build: (context) => [
          pw.Text('PESCOA | Detection Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Period: ${period == 'Custom' && customRange != null ? '${DateFormat('MMM d, yyyy').format(customRange!.start)} - ${DateFormat('MMM d, yyyy').format(customRange!.end)}' : period}'),
          pw.Text('Generated: ${DateFormat('MMM d, yyyy h:mm a').format(DateTime.now())}'),
          pw.SizedBox(height: 18),
          pw.Text('Images saved: ${records.length} | Total detections: ${breakdown.values.fold<int>(0, (a, b) => a + b)} | Active users: $activeUsers'),
          pw.SizedBox(height: 16),
          pw.Text('Classification breakdown', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(headers: ['Classification', 'Records'],
            data: (breakdown.entries.toList()..sort((a,b) => b.value.compareTo(a.value)))
              .map((e) => [e.key, '${e.value}']).toList()),
          pw.SizedBox(height: 16),
          pw.Text('Detection types', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(headers: ['Type', 'Records'],
            data: categories.entries.map((e) => [e.key, '${e.value}']).toList()),
          pw.SizedBox(height: 16),
          pw.Text('Daily trend', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.TableHelper.fromTextArray(headers: ['Date', 'Records'],
            data: ordered.map((e) => [DateFormat('MMM d, yyyy').format(e.key), '${e.value}']).toList()),
          pw.SizedBox(height: 12),
          pw.Text('Counts include every detected type in each document in the pc collection. Unclassified and unspecified entries are shown separately. Active users are distinct users with a detection record in the selected period.',
            style: const pw.TextStyle(fontSize: 9)),
        ]));
      final Uint8List bytes = await doc.save();
      await Printing.layoutPdf(onLayout: (_) async => bytes,
        name: 'PESCOA_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not export the report.')));
      debugPrint('PDF export failed: $e');
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: bg,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('pc').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Unable to load reports.',
            style: TextStyle(color: Color(0xFF18271D))));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: green));
          final all = snapshot.data!.docs.map((d) => d.data()).toList();
          final selected = all.where((r) => _inPeriod(_recordDate(r))).toList();
          final breakdown = <String, int>{};
          final categories = <String, int>{};
          final trend = <DateTime, int>{};
          final userIds = <String>{};
          var totalDetections = 0;
          for (final r in selected) {
            final labels = _allLabels(r);
            totalDetections += labels.length;
            for (final label in labels) {
              breakdown[label] = (breakdown[label] ?? 0) + 1;
              final category = _category(label);
              categories[category] = (categories[category] ?? 0) + 1;
            }
            final date = _recordDate(r)!;
            final day = DateTime(date.year, date.month, date.day);
            trend[day] = (trend[day] ?? 0) + labels.length;
            final user = (r['userId'] ?? r['uid'] ?? r['userEmail'] ?? '').toString().trim();
            if (user.isNotEmpty) userIds.add(user);
          }
          final sorted = breakdown.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
          final trendDays = trend.keys.toList()..sort();
          final maxTrend = trend.values.fold<int>(0, (a,b) => a > b ? a : b);
          return LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;
            final pad = compact ? 14.0 : 26.0;
            return ListView(padding: EdgeInsets.all(pad), children: [
              const Text('Reports', style: TextStyle(color: Color(0xFF18271D), fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Detection history and activity', style: TextStyle(color: muted, fontSize: 13)),
              const SizedBox(height: 18),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in ['7 days', '30 days', 'All time'])
                  ChoiceChip(label: Text(p), selected: period == p,
                    selectedColor: green, backgroundColor: panel,
                    labelStyle: TextStyle(color: Color(0xFF18271D)),
                    onSelected: (_) => setState(() => period = p)),
                ActionChip(label: Text(period == 'Custom' && customRange != null
                  ? '${DateFormat('MMM d').format(customRange!.start)} - ${DateFormat('MMM d').format(customRange!.end)}'
                  : 'Custom dates'), onPressed: _pickRange,
                  backgroundColor: period == 'Custom' ? orange : panel,
                  labelStyle: TextStyle(color: Color(0xFF18271D))),
              ]),
              const SizedBox(height: 16),
              GridView.count(crossAxisCount: compact ? 2 : 4, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 9,
                crossAxisSpacing: 9, childAspectRatio: compact ? 1.38 : 1.7,
                children: [
                  _metric('Total Detections', '$totalDetections', green),
                  _metric('Pest Detections', '${categories['Pest'] ?? 0}', orange),
                  _metric('Disease Detections', '${categories['Disease'] ?? 0}', green),
                  _metric('Unclassified', '${categories['Unclassified'] ?? 0}', orange),
                ]),
              const SizedBox(height: 14),
              _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(child: Text('Detection breakdown', style: TextStyle(color: Color(0xFF18271D), fontWeight: FontWeight.bold, fontSize: 16))),
                  Text('$totalDetections detections', style: const TextStyle(color: muted, fontSize: 12)),
                ]),
                const SizedBox(height: 14),
                if (sorted.isEmpty) const Text('No records for this period.', style: TextStyle(color: muted)),
                for (final e in sorted) ...[
                  Row(children: [
                    Expanded(child: Text(e.key, style: const TextStyle(color: Color(0xFF18271D), fontSize: 13), overflow: TextOverflow.ellipsis)),
                    Text('${e.value}', style: const TextStyle(color: green, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(value: selected.isEmpty ? 0 : e.value / totalDetections,
                      minHeight: 7, color: green, backgroundColor: border)),
                  const SizedBox(height: 12),
                ],
              ])),
              const SizedBox(height: 14),
              _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Detection trend', style: TextStyle(color: Color(0xFF18271D), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                if (trendDays.isEmpty) const SizedBox(height: 110, child: Center(child: Text('No dated records.', style: TextStyle(color: muted))))
                else SizedBox(height: 210, child: BarChart(BarChartData(
                  maxY: (maxTrend + 1).toDouble(),
                  gridData: FlGridData(drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => const FlLine(color: border, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        final step = (trendDays.length / 5).ceil().clamp(1, 99999);
                        if (i < 0 || i >= trendDays.length || i % step != 0) return const SizedBox.shrink();
                        return Padding(padding: const EdgeInsets.only(top: 7),
                          child: Text(DateFormat('M/d').format(trendDays[i]), style: const TextStyle(color: muted, fontSize: 10)));
                      }))),
                  barGroups: [for (var i = 0; i < trendDays.length; i++)
                    BarChartGroupData(x: i, barRods: [BarChartRodData(toY: trend[trendDays[i]]!.toDouble(),
                      width: trendDays.length > 25 ? 5 : 13, color: i.isEven ? green : orange,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))])],
                ))),
              ])),
              const SizedBox(height: 14),
              _card(Row(children: [
                const Icon(Icons.people_outline, color: orange),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Active users', style: TextStyle(color: Color(0xFF18271D), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text('${userIds.length} unique users with a detection in this period',
                    style: const TextStyle(color: muted, fontSize: 12)),
                  if (selected.isNotEmpty && userIds.isEmpty)
                    const Text('User IDs are missing from these records.', style: TextStyle(color: orange, fontSize: 11)),
                ])),
              ])),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: exporting ? null : () => _export(selected, breakdown, categories, trend, userIds.length),
                style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15)),
                icon: Icon(exporting ? Icons.hourglass_top : Icons.picture_as_pdf_outlined),
                label: Text(exporting ? 'Preparing PDF...' : 'Export PDF report'))),
              const SizedBox(height: 10),
              const Text('Reports use timestamped records from the Pescoa Application.',
                style: TextStyle(color: muted, fontSize: 11)),
            ]);
          });
        },
      ));
  }
}
