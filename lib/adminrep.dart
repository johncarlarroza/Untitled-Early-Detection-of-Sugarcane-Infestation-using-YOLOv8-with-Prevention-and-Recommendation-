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
  int totalUsers = 0;
  int totalPests = 0;
  bool loading = true;

  Map<String, int> pestsPerDay = {};
  Map<String, Set<String>> activeUsersPerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();
      final pestsSnap = await FirebaseFirestore.instance.collection('pc').get();

      pestsPerDay.clear();
      activeUsersPerDay.clear();

      for (var doc in pestsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data['createdAt'] == null) continue;
        final date = DateFormat('MMM dd')
            .format((data['createdAt'] as Timestamp).toDate());

        pestsPerDay[date] = (pestsPerDay[date] ?? 0) + 1;

        if (data['userId'] != null) {
          activeUsersPerDay.putIfAbsent(date, () => <String>{});
          activeUsersPerDay[date]!.add(data['userId']);
        }
      }

      setState(() {
        totalUsers = usersSnap.docs.length;
        totalPests = pestsSnap.docs.length;
        loading = false;
      });
    } catch (e) {
      debugPrint("Stats error: $e");
    }
  }

  /// 📄 PDF EXPORT
  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Admin Analytics Report',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Total Users: $totalUsers'),
              pw.Text('Total Pests Detected: $totalPests'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Date', 'Pests Detected', 'Active Users'],
                data: pestsPerDay.keys.map((date) {
                  return [
                    date,
                    pestsPerDay[date].toString(),
                    (activeUsersPerDay[date]?.length ?? 0).toString(),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Widget _barChart(Map<String, int> data, Color color) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return BarChart(
      BarChartData(
        maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.values.elementAt(index).toDouble(),
                width: 18,
                color: color,
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(data.keys.elementAt(v.toInt()),
                  style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeUsersCountPerDay = {
      for (var e in activeUsersPerDay.entries) e.key: e.value.length
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPdf,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Users: $totalUsers",
                style: const TextStyle(fontSize: 16)),
            Text("Total Pests: $totalPests",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text("Pests Detected Per Day",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 220, child: _barChart(pestsPerDay, Colors.red)),
            const SizedBox(height: 32),
            const Text("Active Users Per Day",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
                height: 220,
                child: _barChart(activeUsersCountPerDay, Colors.blue)),
          ],
        ),
      ),
    );
  }
}
