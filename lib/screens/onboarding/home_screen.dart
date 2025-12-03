import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../controllers/location_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = Get.find<AuthService>();
    final locationController = Get.put(LocationController());
    final userName = 'User';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Pure black background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.translate,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // SEARCH ROUTE CARD ----------------------------------------------
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
                  ),
                  child: Column(
                    children: [
                      // SEARCH BAR ------------------------------------------------
                      GestureDetector(
                        onTap: () => Get.toNamed('/location-search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Obx(() => Row(
                            children: [
                              const Icon(Icons.search,
                                  size: 24, color: Colors.black87),
                              const SizedBox(width: 14),

                              // FROM ------------------------------------------------
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text('From',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 2),
                                    Text(
                                      locationController
                                          .fromLocation.value.city,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      locationController
                                          .fromLocation.value.code,
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500),
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
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.swap_horiz,
                                      size: 22, color: Colors.black87),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // TO --------------------------------------------------
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text('To',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 2),
                                    Text(
                                      locationController
                                          .toLocation.value.city,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      locationController
                                          .toLocation.value.code,
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // START BUTTON ----------------------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA78BFA),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'Start',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // HOME + WORK -----------------------------------------------
                      Obx(() => Row(
                        children: [
                          // HOME --------------------------------------------------
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed('/edit-address',
                                  arguments: {'type': 'home'}),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 20, color: Colors.white70),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Home',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          locationController
                                              .homeAddress.value.address,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 10),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          locationController
                                              .homeAddress.value.city,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // WORK --------------------------------------------------
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.toNamed('/edit-address',
                                  arguments: {'type': 'work'}),
                              child: Row(
                                children: [
                                  const Icon(Icons.work_outline,
                                      size: 20, color: Colors.white70),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Work',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          locationController
                                              .workAddress.value.address,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 10),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          locationController
                                              .workAddress.value.city,
                                          style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 10),
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

                const SizedBox(height: 16),

                // ANALYTICS / STATS CARD (CLICKABLE) -------------------------
                GestureDetector(
                  onTap: () => Get.toNamed('/my-stats'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('25%',
                                    style: TextStyle(
                                        color: Color(0xFFA78BFA),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('more than previous month',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('250 g/km',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  const SizedBox(height: 2),
                                  Text('Monthly Carbon',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400)),
                                  Text('emission',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400)),
                                ]),
                          ]),
                      const SizedBox(height: 16),

                      // Purple Bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(12, (i) {
                          final heights = [
                            28.0, 35.0, 40.0, 45.0, 48.0, 52.0,
                            56.0, 60.0, 50.0, 55.0, 62.0, 68.0
                          ];
                          return Container(
                            width: 16,
                            height: heights[i],
                            decoration: BoxDecoration(
                              color: i == 6
                                  ? const Color(0xFFA78BFA)
                                  : const Color(0xFFE9D5FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ]),
                  ),
                ),

                const SizedBox(height: 16),

                // AI CHECKLIST -----------------------------------------------------
                GestureDetector(
                  onTap: () => Get.toNamed('/ai-checklist'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Container(
                                width: 16,
                                height: 3,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                width: 16,
                                height: 3,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                width: 16,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Checkboxes
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.white, size: 10),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.white, size: 10),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'AI Checklist',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // BUTTON ROW - AUTO TRACKING + TRIP HISTORY ---------------------
                Row(children: [
                  // AUTO TRIP TRACKING
                  Expanded(
                    flex: 55,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/auto-trip-tracking'),
                      child: Container(
                        height: 110,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF475569),
                            borderRadius: BorderRadius.circular(18)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('AUTO',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2)),
                                  Text('TRIP',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2)),
                                  Text('TRACKING',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.location_on,
                                    color: Colors.white, size: 28),
                              )
                            ]),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // TRIP HISTORY
                  Expanded(
                    flex: 45,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/trip-history'),
                      child: Container(
                        height: 110,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFA78BFA),
                            borderRadius: BorderRadius.circular(18)),
                        child: const Center(
                            child: Text('Trip History',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 12),

                // SECOND ROW - RECORD A TRIP + RIGHT SIDE
                Row(children: [
                  // RECORD A TRIP (VERTICAL PURPLE)
                  Expanded(
                    flex: 35,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/cost-calculator'),
                      child: Container(
                        height: 240,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFFA78BFA),
                            borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.calendar_today,
                                  color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 50),
                            const RotatedBox(
                              quarterTurns: 3,
                              child: Text('Record a trip',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // RIGHT SIDE PANELS
                  Expanded(
                    flex: 65,
                    child: Column(children: [
                      // SCHEDULE A TRIP FOR LATER
                      GestureDetector(
                        onTap: () => Get.toNamed('/planner'),
                        child: Container(
                          height: 114,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10)),
                                child:
                                const Icon(Icons.near_me, size: 32),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Schedule a',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            height: 1.2)),
                                    Text('Trip for later',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            height: 1.2)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // AI ASSISTANT
                      GestureDetector(
                        onTap: () => Get.toNamed('/ai-chatbot'),
                        child: Container(
                          height: 114,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: const Color(0xFF475569),
                              borderRadius: BorderRadius.circular(18)),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.smart_toy,
                                  color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Any questions?',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text('Ask your own AI personal assistant',
                                        style: TextStyle(
                                            color: Colors.white70, fontSize: 10),
                                        maxLines: 2),
                                  ],
                                ))
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ]),

                const SizedBox(height: 12),

                // COST CALCULATOR (FULL WIDTH WHITE)
                GestureDetector(
                  onTap: () => Get.toNamed('/cost-calculator'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.calculate_outlined,
                              size: 32, color: Colors.black),
                        ),
                        const SizedBox(width: 16),
                        const Text('Cost Calculator',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // DISCOVER HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DISCOVER',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    TextButton(
                        onPressed: () => Get.toNamed('/discover'),
                        child: const Text('See all',
                            style:
                            TextStyle(color: Colors.white70, fontSize: 14)))
                  ],
                ),

                const SizedBox(height: 12),

                // DISCOVER IMAGE CARD
                Container(
                  height: 180,
                  clipBehavior: Clip.antiAlias,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(18)),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        "assets/images/jaipur.png",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),

                    // Heart icon
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: Icon(Icons.favorite,
                            color: Colors.red, size: 20),
                      ),
                    ),

                    // Bottom content
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jaipur',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Route - Delhi - BOM expy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTag('Services'),
                              const SizedBox(width: 8),
                              _buildTag('Cost'),
                              const SizedBox(width: 8),
                              _buildTag('Co2'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 80), // Extra space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}