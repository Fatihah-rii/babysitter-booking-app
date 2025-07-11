import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Stream<QuerySnapshot> _bookingsStream;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();

    if (uid != null) {
      _bookingsStream = FirebaseFirestore.instance
          .collection('bookings')
          .where('parent_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .snapshots();
    } else {
      _bookingsStream = const Stream.empty();
    }
  }

  void _deleteBooking(String docId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8EB8E5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bookingsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['babysitter_name'] ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8EB8E5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Date: ${data['date']}'),
                      Text('Time: ${data['time']}'),
                      Text('Duration: ${data['duration'] ?? '-'}'),
                      Text('Location: ${data['location']}'),
                      Text('Children: ${data['number_of_children']} (Ages ${data['age_of_children']})'),
                      Text('Status: ${data['status']}'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/editBooking',
                                arguments: {
                                  'docId': doc.id,
                                  'data': data,
                                },
                              );
                            },
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Color(0xFF8EB8E5)),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _deleteBooking(doc.id),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Color(0xFFFFA6C9)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
