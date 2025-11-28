import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  // color palette (based on your screenshot)
  static const Color backgroundDark = Color(0xFF0F0F1E);
  static const Color cardDark = Color(0xFF1E1E20);
  static const Color lavender = Color(0xFFEDE9FF);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color brightBlue = Color(0xFF2F5BFF);

  void _onNavTap(int index) {
    setState(() {
      _selectedTab = index;
    });
    // Navigate to placeholder screens for tabs that aren't Home
    switch (index) {
      case 0:
      // already home
        break;
      case 1:
        Navigator.pushNamed(context, '/planner');
        break;
      case 2:
        Navigator.pushNamed(context, '/maps');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _topSearchCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.black54),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Where are you going?",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Home\nDelhi, India', style: TextStyle(color: Colors.white70)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.work_outline, size: 16, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('Work\nAdd Shortcut', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _statCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lavender,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: Text('25%\nmore than previous months', style: TextStyle(color: Colors.black87)),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('250 g/km', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  Text('Monthly carbon emission', style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          // mini bar chart (simple)
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(12, (i) {
                double height = (i == 6) ? 28 : 18 + (i % 3) * 4;
                return Container(
                  width: 8,
                  height: height,
                  decoration: BoxDecoration(
                    color: i == 6 ? accentPurple : brightBlue.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _tile({
    required Color color,
    required Widget child,
    required VoidCallback onTap,
    double height = 90,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _gridSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Auto Trip Tracking (bigger card)
        SizedBox(
          width: 220,
          child: _tile(
            color: const Color(0xFF2E2E31),
            height: 100,
            onTap: () => Navigator.pushNamed(context, '/trip_history'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('AUTO\nTRIP\nTRACKING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                Spacer(),
                Align(alignment: Alignment.bottomRight, child: Icon(Icons.location_on, color: Colors.white)),
              ],
            ),
          ),
        ),

        SizedBox(
          width: 140,
          child: _tile(
            color: brightBlue,
            onTap: () => Navigator.pushNamed(context, '/trip_history'),
            child: const Center(
              child: Text('Trip History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),

        SizedBox(
          width: 100,
          child: _tile(
            color: accentPurple,
            onTap: () => Navigator.pushNamed(context, '/cost_calculator'),
            child: const Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text('Cost Calculator', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),

        SizedBox(
          width: 100,
          child: _tile(
            color: const Color(0xFFFFFFFF),
            onTap: () => Navigator.pushNamed(context, '/packing_checklist'),
            child: const Center(
              child: Text('AI\nPacking\nchecklist', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            ),
          ),
        ),

        SizedBox(
          width: 100,
          child: _tile(
            color: const Color(0xFFFFFFFF),
            onTap: () => Navigator.pushNamed(context, '/plan_ride'),
            child: const Center(
              child: Text('Plan a\nRide', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            ),
          ),
        ),

        SizedBox(
          width: 100,
          child: _tile(
            color: const Color(0xFFFFFFFF),
            onTap: () => Navigator.pushNamed(context, '/safety_tools'),
            child: const Center(
              child: Text('Safety\nTools', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
            ),
          ),
        ),

        SizedBox(
          width: 100,
          child: _tile(
            color: const Color(0xFF5A5A5E),
            onTap: () => Navigator.pushNamed(context, '/saved_routes'),
            child: const Center(
              child: Text('Saved\nRoutes', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // reference screenshot path (your uploaded file). Keep for visual matching:
    // /mnt/data/Screenshot 2025-11-20 at 11.29.14 AM.png

    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Good Morning,', style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 6),
                      Text('Tanvee Saxena', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // small icons area
                  Row(
                    children: [
                      // translate-like icon (square)
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.translate, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _topSearchCard(),
              const SizedBox(height: 14),
              _statCard(),
              const SizedBox(height: 12),
              // grid section (tiles)
              _gridSection(),
              const SizedBox(height: 18),

              // DISCOVER title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('DISCOVER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('See all', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 12),

              // Example discover cards (simplified)
              Column(
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(width: 80, margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8))),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(height: 6),
                                Text('Subtitle / description', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.favorite_border, color: Colors.white54),
                        )
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 80), // space for bottom nav
            ],
          ),
        ),
      ),

      // bottom navigation
      bottomNavigationBar: BottomAppBar(
        color: backgroundDark,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(icon: Icons.home, label: 'Home', index: 0),
              _navItem(icon: Icons.calendar_today, label: 'Planner', index: 1),
              _navItem(icon: Icons.location_on, label: 'Maps', index: 2),
              _navItem(icon: Icons.person, label: 'Profile', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final selected = _selectedTab == index;
    return InkWell(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? const Color(0xFF8B5CF6) : Colors.white70),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? const Color(0xFF8B5CF6) : Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
