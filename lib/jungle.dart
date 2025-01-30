import 'dart:convert';
import 'package:flutter/material.dart';
import 'discover.dart';
import 'home.dart';
import 'scan.dart';
import 'view_species.dart';

class JungleScreen extends StatefulWidget {
  const JungleScreen({super.key});

  @override
  _JungleScreenState createState() => _JungleScreenState();
}

class _JungleScreenState extends State<JungleScreen> {
  List<Map<String, dynamic>> jungleData = [];
  bool isLoading = true; // For displaying a loading indicator

  @override
  void initState() {
    super.initState();
    loadjungleData();
  }

  Future<void> loadjungleData() async {
    try {
      // Load the species_data.json file
      final String response =
          await DefaultAssetBundle.of(context).loadString('assets/species_data.json');
      List<dynamic> data = jsonDecode(response);

      // Filter only jungle-related species
      List<Map<String, dynamic>> jungles = data
          .where((species) =>
              species["name"]?.toLowerCase() == "hornbill" ||
              species["name"]?.toLowerCase() == "hummingjungle" ||
              species["name"]?.toLowerCase() == "tiger" ||
              species["name"]?.toLowerCase() == "orangutan" ||
              species["name"]?.toLowerCase() == "crocodile" ||
              species["name"]?.toLowerCase() == "lizard" ||
              species["name"]?.toLowerCase() == "snake" ||
              species["name"]?.toLowerCase() == "grasshopper" ||
              species["name"]?.toLowerCase() == "cicada" ||
              species["name"]?.toLowerCase() == "beetle" ||
              species["name"]?.toLowerCase() == "ladybug" ||
              species["name"]?.toLowerCase() == "frog" ||
              species["name"]?.toLowerCase() == "salamander" ||
              species["name"]?.toLowerCase() == "spider" ||
              species["name"]?.toLowerCase() == "scorpion")
          .cast<Map<String, dynamic>>() // Ensure the data is cast correctly
          .toList();

      setState(() {
        jungleData = jungles;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading species data: $e');
      setState(() {
        isLoading = false; // Stop loading even if there is an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "The Jungle",
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
          Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : jungleData.isEmpty
                        ? const Center(
                            child: Text(
                              "No jungles found!",
                              style: TextStyle(
                                fontFamily: 'Minecraft',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two columns
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1, // Square cards
                            ),
                            itemCount: jungleData.length,
                            itemBuilder: (context, index) {
                              final jungle = jungleData[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to ViewSpeciesPage with the jungle's data
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewSpeciesPage(
                                        speciesData: jungle,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          jungle["headerImage"] ?? 'assets/placeholder.jpg',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      jungle["name"] ?? "Unknown jungle",
                                      style: const TextStyle(
                                        fontFamily: 'Minecraft',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
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
                  currentIndex: 1, // Highlight jungles tab
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
