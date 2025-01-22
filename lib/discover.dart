import 'package:flutter/material.dart';
import 'home.dart'; // Import HomePage
import 'scan.dart'; // Import ScanScreen
import 'jungle.dart'; // Import JunglePage
import 'wetland.dart'; // Import WetlandsPage
import 'ocean.dart'; // Import OceanPage

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> discoverData = [
      {
        "image": 'assets/jungle2.jpg',
        "label": 'Jungle',
        "route": const JungleScreen(), // Add route for JunglePage
      },
      {
        "image": 'assets/wetland.jpg',
        "label": 'Wetlands',
        "route": const WetlandScreen(), // Add route for WetlandsPage
      },
      {
        "image": 'assets/ocean.jpg',
        "label": 'Ocean',
        "route": const OceanScreen(), // Add route for OceanPage
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Discover",
          style: TextStyle(
            fontFamily: 'Minecraft',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
              bottom: 80, // Extra padding to stay above the navigation bar
            ),
            itemCount: discoverData.length, // Number of items
            itemBuilder: (context, index) {
              final item = discoverData[index];
              return GestureDetector(
                onTap: () {
                  if (item["route"] != null) {
                    // Navigate to the respective page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => item["route"] as Widget,
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 324, // Fixed width for consistency
                      height: 150, // Fixed height for consistency
                      child: Stack(
                        children: [
                          Image.asset(
                            item["image"]!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Text(
                              item["label"]!,
                              style: const TextStyle(
                                fontFamily: 'Minecraft',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Container(
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: 2, // Highlight Discover tab
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Colors.redAccent.withOpacity(0.9),
                  unselectedItemColor: Colors.white.withOpacity(0.9),
                  selectedFontSize: 14,
                  unselectedFontSize: 12,
                  iconSize: 24,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_filled),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt),
                      label: 'Scan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.manage_search_rounded),
                      label: 'Discover',
                    ),
                  ],
                  onTap: (index) {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomePage(),
                          transitionsBuilder: (_, anim, __, child) => FadeTransition(
                            opacity: anim,
                            child: child,
                          ),
                        ),
                      );
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const ScanPage(),
                          transitionsBuilder: (_, anim, __, child) => FadeTransition(
                            opacity: anim,
                            child: child,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
