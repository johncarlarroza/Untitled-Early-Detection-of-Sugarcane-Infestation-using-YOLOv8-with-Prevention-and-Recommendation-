import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int totalPests = 0;
  bool loading = true;

  Map<String, int> usersPerDay = {};
  Map<String, int> pestsPerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final pestsSnapshot =
          await FirebaseFirestore.instance.collection('pc').get();

      final fetchedUsersPerDay = _groupByDay(usersSnapshot.docs, 'createdAt');
      final fetchedPestsPerDay = _groupByDay(pestsSnapshot.docs, 'timestamp');

      if (!mounted) return;

      setState(() {
        totalUsers = usersSnapshot.docs.length;
        totalPests = pestsSnapshot.docs.length;
        usersPerDay = fetchedUsersPerDay;
        pestsPerDay = fetchedPestsPerDay;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching stats: $e");
      if (!mounted) return;
      setState(() => loading = false);
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.16),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
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
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              height: 1.45,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    if (totalUsers == 0 && totalPests == 0) {
      return const Center(child: Text('No data available'));
    }

    return SizedBox(
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
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: totalPests.toDouble(),
              color: Colors.red,
              radius: 78,
              title: 'Pests\n$totalPests',
              titleStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, int> data, Color color) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final entries = data.entries.toList();

    return SizedBox(
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
                showTitles: true,
                reservedSize: 30,
                interval: 1,
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
                showTitles: true,
                reservedSize: 42,
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
    );
  }

  Widget _buildLineChart(Map<String, int> data, Color color) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final entries = data.entries.toList();
    final spots = _toSpots(data);

    return SizedBox(
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
                showTitles: true,
                reservedSize: 30,
                interval: 1,
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
                color: color.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: const Color(0xFFF6F8FC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard Overview",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Monitor user growth and pest detection activity in one place.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return GridView.count(
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isWide ? 2.5 : 2.2,
                  children: [
                    _buildStatCard(
                      title: "Total Users",
                      value: totalUsers.toString(),
                      icon: Icons.people_alt_rounded,
                      color: Colors.blue,
                      subtitle: "Registered accounts in the system",
                    ),
                    _buildStatCard(
                      title: "Pests Detected",
                      value: totalPests.toString(),
                      icon: Icons.bug_report_rounded,
                      color: Colors.red,
                      subtitle: "Total records captured from detections",
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: "Users vs Pests Distribution",
              description:
                  "This pie chart gives a quick overview of the proportion between registered users and recorded pest detections.",
              child: _buildPieChart(),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: "Daily Pest Detection Trend",
              description:
                  "This bar chart highlights how many pest detections were recorded each day.",
              child: _buildBarChart(pestsPerDay, Colors.red),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: "Daily User Registration Trend",
              description:
                  "This line chart shows how user registrations change over time. It gives a clearer view of growth patterns and whether new users are increasing consistently.",
              child: _buildLineChart(usersPerDay, Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
