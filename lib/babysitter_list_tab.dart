import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'babysitter_profile.dart';

class BabysitterListTab extends StatelessWidget {
  const BabysitterListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('babysitters')
          .where('isAvailable', isEqualTo: true) // Optional: Only show available babysitters
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No babysitters available.'));
        }

        final docs = snapshot.data!.docs;
        print('Snapshot has ${docs.length} babysitters');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    data['profile_picture'] ?? 'https://via.placeholder.com/150',
                  ),
                ),
                title: Text(
                  data['fullName'] ?? 'No name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8EB8E5),
                  ),
                ),
                subtitle: Text(data['location'] ?? 'No location'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BabysitterProfile(babysitterData: data),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA6C9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
