import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingForm extends StatefulWidget {
  final Map<String, dynamic> babysitterData;

  const BookingForm({Key? key, required this.babysitterData}) : super(key: key);

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController numChildrenController = TextEditingController();
  final TextEditingController ageChildrenController = TextEditingController();

  String? selectedDuration;
  bool isSubmitting = false;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      dateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('bookings').add({
        'parent_id': currentUser.uid,
        'babysitter_id': widget.babysitterData['uid'],
        'babysitter_name': widget.babysitterData['fullName'],
        'date': dateController.text.trim(),
        'time': timeController.text.trim(),
        'duration': selectedDuration ?? '',
        'location': locationController.text.trim(),
        'number_of_children': numChildrenController.text.trim(),
        'age_of_children': ageChildrenController.text.trim(),
        'status': 'ongoing',
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted!')),
      );

      // ✅ Navigate directly to MyBookings
      Navigator.pushNamedAndRemoveUntil(context, '/myBookings', (route) => false);
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8EB8E5),
        title: const Text('Booking Form', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDateField(),
              _buildInputField(timeController, 'Time (e.g. 10:00 AM)'),
              _buildDurationDropdown(),
              _buildInputField(locationController, 'Location'),
              _buildInputField(numChildrenController, 'Number of Children'),
              _buildInputField(ageChildrenController, 'Age of Children'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA6C9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Booking', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: dateController,
        readOnly: true,
        onTap: _selectDate,
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: 'Select Date',
          filled: true,
          fillColor: const Color(0xFFF0F4FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
      ),
    );
  }

  Widget _buildDurationDropdown() {
    List<String> durations = ['1 hour', '2 hours', '3 hours', '4 hours', 'Half day', 'Full day'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedDuration,
        items: durations.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedDuration = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'Duration',
          filled: true,
          fillColor: const Color(0xFFF0F4FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF0F4FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
