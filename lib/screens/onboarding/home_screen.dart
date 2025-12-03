import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../controllers/location_controller.dart';
import 'package:trackmate_app/screens/chat_screen/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = Get.find<AuthService>();
    final locationController = Get.put(LocationController());
    final userName = 'Tanvee Saxena';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // HEADER ---------------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Greetings,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.translate,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SEARCH ROUTE CARD ----------------------------------------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [

                      // SEARCH BAR ------------------------------------------------
                      GestureDetector(
                        onTap: () => Get.toNamed('/location-search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16,
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Obx(() =>
                              Row(
                                children: [
                                  const Icon(Icons.search, size: 24),
                                  const SizedBox(width: 12),

                                  // FROM ------------------------------------------------
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text('From',
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13)),
                                        Text(
                                          locationController.fromLocation.value
                                              .city,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          locationController.fromLocation.value
                                              .code,
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // SWAP ------------------------------------------------
                                  GestureDetector(
                                    onTap: () =>
                                        locationController.swapLocations(),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                          Icons.swap_horiz, size: 26,
                                          color: Colors.white),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // TO --------------------------------------------------
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text('To',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13)),
                                        Text(
                                          locationController.toLocation.value
                                              .city,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          locationController.toLocation.value
                                              .code,
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),

                      // HOME + WORK -----------------------------------------------
                      Obx(() =>
                          Row(
                            children: [

                              // HOME --------------------------------------------------
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      Get.toNamed('/edit-address',
                                          arguments: {'type': 'home'}),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.home, size: 24,
                                          color: Colors.black87),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            const Text(
                                              'Home',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              locationController.homeAddress
                                                  .value.address,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              locationController.homeAddress
                                                  .value.city,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // WORK --------------------------------------------------
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      Get.toNamed('/edit-address',
                                          arguments: {'type': 'work'}),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.work, size: 24,
                                          color: Colors.black87),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            const Text(
                                              'Work',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              locationController.workAddress
                                                  .value.address,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              locationController.workAddress
                                                  .value.city,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CARBON EMISSION -----------------------------------------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('25%', style: TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold)),
                              Text('more than previous month',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 17))
                            ],
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('250 g/km',
                                    style: TextStyle(fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87)),
                                Text('Monthly Carbon', style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13)),
                                Text('emission', style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13)),
                              ]),
                        ]),

                    const SizedBox(height: 20),

                    // Purple Bars (One darker) -----------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(12, (i) {
                        final heights = [
                          30.0,
                          40.0,
                          45.0,
                          50.0,
                          55.0,
                          60.0,
                          65.0,
                          68.0,
                          70.0,
                          74.0,
                          78.0,
                          80.0
                        ];
                        return Container(
                          width: 18,
                          height: heights[i],
                          decoration: BoxDecoration(
                            color: i == 7
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFFE9D5FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ]), // 🔥 FIXED: Added missing closing bracket here
                ),

                const SizedBox(height: 20),

                // HANDPICKED -----------------------------------------------------
                // HANDPICKED -----------------------------------------------------
                GestureDetector(
                  onTap: () => Get.toNamed('/discover'),   // << ADDED TAP NAVIGATION
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.favorite_border, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Handpicked',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'collection for you',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),


                // BUTTON ROW -----------------------------------------------------
                Row(children: [

                  // AUTO TRACKING
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/auto-trip-tracking'),
                      child: Container(
                        height: 120, padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Color(0xFF475569),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('AUTO', style: TextStyle(color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                              Text('TRIP', style: TextStyle(color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                              Text('TRACKING', style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white24,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(
                                Icons.location_on, color: Colors.white,
                                size: 32),
                          )
                        ]),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // TRIP HISTORY
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/trip-history'),
                      child: Container(
                        height: 120, padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Center(child: Text(
                            'Trip History', style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // COST CALC + RIGHT SIDE
                Row(children: [

                  // COST CALC
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/cost-calculator'),
                      child: Container(
                        height: 260, padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white24,
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(
                                  Icons.calculate, color: Colors.white,
                                  size: 40),
                            ),
                            const SizedBox(height: 16),
                            const Text('Cost Calculator',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // RIGHT SIDE PANELS
                  Expanded(
                    flex: 6,
                    child: Column(children: [

                      // PLAN A TRIP
                      GestureDetector(
                        onTap: () => Get.toNamed('/planner'),
                        child: Container(
                          height: 122, padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Center(child: Text('Plan a\nTrip',
                              style: TextStyle(fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.2),
                              textAlign: TextAlign.center)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // AI ASSISTANT
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen())),
                        child: Container(
                          height: 122, padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Color(0xFF475569),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(
                                  Icons.smart_toy, color: Colors.white,
                                  size: 32),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Any questions?', style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Ask your own AI personal assistant',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 11),
                                    maxLines: 2),
                              ],
                            ))
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ]),

                const SizedBox(height: 32),

                // DISCOVER HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DISCOVER',
                        style: TextStyle(color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    TextButton(
                        onPressed: () => Get.toNamed('/discover'),
                        child: const Text('See all', style: TextStyle(
                            color: Colors.white70, fontSize: 18)))
                  ],
                ),

                const SizedBox(height: 16),

                // DISCOVER IMAGE CARD
                Container(
                  height: 200,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20)),
                  child: Stack(children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/jaipur.png",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: Colors.red,
                            size: 20),
                      ),
                    ),

                    Positioned(bottom: 16, left: 0, right: 0,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) =>
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                width: 80, height: 8,
                                decoration: BoxDecoration(
                                  color: i == 0 ? Colors.white : Colors.white54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ))),
                    ),
                  ]),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}