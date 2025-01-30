import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'scan.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'saved_animals.dart';
import 'discover.dart';
import 'birds.dart';
import 'mammals.dart';
import 'reptiles.dart';
import 'seafish.dart';
import 'see_all.dart';
import 'view_species.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const HomeScreen(),
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
                    currentIndex: 0,
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
                      if (index == 1) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const ScanPage(),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(
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
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(
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
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String? displayName = user?.displayName ?? 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          WelcomeBanner(name: displayName),
          const SizedBox(height: 16),
          const DiscoverSection(),
          const SizedBox(height: 16),
          const Expanded(
            child: QuickDiscoverSection(),
          ),
        ],
      ),
    );
  }
}

class WelcomeBanner extends StatelessWidget {
  final String name;

  const WelcomeBanner({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Welcome, ',
            style: const TextStyle(
              fontFamily: 'Minecraft',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: '$name!',
                style: const TextStyle(
                  fontFamily: 'Minecraft',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Discover the wilderness today!',
          style: TextStyle(
            fontFamily: 'Minecraft',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        const YourHistoryCard(),
      ],
    );
  }
}

class YourHistoryCard extends StatelessWidget {
  const YourHistoryCard({super.key});

  Stream<int> _getSavedAnimalsCountStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(0); // Return a default value if the user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_species')
        .snapshots()
        .map((snapshot) => snapshot.docs.length); // Map the snapshot to the count
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3FF63),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your History',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<int>(
                  stream: _getSavedAnimalsCountStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        'Loading saved species...',
                        style: TextStyle(color: Colors.black),
                      );
                    }
                    final count = snapshot.data!;
                    return Text(
                      '$count new species discovered!',
                      style: const TextStyle(color: Colors.black),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore new regions!',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SavedAnimalsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
              ),
              child: const Text('Check'),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoverSection extends StatelessWidget {
  const DiscoverSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SeeAllScreen()), // Navigate to See All page
                );
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BirdsScreen()),
                  );
                },
                child: const DiscoverCard(
                  label: 'Birds',
                  iconPath: 'assets/birds.png',
                  backgroundColor: Color(0xFFFF2257),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const mammalsScreen()),
                  );
                },
                child: const DiscoverCard(
                  label: 'Mammals',
                  iconPath: 'assets/carnivore.png',
                  backgroundColor: Color(0xFFFFCF23),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReptilesScreen()),
                  );
                },
                child: const DiscoverCard(
                  label: 'Reptiles',
                  iconPath: 'assets/herbivore.png',
                  backgroundColor: Color(0xFFA3EE89),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const fishScreen()),
                  );
                },
                child: const DiscoverCard(
                  label: 'Fish',
                  iconPath: 'assets/seafish.png',
                  backgroundColor: Color(0xFF1AACFF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DiscoverCard extends StatelessWidget {
  final String label;
  final String iconPath;
  final Color backgroundColor;

  const DiscoverCard({
    super.key,
    required this.label,
    required this.iconPath,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(iconPath, width: 50, height: 50),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

class QuickDiscoverSection extends StatefulWidget {
  const QuickDiscoverSection({super.key});

  @override
  _QuickDiscoverSectionState createState() => _QuickDiscoverSectionState();
}

class _QuickDiscoverSectionState extends State<QuickDiscoverSection> {
  List<Map<String, dynamic>> animalData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRandomAnimalData();
  }

  Future<void> loadRandomAnimalData() async {
    try {
      // Load the species_data.json file
      final String response = await DefaultAssetBundle.of(context)
          .loadString('assets/species_data.json');
      List<dynamic> data = jsonDecode(response);

      // Shuffle the list and pick a subset
      data.shuffle(Random());
      List<Map<String, dynamic>> randomAnimals = data
          .take(6) // Change the number to decide how many animals to display
          .cast<Map<String, dynamic>>()
          .toList();

      setState(() {
        animalData = randomAnimals;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading species data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Discover',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : animalData.isEmpty
                  ? const Center(
                      child: Text(
                        "No animals found!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: animalData.length,
                      itemBuilder: (context, index) {
                        final animal = animalData[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewSpeciesPage(
                                  speciesData: animal,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              animal["headerImage"] ??
                                  'assets/placeholder.jpg', // Fallback image
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
