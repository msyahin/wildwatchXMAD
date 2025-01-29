import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'view_species.dart';
import 'view_location.dart';

class SavedAnimalsPage extends StatefulWidget {
  const SavedAnimalsPage({super.key});

  @override
  _SavedAnimalsPageState createState() => _SavedAnimalsPageState();
}

class _SavedAnimalsPageState extends State<SavedAnimalsPage> {
  bool showSavedAnimals = true; // Toggle between saved animals and flagged locations
  final String _googleApiKey = "AIzaSyDi2T2HniyP_KUpJp3Z9N6xvWILmmhW1ic"; // Replace with your API key

  Future<List<Map<String, dynamic>>> _fetchSavedAnimals() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      CollectionReference savedSpecies = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_species');

      QuerySnapshot querySnapshot = await savedSpecies.get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching saved animals: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFlaggedLocations() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('animal_sightings').get();
    List<Map<String, dynamic>> locations = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String placeName = await _getPlaceName(data['latitude'], data['longitude']);

      locations.add({
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'placeName': placeName,
        'speciesList': List<Map<String, dynamic>>.from(data['speciesList'] ?? []),
      });
    }

    return locations;
  } catch (e) {
    debugPrint('Error fetching flagged locations: $e');
    return [];
  }
}

  Future<String> _getPlaceName(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleApiKey'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['results'] != null && json['results'].isNotEmpty) {
          return json['results'][0]['formatted_address'];
        }
      }
      return "Unknown Location";
    } catch (e) {
      debugPrint('Error fetching place name: $e');
      return "Unknown Location";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Saved",
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

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Toggle Buttons
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      // Saved Animals Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showSavedAnimals = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: showSavedAnimals
                                  ? const Color(0xFFCDEB45)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "Animals",
                                style: TextStyle(
                                  fontFamily: 'Minecraft',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Flagged Locations Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showSavedAnimals = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: !showSavedAnimals
                                  ? const Color(0xFFCDEB45)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "Locations",
                                style: TextStyle(
                                  fontFamily: 'Minecraft',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Expanded(
                  child: showSavedAnimals
                      ? _buildSavedAnimalsView()
                      : _buildFlaggedLocationsView(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedAnimalsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSavedAnimals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading saved animals"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No saved animals yet"));
        }

        List<Map<String, dynamic>> savedAnimals = snapshot.data!;
        return ListView.builder(
          itemCount: savedAnimals.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> animal = savedAnimals[index];
            String seenDate = animal['seenDate'] ?? 'Date not available';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewSpeciesPage(speciesData: animal),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toBeginningOfSentenceCase(animal['name']) ?? "Unknown Species",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Saved: $seenDate",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      (animal['images'] != null && animal['images'].isNotEmpty)
                          ? animal['images'][0]
                          : 'assets/placeholder.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFlaggedLocationsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchFlaggedLocations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading locations"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No flagged locations yet"));
        }

        List<Map<String, dynamic>> locations = snapshot.data!;
        return ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> location = locations[index];

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewLocationPage(
                      latitude: location['latitude'],
                      longitude: location['longitude'], 
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location['placeName'] ?? "Unknown Location",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    const Icon(Icons.location_on, color: Colors.red),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
