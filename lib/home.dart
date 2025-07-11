import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Babysitters', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8EB8E5),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/myBookings');
            },
            tooltip: 'My Bookings',
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('babysitters').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No babysitters available.'));
          }

          final babysitters = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: babysitters.length,
            itemBuilder: (context, index) {
              final data = babysitters[index].data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(data['profile_picture'] ?? ''),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['fullName'] ?? '-',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(data['location'] ?? '-'),
                            Text('Rate: RM${data['rate_per_hour'] ?? '-'} / hour'),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/bookingForm', arguments: data);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA6C9),
                        ),
                        child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                      )
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
