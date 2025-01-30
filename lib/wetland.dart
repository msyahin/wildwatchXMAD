import 'dart:convert';
import 'package:flutter/material.dart';
import 'discover.dart';
import 'home.dart';
import 'scan.dart';
import 'view_species.dart';

class WetlandScreen extends StatefulWidget {
  const WetlandScreen({super.key});

  @override
  _WetlandScreenState createState() => _WetlandScreenState();
}

class _WetlandScreenState extends State<WetlandScreen> {
  List<Map<String, dynamic>> wetlandData = [];
  bool isLoading = true; // For displaying a loading indicator

  @override
  void initState() {
    super.initState();
    loadwetlandData();
  }

  Future<void> loadwetlandData() async {
    try {
      // Load the species_data.json file
      final String response =
          await DefaultAssetBundle.of(context).loadString('assets/species_data.json');
      List<dynamic> data = jsonDecode(response);

      // Filter only wetland-related species
      List<Map<String, dynamic>> wetlands = data
          .where((species) =>
              species["name"]?.toLowerCase() == "duck" ||
              species["name"]?.toLowerCase() == "crocodile" ||
              species["name"]?.toLowerCase() == "frog" ||
              species["name"]?.toLowerCase() == "crab" ||
              species["name"]?.toLowerCase() == "salamander")
          .cast<Map<String, dynamic>>() // Ensure the data is cast correctly
          .toList();

      setState(() {
        wetlandData = wetlands;
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
          "The Wetland",
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
                    : wetlandData.isEmpty
                        ? const Center(
                            child: Text(
                              "No wetlands found!",
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
                            itemCount: wetlandData.length,
                            itemBuilder: (context, index) {
                              final wetland = wetlandData[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to ViewSpeciesPage with the wetland's data
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewSpeciesPage(
                                        speciesData: wetland,
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
                                          wetland["headerImage"] ?? 'assets/placeholder.jpg',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      wetland["name"] ?? "Unknown wetland",
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
                  currentIndex: 1, // Highlight wetlands tab
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
