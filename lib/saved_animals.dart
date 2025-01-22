import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_species.dart'; // Import the ViewSpeciesPage

class SavedAnimalsPage extends StatelessWidget {
  const SavedAnimalsPage({super.key});

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
      print('Error fetching saved animals: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Saved",
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

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSavedAnimals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading saved animals'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved animals yet'));
          }

          List<Map<String, dynamic>> savedAnimals = snapshot.data!;
          return ListView.separated(
            itemCount: savedAnimals.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              Map<String, dynamic> animal = savedAnimals[index];
              String seenDate = animal['seenDate'] ?? 'Date not available'; // Fallback for date

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
                      // Animal details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              animal['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Saved: $seenDate',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Image of the animal on the right
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          animal['images'].isNotEmpty ? animal['images'][0] : 'assets/placeholder.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
