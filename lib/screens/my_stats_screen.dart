import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

/// ✔ Screen widget for GetX navigation
class MyStatsScreen extends StatelessWidget {
  const MyStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

/// ✔ Stateful Dashboard
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildDailyScoreCard(),
              const SizedBox(height: 16),
              _buildCalendarCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToDetails(context, 'Distance Travelled'),
                      child: _buildDistanceCard(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToDetails(context, 'CO2 Emissions'),
                      child: _buildCO2Card(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _navigateToDetails(context, 'Fuel Cost'),
                child: _buildFuelCostCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(title: title),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🟣 WIDGET METHODS (clean, no duplicates)
  // ---------------------------------------------------------------------------

  Widget _buildDailyScoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Score',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Your daily score',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const Text(
                  '75',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final monthNames = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];

    final firstDayOfMonth =
    DateTime(selectedMonth.year, selectedMonth.month, 1);

    int firstWeekday = (firstDayOfMonth.weekday + 1) % 7;

    final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday));
    final List<DateTime> weekDates =
    List.generate(7, (index) => startDate.add(Duration(days: index)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.blue),
                    onPressed: _previousMonth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.blue),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sat','Sun','Mon','Tue','Wed','Thu','Fri']
                .map((day) => Text(day,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDates.map((date) {
              final isCurrentMonth = date.month == selectedMonth.month;
              return Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isCurrentMonth ? Colors.black : Colors.grey[400],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D4E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distance Travelled',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('6000 km',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCO2Card() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "CO₂ Chart goes here",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildFuelCostCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "Fuel cost chart",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// DETAIL PAGE
/// ---------------------------------------------------------------------------

class DetailPage extends StatefulWidget {
  final String title;

  const DetailPage({super.key, required this.title});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String selectedPeriod = 'Day';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "Detail Screen",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}