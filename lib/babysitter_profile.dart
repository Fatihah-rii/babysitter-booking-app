import 'package:flutter/material.dart';

class BabysitterProfile extends StatelessWidget {
  final Map<String, dynamic> babysitterData;

  const BabysitterProfile({Key? key, required this.babysitterData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${babysitterData['fullName'] ?? 'Babysitter'} Profile'),
        backgroundColor: const Color(0xFF8EB8E5),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(babysitterData['profile_picture'] ?? ''),
            ),
            const SizedBox(height: 20),
            Text(
              babysitterData['fullName'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Location: ${babysitterData['location'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Experience: ${babysitterData['experience'] ?? '0'} years'),
            const SizedBox(height: 8),
            Text('Rate per hour: ${babysitterData['rate_per_hour'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Bio: ${babysitterData['bio'] ?? 'No bio provided.'}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/bookingForm',
                  arguments: babysitterData,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA6C9),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Book Babysitter', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
