import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BabysitterFormPage extends StatefulWidget {
  const BabysitterFormPage({Key? key}) : super(key: key);

  @override
  State<BabysitterFormPage> createState() => _BabysitterFormPageState();
}

class _BabysitterFormPageState extends State<BabysitterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? _imageFile;
  bool isSubmitting = false;

  Future<void> pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<String> uploadImage(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('babysitter_photos')
        .child(fileName);

    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }

  Future<void> saveBabysitterData() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields and upload an image.")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final imageUrl = await uploadImage(_imageFile!);

      await FirebaseFirestore.instance.collection('babysitters').add({
        'fullName': nameController.text.trim(),
        'photo_url': imageUrl,
        'location': locationController.text.trim(),
        'qualifications': qualificationController.text.trim(),
        'experience_years': int.parse(experienceController.text.trim()),
        'price_per_hour': double.parse(priceController.text.trim()),
        'available': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Babysitter added successfully.")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save babysitter. Please try again.")),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF8EB8E5), // Baby blue
        title: Text("Add Babysitter", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Upload Image
                GestureDetector(
                  onTap: pickImageFromGallery,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFE3ED), // Light baby pink
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imageFile == null
                        ? Icon(Icons.add_a_photo, size: 40, color: Colors.pinkAccent)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                buildTextField(nameController, "Full Name"),

                // Location
                buildTextField(locationController, "Location"),

                // Qualification
                buildTextField(qualificationController, "Qualifications (comma separated)"),

                // Experience
                buildTextField(
                  experienceController,
                  "Experience (years)",
                  keyboardType: TextInputType.number,
                ),

                // Price per hour
                buildTextField(
                  priceController,
                  "Price per Hour (RM)",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : saveBabysitterData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8EB8E5), // Baby blue
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Color(0xFFF0F4FF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
