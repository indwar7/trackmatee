import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyStatsScreen extends StatefulWidget {
  const MyStatsScreen({super.key});

  @override
  State<MyStatsScreen> createState() => _MyStatsScreenState();
}

class _MyStatsScreenState extends State<MyStatsScreen> {
  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  DateTime selectedMonth = DateTime.now();
  final List<String> tabs = ["Day", "Week", "Month", "Year"];
  String selectedTab = "Day";

  // Data sets for different tabs
  final Map<String, List<double>> _co2ChartDataByTab = {
    "Day": [3, 4, 2, 6, 5, 7, 4],
    "Week": [6, 3, 5, 8, 7, 6, 5],
    "Month": [4, 7, 3, 9, 6, 8, 5],
    "Year": [5, 8, 6, 7, 9, 5, 4],
  };

  final Map<String, List<double>> _fuelChartDataByTab = {
    "Day": [2, 5, 3, 4, 6],
    "Week": [4, 6, 5, 7, 8],
    "Month": [3, 7, 4, 6, 9],
    "Year": [5, 8, 7, 9, 10],
  };

  final Map<String, int> _distanceByTab = {
    "Day": 45,
    "Week": 320,
    "Month": 1320,
    "Year": 15400,
  };

  late List<double> co2ChartData;
  late List<double> fuelChartData;
  late int distanceValue;

  @override
  void initState() {
    super.initState();
    _updateData(); // initialize with "Day"
  }

  // ---------------------------------------------------------------------------
  // DATA LOGIC
  // ---------------------------------------------------------------------------

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      _updateData();
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
      _updateData();
    });
  }

  void _updateData() {
    co2ChartData = _co2ChartDataByTab[selectedTab] ?? [0, 0, 0, 0, 0, 0, 0];
    fuelChartData = _fuelChartDataByTab[selectedTab] ?? [0, 0, 0, 0, 0];
    distanceValue = _distanceByTab[selectedTab] ?? 0;
  }

  void _changeTab(String tab) {
    setState(() {
      selectedTab = tab;
      _updateData();
    });
  }

  // ===========================================================================
  // UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    const bg = Colors.black;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Avatar
              const Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey,
                ),
              ),

              const SizedBox(height: 18),
              _buildDailyScoreCard(),
              const SizedBox(height: 18),
              _buildTopTabs(),
              const SizedBox(height: 18),
              _buildMonthSelector(),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(child: _buildDistanceCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCo2LineChartCard()),
                ],
              ),

              const SizedBox(height: 18),
              _buildFuelBarChartCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // COMPONENTS
  // ===========================================================================

  Widget _buildDailyScoreCard() {
    const purple = Color(0xFF8B5CF6);
    const blue = Color(0xFF4F8BFF);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: purple,
            child: Icon(Icons.eco, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Score",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 2),
                Text(
                  "Your daily score",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(blue),
                ),
                const Text(
                  "75",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP TABS (Day / Week / Month / Year)
  // ---------------------------------------------------------------------------

  Widget _buildTopTabs() {
    const purple = Color(0xFF8B5CF6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tabs.map((tab) {
        final bool isActive = tab == selectedTab;

        return GestureDetector(
          onTap: () => _changeTab(tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            decoration: BoxDecoration(
              color: isActive ? purple : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? purple : Colors.white24,
                width: 1,
              ),
            ),
            child: Text(
              tab,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // MONTH SELECTOR (Animated)
  // ---------------------------------------------------------------------------

  Widget _buildMonthSelector() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey("${selectedMonth.month}-${selectedMonth.year}"),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            onPressed: _previousMonth,
          ),
          Column(
            children: [
              Text(
                "${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Overview · $selectedTab",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DISTANCE CARD
  // ---------------------------------------------------------------------------

  Widget _buildDistanceCard() {
    const lightPurple = Color(0xFFE8D4FF);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Distance travelled",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "$distanceValue km",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Based on your trips this",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CO2 LINE CHART CARD
  // ---------------------------------------------------------------------------

  Widget _buildCo2LineChartCard() {
    const purple = Color(0xFF8B5CF6);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CO₂ emissions",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "g/km · lower is better",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (co2ChartData.length - 1).toDouble(),
                minY: 0,
                maxY: 10,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      co2ChartData.length,
                          (i) => FlSpot(i.toDouble(), co2ChartData[i]),
                    ),
                    isCurved: true,
                    barWidth: 4,
                    color: purple,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FUEL BAR CHART CARD
  // ---------------------------------------------------------------------------

  Widget _buildFuelBarChartCard() {
    const purple = Color(0xFF8B5CF6);

    return Container(
      height: 230,
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fuel cost",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "₹ per trip (avg)",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
                barGroups: List.generate(
                  fuelChartData.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        width: 18,
                        toY: fuelChartData[i],
                        color: purple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CARD DECORATION
  // ---------------------------------------------------------------------------

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    );
  }
}
