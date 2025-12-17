import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pc').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No pest detections found."));
        }

        final pests = snapshot.data!.docs;

        // Count pests by type
        final pestCountMap = <String, int>{};
        for (var doc in pests) {
          final data = doc.data() as Map<String, dynamic>;
          final type = data['pestType'] ?? 'Unknown';
          pestCountMap[type] = (pestCountMap[type] ?? 0) + 1;
        }

        return Column(
          children: [
            // Total pests card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Total Pests Detected",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(pests.length.toString(),
                          style:
                              const TextStyle(fontSize: 24, color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ),
            // Bar chart for pest types
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (pestCountMap.values.isEmpty
                          ? 1
                          : pestCountMap.values
                              .reduce((a, b) => a > b ? a : b)) *
                      1.2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < pestCountMap.keys.length) {
                            return Text(
                                pestCountMap.keys.elementAt(value.toInt()));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    pestCountMap.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: pestCountMap.values.elementAt(index).toDouble(),
                          color: Colors.red,
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
