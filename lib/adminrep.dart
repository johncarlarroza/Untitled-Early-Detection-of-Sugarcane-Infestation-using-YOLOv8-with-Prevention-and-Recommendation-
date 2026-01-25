import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
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

      /// USERS REGISTERED PER DAY
      usersPerDay = _groupByDay(usersSnapshot.docs, 'createdAt');

      /// PESTS DETECTED PER DAY
      pestsPerDay = _groupByDay(pestsSnapshot.docs, 'timestamp');

      /// ACTIVE USERS PER DAY (USING USERNAME)
      final Map<String, Set<String>> tempActive = {};

      for (var doc in pestsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('timestamp')) continue;

        final day = DateFormat('MMM dd')
            .format((data['timestamp'] as Timestamp).toDate());

        final username = data['username'] ?? 'unknown';

        tempActive.putIfAbsent(day, () => <String>{});
        tempActive[day]!.add(username);
      }

      activeUsersPerDay = {
        for (var e in tempActive.entries) e.key: e.value.length
      };

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint('REPORT ERROR: $e');
    }
  }

  /// GROUP DOCUMENTS BY DAY
  Map<String, int> _groupByDay(
    List<QueryDocumentSnapshot> docs,
    String field,
  ) {
    final Map<String, int> result = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey(field)) continue;

      final Timestamp ts = data[field];
      final String day = DateFormat('MMM dd').format(ts.toDate());

      result[day] = (result[day] ?? 0) + 1;
    }
    return result;
  }

  /// BAR CHART WIDGET
  Widget _buildBarChart(Map<String, int> data, Color color) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    return BarChart(
      BarChartData(
        maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.values.elementAt(index).toDouble(),
                width: 18,
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() < data.keys.length) {
                  return Text(
                    data.keys.elementAt(value.toInt()),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  /// PDF EXPORT
  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Admin Analytics Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Total Users: $totalUsers'),
              pw.Text('Total Pest Detections: $totalPests'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: const ['Date', 'Pests Detected', 'Active Users'],
                data: pestsPerDay.keys.map((date) {
                  return [
                    date,
                    pestsPerDay[date].toString(),
                    activeUsersPerDay[date]?.toString() ?? '0',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOTALS
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Total Users'),
                          const SizedBox(height: 6),
                          Text(
                            totalUsers.toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Total Pests'),
                          const SizedBox(height: 6),
                          Text(
                            totalPests.toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// PESTS PER DAY
            const Text(
              'Pests Detected Per Day',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 220,
              child: _buildBarChart(pestsPerDay, Colors.red),
            ),

            const SizedBox(height: 32),

            /// USERS PER DAY
            const Text(
              'Users Registered Per Day',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 220,
              child: _buildBarChart(usersPerDay, Colors.blue),
            ),

            const SizedBox(height: 32),

            /// ACTIVE USERS PER DAY
            const Text(
              'Active Users Per Day',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 220,
              child: _buildBarChart(activeUsersPerDay, Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
