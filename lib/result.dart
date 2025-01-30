import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'view_species.dart';

class ResultPage extends StatefulWidget {
  final File image;
  final String result;
  final dynamic probability;

  const ResultPage({
    super.key,
    required this.image,
    required this.result,
    required this.probability,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch species data from the JSON file
  Future<Map<String, dynamic>?> fetchSpeciesData(BuildContext context, String result) async {
    if (result == "Unidentified") {
      return null;
    }
    final String response = await DefaultAssetBundle.of(context).loadString('assets/species_data.json');
    List<dynamic> data = jsonDecode(response);

    final speciesName = result.trim();

    return data.firstWhere(
      (species) => species["name"].toLowerCase() == speciesName.toLowerCase(),
      orElse: () => null,
    );
  }

  /// Get user location for tracking animal sightings
  Future<Position?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permission denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Location permissions are permanently denied.");
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Flag an animal sighting and track population within a 3 km radius
  Future<void> _flagAnimalSighting() async {
  if (widget.result == "Unidentified") {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cannot flag location for an unidentified species!")),
    );
    return;
  }

  Position? position = await _getUserLocation();
  if (position == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location access denied!")),
    );
    return;
  }

  String speciesName = widget.result.trim().toLowerCase();
  double userLat = position.latitude;
  double userLng = position.longitude;

  // Fetch the species data to get the image
  final speciesData = await fetchSpeciesData(context, widget.result);

  try {
    QuerySnapshot querySnapshot = await _firestore.collection('animal_sightings').get();

    DocumentReference? nearbyDoc;
    double closestDistance = double.infinity;

    for (var doc in querySnapshot.docs) {
      double lat = doc['latitude'];
      double lng = doc['longitude'];

      double distance = Geolocator.distanceBetween(userLat, userLng, lat, lng) / 1000;

      if (distance <= 3 && distance < closestDistance) {
        closestDistance = distance;
        nearbyDoc = doc.reference;
      }
    }

    if (nearbyDoc != null) {
      // Check if the species already exists at this location
      var docData = await nearbyDoc.get();
      Map<String, dynamic> data = docData.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> speciesList = List<Map<String, dynamic>>.from(data['speciesList'] ?? []);

      bool speciesExists = false;
      for (var species in speciesList) {
        if (species['name'] == speciesName) {
          species['count'] += 1;
          speciesExists = true;
          break;
        }
      }

      if (!speciesExists) {
        speciesList.add({
          'name': speciesName,
          'count': 1,
          'images': speciesData?['images'] ?? [],
        });
      }

      await nearbyDoc.update({'speciesList': speciesList});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Population count updated!")),
      );
    } else {
      await _firestore.collection('animal_sightings').add({
        'latitude': userLat,
        'longitude': userLng,
        'speciesList': [
          {
            'name': speciesName,
            'count': 1,
            'images': speciesData?['images'] ?? [],
          }
        ],
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New sighting added!")),
      );
    }
  } catch (e) {
    debugPrint("Error flagging animal sighting: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error flagging sighting.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          // Flag Location Icon (Disabled if Unidentified)
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.flag, color: Colors.black),
              onPressed: widget.result == "Unidentified" ? null : _flagAnimalSighting,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCDEB45),
              Color(0xFFF4FFE9),
              Color(0xFFFAFFF5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Classification Result",
                style: TextStyle(
                  fontFamily: 'Minecraft',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.image,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.result == "Unidentified"
                    ? "The image could not be identified."
                    : "You've caught a species!",
                style: TextStyle(
                  fontFamily: 'Minecraft',
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: widget.result == "Unidentified" ? Colors.red : Colors.purpleAccent,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.result != "Unidentified") ...[
                Text(
                  widget.result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Minecraft',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Probability: ${(widget.probability * 100).toStringAsFixed(2)}%\nYou observed it on:\n$formattedDate",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Minecraft',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    if (widget.result != "Unidentified")
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final speciesData = await fetchSpeciesData(context, widget.result);
                            if (speciesData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewSpeciesPage(speciesData: speciesData),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Species data not found!')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCDEB45),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View Species',
                            style: TextStyle(fontFamily: 'Minecraft', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
