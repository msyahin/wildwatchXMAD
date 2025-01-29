import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewLocationPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const ViewLocationPage({
    super.key,
    required this.latitude,
    required this.longitude,

  });

  Future<List<Map<String, dynamic>>> _fetchAnimalsAtLocation() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('animal_sightings')
          .where('latitude', isEqualTo: latitude)
          .where('longitude', isEqualTo: longitude)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      return List<Map<String, dynamic>>.from(querySnapshot.docs.first['speciesList'] ?? []);
    } catch (e) {
      debugPrint('Error fetching animals at location: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Population Counter",
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAnimalsAtLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading animals at location'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No animals found at this location'));
          }

          List<Map<String, dynamic>> animals = snapshot.data!;
          return ListView.separated(
            itemCount: animals.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              Map<String, dynamic> animal = animals[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toBeginningOfSentenceCase(animal['name']) ?? "Unknown Species",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Count: ${animal['count']}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        (animal['images'] != null && animal['images'].isNotEmpty)
                            ? animal['images'][0]
                            : 'assets/placeholder.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
