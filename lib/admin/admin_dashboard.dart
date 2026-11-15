import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const bg = Color(0xFFF7F9F7);
  static const panel = Colors.white;
  static const lime = Color(0xFF39C957);
  static const orange = Color(0xFFFF992D);
  static const muted = Color(0xFF647568);

  bool loading = true;
  String? error;
  int users = 0;
  int detections = 0;
  int today = 0;
  int diseases = 0;
  int pests = 0;
  int unclassified = 0;
  final Map<DateTime, int> daily = {};
  final Map<String, int> classes = {};
  int selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _classify(Map<String, dynamic> data) {
    dynamic label;
    for (final key in [
      'detectedClass', 'className', 'class', 'label', 'pestName',
      'diseaseName', 'result', 'prediction', 'detectedPest', 'pest', 'name'
    ]) {
      if (data[key] is String && (data[key] as String).trim().isNotEmpty) {
        label = data[key];
        break;
      }
    }
    if (label == null && data['detections'] is List &&
        (data['detections'] as List).isNotEmpty) {
      final first = (data['detections'] as List).first;
      if (first is String) label = first;
      if (first is Map) label = first['className'] ?? first['label'] ?? first['class'];
    }
    final text = (label ?? '').toString().toLowerCase();
    if (text.contains('mealy')) return 'Mealybug';
    if (text.contains('mirid')) return 'Mirid';
    if (text.contains('borer')) return 'Pod Borer';
    if (text.contains('phytophthora') || text.contains('black pod')) return 'Phytophthora';
    if (text.contains('unclass') || text.contains('healthy') || text.contains('unknown') || text.contains('no pest')) return 'Unclassified';
    return text.isEmpty ? 'Unspecified' : label.toString();
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

  Future<void> _load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').get(),
        FirebaseFirestore.instance.collection('pc').get(),
      ]);
      final counts = <String, int>{};
      final trend = <DateTime, int>{};
      final current = _dateOnly(DateTime.now());
      var todayCount = 0;
      var totalDetections = 0;
      var diseaseCount = 0;
      var pestCount = 0;
      var otherCount = 0;
      for (final doc in results[1].docs) {
        final data = doc.data();
        final labels = _allLabels(data);
        totalDetections += labels.length;
        for (final label in labels) {
          counts[label] = (counts[label] ?? 0) + 1;
          if (label == 'Phytophthora') {
            diseaseCount++;
          } else if (label == 'Mealybug' || label == 'Mirid' || label == 'Pod Borer') {
            pestCount++;
          } else {
            otherCount++;
          }
        }
        final date = _parseDate(data['timestamp']) ??
            _parseDate(data['createdAt']) ?? _parseDate(data['date']);
        if (date != null) {
          final day = _dateOnly(date);
          trend[day] = (trend[day] ?? 0) + labels.length;
          if (day == current) todayCount += labels.length;
        }
      }
      if (!mounted) return;
      setState(() {
        users = results[0].docs.length;
        detections = totalDetections;
        today = todayCount;
        diseases = diseaseCount;
        pests = pestCount;
        unclassified = otherCount;
        daily..clear()..addAll(trend);
        classes..clear()..addAll(counts);
        loading = false;
      });
    } catch (e) {
      debugPrint('Dashboard: $e');
      if (mounted) setState(() {
        loading = false;
        error = 'Could not load dashboard. Check your connection and Firestore access.';
      });
    }
  }

  Widget _metric(String label, int count, IconData icon, {String? detail}) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 31, height: 31,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 17),
          ),
          const Spacer(),
          const Icon(Icons.arrow_outward_rounded, color: Color(0xFF0D4B15), size: 16),
        ]),
        const SizedBox(height: 9),
        Text(NumberFormat.decimalPattern().format(count),
            style: const TextStyle(color: Colors.black, fontSize: 25,
                fontWeight: FontWeight.w900, height: 1.05)),
        const SizedBox(height: 3),
        Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontSize: 12,
                fontWeight: FontWeight.w700)),
        if (detail != null) ...[
          const SizedBox(height: 2),
          Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF19561F), fontSize: 10)),
        ],
      ]),
    );
  }

  Widget _trend() {
    final end = _dateOnly(DateTime.now());
    final dates = List.generate(selectedDays,
        (i) => end.subtract(Duration(days: selectedDays - 1 - i)));
    final counts = dates.map((d) => daily[d] ?? 0).toList();
    final maxCount = counts.fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = (maxCount + 2).toDouble().clamp(4.0, double.infinity);
    return SizedBox(
      height: 190,
      child: BarChart(BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFE8EEE9), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= dates.length || i != value ||
                  (selectedDays == 30 && i % 5 != 0)) return const SizedBox.shrink();
              return Padding(padding: const EdgeInsets.only(top: 7),
                  child: Text(DateFormat(selectedDays == 30 ? 'd' : 'E').format(dates[i]),
                      style: const TextStyle(color: muted, fontSize: 10)));
            },
          )),
        ),
        barGroups: [
          for (var i = 0; i < counts.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: counts[i].toDouble(),
                  color: i == counts.length - 1 ? orange : lime,
                  width: selectedDays == 30 ? 5 : 15,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
            ]),
        ],
      )),
    );
  }

  Widget _breakdown() {
    final entries = classes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) return const Text('No detections yet', style: TextStyle(color: muted));
    const colors = [lime, orange, Color(0xFF87C779), Color(0xFFFFC26E), Color(0xFF789386)];
    return Column(children: [
      for (var i = 0; i < entries.length && i < 6; i++) ...[
        Row(children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
          const SizedBox(width: 9),
          Expanded(child: Text(entries[i].key,
              style: const TextStyle(color: Color(0xFF18271D), fontSize: 12))),
          Text('${entries[i].value}',
              style: const TextStyle(color: Color(0xFF18271D), fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
          minHeight: 5,
          value: detections == 0 ? 0 : entries[i].value / detections,
          color: colors[i % colors.length],
          backgroundColor: const Color(0xFFE8EEE9),
        )),
        const SizedBox(height: 12),
      ],
    ]);
  }

  Widget _section({required String title, Widget? trailing, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE0E7E1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF18271D),
              fontSize: 15, fontWeight: FontWeight.w800))),
          if (trailing != null) trailing,
        ]),
        const SizedBox(height: 17),
        child,
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const ColoredBox(color: bg,
        child: Center(child: CircularProgressIndicator(color: lime)));
    if (error != null) return ColoredBox(color: bg,
        child: Center(child: Padding(padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF18271D))),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('Retry',
                  style: TextStyle(color: lime))),
            ]))));

    return ColoredBox(
      color: bg,
      child: RefreshIndicator(
        color: lime,
        onRefresh: _load,
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final padding = width < 390 ? 12.0 : 20.0;
          final gap = width < 390 ? 10.0 : 14.0;
          final tileWidth = (width - padding * 2 - gap) / 2;
          return ListView(padding: EdgeInsets.all(padding), children: [
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard', style: TextStyle(color: Color(0xFF18271D),
                      fontSize: 24, fontWeight: FontWeight.w900)),
                  SizedBox(height: 3),
                  Text('Overview', style: TextStyle(color: muted, fontSize: 12)),
                ],
              )),
              IconButton(onPressed: _load, tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF18271D))),
              const CircleAvatar(radius: 17, backgroundColor: Color(0xFFE3F4E8),
                  child: Icon(Icons.person_outline, color: orange, size: 19)),
            ]),
            const SizedBox(height: 19),
            Row(children: [
              const Text('Overview', style: TextStyle(color: Color(0xFF18271D),
                  fontSize: 16, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(20)),
                child: const Text('All time', style: TextStyle(color: muted, fontSize: 11))),
            ]),
            const SizedBox(height: 12),
            // Intrinsic card height prevents RenderFlex overflow on narrow phones.
            Wrap(spacing: gap, runSpacing: gap, children: [
              SizedBox(width: tileWidth, height: 124,
                  child: _metric('Total Users', users, Icons.people_alt_outlined)),
              SizedBox(width: tileWidth, height: 124,
                  child: _metric('Total Detections', detections, Icons.radar_outlined)),
              SizedBox(width: tileWidth, height: 124,
                  child: _metric('Detections Today', today, Icons.today_outlined)),
              SizedBox(width: tileWidth, height: 124,
                  child: _metric('Pest Detections', pests, Icons.bug_report_outlined)),
            ]),
            const SizedBox(height: 20),
            _section(title: 'Detection Activity', trailing: PopupMenuButton<int>(
              initialValue: selectedDays,
              color: Colors.white,
              onSelected: (value) => setState(() => selectedDays = value),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 7, child: Text('Last 7 days', style: TextStyle(color: Color(0xFF18271D)))),
                PopupMenuItem(value: 30, child: Text('Last 30 days', style: TextStyle(color: Color(0xFF18271D)))),
              ],
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${selectedDays}D', style: const TextStyle(color: Color(0xFF18271D), fontSize: 11)),
                  const SizedBox(width: 3),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xFF18271D), size: 15),
                ])),
            ), child: _trend()),
            const SizedBox(height: 14),
            _section(title: 'Detection Breakdown', child: _breakdown()),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _miniSummary('Diseases', diseases, orange)),
              const SizedBox(width: 10),
              Expanded(child: _miniSummary('Other / Unclassified', unclassified, lime)),
            ]),
            const SizedBox(height: 12),
          ]);
        }),
      ),
    );
  }

  Widget _miniSummary(String label, int value, Color color) {
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 6),
        Text('$value', style: TextStyle(color: color, fontSize: 21, fontWeight: FontWeight.w800)),
      ]));
  }
}
