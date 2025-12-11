// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:trackmate_app/services/stats_service.dart';
import 'package:trackmate_app/screens/statistics_detail_screen.dart';

class MyStatsScreen extends StatefulWidget {
  const MyStatsScreen({super.key});

  @override
  State<MyStatsScreen> createState() => _MyStatsScreenState();
}

class _MyStatsScreenState extends State<MyStatsScreen> {
  bool loading = true;

  Map<String, dynamic>? dailyScore;
  Map<String, dynamic>? calendarStats;
  Map<String, dynamic>? monthlyChart;

  final StatsService statsService = StatsService();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final ds = await statsService.getDailyScore();
    final cs = await statsService.getCalendarStats();
    final mc = await statsService.getMonthlyChart();

    setState(() {
      dailyScore = ds;
      calendarStats = cs;
      monthlyChart = mc;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xff0D0D0D),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff0D0D0D),
      appBar: AppBar(
        title: const Text("Your Stats"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// DAILY SCORE HEADER
            _headerSection(
              score: dailyScore?["score"] ?? 0,
            ),

            const SizedBox(height: 20),

            /// DISTANCE CARD
            _statsCard(
              title: "Distance Travelled",
              value: "${dailyScore?['distance_travelled'] ?? 0} km",
              icon: Icons.location_on,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StatisticsDetailScreen(
                      section: "distance",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            /// CO₂ CARD
            _statsCard(
              title: "CO₂ Emissions",
              value: "${dailyScore?['co2_emissions'] ?? 0} g",
              icon: Icons.eco,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StatisticsDetailScreen(
                      section: "co2_emissions",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            /// FUEL COST CARD
            _statsCard(
              title: "Fuel Cost",
              value: "₹ ${dailyScore?['fuel_cost'] ?? 0}",
              icon: Icons.local_gas_station,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StatisticsDetailScreen(
                      section: "fuel_cost",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER SECTION (Daily Score)
  // ============================================================

  Widget _headerSection({required int score}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xff1a1a1a),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.blue, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Score",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  "$score / 100",
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
          ),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: score / 100,
                color: Colors.blue,
                strokeWidth: 6,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  // COMMON CARD WIDGET
  // ============================================================

  Widget _statsCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xff1a1a1a),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}
