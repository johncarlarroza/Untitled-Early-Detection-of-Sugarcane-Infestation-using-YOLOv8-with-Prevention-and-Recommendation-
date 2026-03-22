import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool loading = true;

  int totalUsers = 0;
  int totalPests = 0;

  Map<String, int> pestsPerDay = {};
  Map<String, int> usersPerDay = {};
  Map<String, int> activeUsersPerDay = {};

  final GlobalKey _pieChartKey = GlobalKey();
  final GlobalKey _pestsBarKey = GlobalKey();
  final GlobalKey _usersLineKey = GlobalKey();
  final GlobalKey _activeUsersBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final pestsSnapshot =
          await FirebaseFirestore.instance.collection('pc').get();

      totalUsers = usersSnapshot.docs.length;
      totalPests = pestsSnapshot.docs.length;

      usersPerDay = _groupByDay(usersSnapshot.docs, 'createdAt');
      pestsPerDay = _groupByDay(pestsSnapshot.docs, 'timestamp');

      final Map<String, Set<String>> tempActive = {};

      for (final doc in pestsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('timestamp') || data['timestamp'] == null)
          continue;

        final timestamp = data['timestamp'];
        if (timestamp is! Timestamp) continue;

        final day = DateFormat('MMM dd').format(timestamp.toDate());
        final username = (data['username'] ?? 'unknown').toString();

        tempActive.putIfAbsent(day, () => <String>{});
        tempActive[day]!.add(username);
      }

      activeUsersPerDay = {
        for (final e in tempActive.entries) e.key: e.value.length
      };

      if (!mounted) return;
      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint('REPORT ERROR: $e');
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  Map<String, int> _groupByDay(
    List<QueryDocumentSnapshot> docs,
    String field,
  ) {
    final Map<String, int> result = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey(field) || data[field] == null) continue;

      final value = data[field];
      if (value is! Timestamp) continue;

      final day = DateFormat('MMM dd').format(value.toDate());
      result[day] = (result[day] ?? 0) + 1;
    }

    return result;
  }

  List<FlSpot> _toSpots(Map<String, int> data) {
    final entries = data.entries.toList();
    return List.generate(
      entries.length,
      (index) => FlSpot(index.toDouble(), entries[index].value.toDouble()),
    );
  }

  double _safeMax(Map<String, int> data) {
    if (data.isEmpty) return 5;
    return (data.values.reduce((a, b) => a > b ? a : b) + 2).toDouble();
  }

  Future<Uint8List?> _captureChart(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture chart error: $e');
      return null;
    }
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Reports & Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This report summarizes user registrations, pest detections, and daily activity trends. It is designed to help administrators monitor growth, identify reporting spikes, and better understand system usage.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget chart,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    if (totalUsers == 0 && totalPests == 0) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('No data available')),
      );
    }

    return RepaintBoundary(
      key: _pieChartKey,
      child: Container(
        color: Colors.white,
        height: 260,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 52,
            sectionsSpace: 4,
            sections: [
              PieChartSectionData(
                value: totalUsers.toDouble(),
                color: Colors.blue,
                radius: 78,
                title: 'Users\n$totalUsers',
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              PieChartSectionData(
                value: totalPests.toDouble(),
                color: Colors.red,
                radius: 78,
                title: 'Pests\n$totalPests',
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart({
    required GlobalKey chartKey,
    required Map<String, int> data,
    required Color color,
  }) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text("No data available")),
      );
    }

    final entries = data.entries.toList();

    return RepaintBoundary(
      key: chartKey,
      child: Container(
        color: Colors.white,
        height: 260,
        child: BarChart(
          BarChartData(
            maxY: _safeMax(data),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.15),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 30,
                  interval: 1,
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 42,
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= entries.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[index].key,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(
              entries.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entries[index].value.toDouble(),
                    width: 18,
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart({
    required GlobalKey chartKey,
    required Map<String, int> data,
    required Color color,
  }) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text("No data available")),
      );
    }

    final entries = data.entries.toList();
    final spots = _toSpots(data);

    return RepaintBoundary(
      key: chartKey,
      child: Container(
        color: Colors.white,
        height: 260,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: _safeMax(data),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.14),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 30,
                  interval: 1,
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  reservedSize: 42,
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= entries.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[index].key,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: color,
                barWidth: 4,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: color,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withOpacity(0.14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    try {
      final pieChartImage = await _captureChart(_pieChartKey);
      final pestsChartImage = await _captureChart(_pestsBarKey);
      final usersChartImage = await _captureChart(_usersLineKey);
      final activeChartImage = await _captureChart(_activeUsersBarKey);

      final pdf = pw.Document();

      pw.Widget? buildPdfImage(Uint8List? bytes) {
        if (bytes == null) return null;
        return pw.Container(
          margin: const pw.EdgeInsets.only(top: 10, bottom: 18),
          child: pw.Image(
            pw.MemoryImage(bytes),
            fit: pw.BoxFit.contain,
            height: 220,
          ),
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(
              'Admin Analytics Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'This report presents a summary of platform activity, including user registrations, pest detections, and active user engagement trends. The charts and descriptions below are intended to support monitoring, analysis, and administrative decision-making.',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Summary Metrics',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      )),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Users: $totalUsers'),
                  pw.Text('Total Pest Detections: $totalPests'),
                ],
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Text(
              'Users vs Pests Distribution',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'This chart compares the number of registered users with the total pest detections recorded in the system. It gives a quick visual overview of platform participation versus monitoring activity.',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
            ),
            if (buildPdfImage(pieChartImage) != null)
              buildPdfImage(pieChartImage)!,
            pw.Text(
              'Pests Detected Per Day',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'This bar chart shows how many pest detections were logged each day. It helps identify trends, sudden increases, and high-activity periods in reporting.',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
            ),
            if (buildPdfImage(pestsChartImage) != null)
              buildPdfImage(pestsChartImage)!,
            pw.Text(
              'Users Registered Per Day',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'This line chart displays daily user registration activity. It helps show whether the system is growing steadily or if registration spikes happened during certain dates.',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
            ),
            if (buildPdfImage(usersChartImage) != null)
              buildPdfImage(usersChartImage)!,
            pw.Text(
              'Active Users Per Day',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'This chart estimates daily active users based on unique usernames found in pest detection records. It provides a helpful view of actual engagement rather than just total registration count.',
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
            ),
            if (buildPdfImage(activeChartImage) != null)
              buildPdfImage(activeChartImage)!,
            pw.SizedBox(height: 8),
            pw.Text(
              'Detailed Table',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: const [
                'Date',
                'Pests Detected',
                'Users Registered',
                'Active Users'
              ],
              data: {
                ...pestsPerDay.keys,
                ...usersPerDay.keys,
                ...activeUsersPerDay.keys,
              }.map((date) {
                return [
                  date,
                  (pestsPerDay[date] ?? 0).toString(),
                  (usersPerDay[date] ?? 0).toString(),
                  (activeUsersPerDay[date] ?? 0).toString(),
                ];
              }).toList(),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('PDF EXPORT ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Admin Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 920;
                return GridView.count(
                  crossAxisCount: isWide ? 2 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 2.5 : 2.2,
                  children: [
                    _buildSummaryCard(
                      title: 'Total Users',
                      value: totalUsers.toString(),
                      color: Colors.blue,
                      icon: Icons.people_alt_rounded,
                    ),
                    _buildSummaryCard(
                      title: 'Total Pest Detections',
                      value: totalPests.toString(),
                      color: Colors.red,
                      icon: Icons.bug_report_rounded,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _buildSection(
              title: 'Users vs Pests Distribution',
              description:
                  'This chart compares the total number of registered users and the total number of pest detections. It provides a quick overall snapshot of system participation and field activity.',
              chart: _buildPieChart(),
            ),
            const SizedBox(height: 18),
            _buildSection(
              title: 'Pests Detected Per Day',
              description:
                  'This bar chart shows the number of pest detections recorded on each day. It helps administrators see activity spikes and identify periods with higher reporting volume.',
              chart: _buildBarChart(
                chartKey: _pestsBarKey,
                data: pestsPerDay,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            _buildSection(
              title: 'Users Registered Per Day',
              description:
                  'This line chart displays how many users registered each day. It is useful for understanding account growth patterns and measuring user acquisition over time.',
              chart: _buildLineChart(
                chartKey: _usersLineKey,
                data: usersPerDay,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 18),
            _buildSection(
              title: 'Active Users Per Day',
              description:
                  'This chart estimates active users by counting unique usernames that appeared in daily pest detection records. It gives a better picture of real engagement and actual reporting activity.',
              chart: _buildBarChart(
                chartKey: _activeUsersBarKey,
                data: activeUsersPerDay,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
