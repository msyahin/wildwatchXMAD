import 'package:flutter/material.dart';
import 'amphibians.dart';
import 'arachnids.dart';
import 'crustaceans.dart';
import 'insects.dart';
import 'mammals.dart';
import 'reptiles.dart';
import 'seafish.dart';
import 'birds.dart'; // Import the birds.dart interface
import 'home.dart'; // Import the HomePage
import 'scan.dart'; // Import the ScanScreen
import 'discover.dart';

class SeeAllScreen extends StatelessWidget {
  const SeeAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Categories data
    final categories = [
      {"label": "Birds", "icon": "assets/flams1.png", "color": Colors.redAccent, "route": const BirdsScreen()},
      {"label": "Mammals", "icon": "assets/lions1.png", "color": Colors.amber, "route": const mammalsScreen()},
      {"label": "Reptiles", "icon": "assets/crocs1.png", "color": Colors.green, "route": const ReptilesScreen()},
      {"label": "Fish", "icon": "assets/shark2.png", "color": Colors.blueAccent, "route": const fishScreen()},
      {"label": "Amphibians", "icon": "assets/frogs.png", "color": Colors.purpleAccent, "route": const amphibiansScreen()},
      {"label": "Insects", "icon": "assets/bees.png", "color": Colors.pinkAccent, "route": const insectsScreen()},
      {"label": "Arachnids", "icon": "assets/spiders.png", "color": Colors.lightBlueAccent, "route": const arachnidsScreen()},
      {"label": "Crustaceans", "icon": "assets/crabs.png", "color": Colors.orangeAccent, "route": const crustaceansScreen()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(
            fontFamily: 'Minecraft', // Use Minecraft font for consistency
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
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Add padding at the bottom
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two categories per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length, // Total number of categories
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  if (category["route"] != null) {
                    // Navigate to the corresponding screen if a route is defined
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => category["route"] as Widget),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: category["color"] as Color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        category["icon"] as String,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category["label"] as String,
                        style: const TextStyle(
                          fontFamily: 'Minecraft',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Bottom Navigation Bar
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
                  currentIndex: 1, // Highlight Birds tab
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
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const DiscoverScreen(),
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
