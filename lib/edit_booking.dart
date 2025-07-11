import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBookingPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditBookingPage({Key? key, required this.docId, required this.data}) : super(key: key);

  @override
  State<EditBookingPage> createState() => _EditBookingPageState();
}

class _EditBookingPageState extends State<EditBookingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController locationController;
  late TextEditingController numChildrenController;
  late TextEditingController ageChildrenController;

  String? selectedDuration;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.data['date']);
    timeController = TextEditingController(text: widget.data['time']);
    locationController = TextEditingController(text: widget.data['location']);
    numChildrenController = TextEditingController(text: widget.data['number_of_children']);
    ageChildrenController = TextEditingController(text: widget.data['age_of_children']);
    selectedDuration = widget.data['duration'];
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.data['date']) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _updateBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    await FirebaseFirestore.instance.collection('bookings').doc(widget.docId).update({
      'date': dateController.text.trim(),
      'time': timeController.text.trim(),
      'duration': selectedDuration ?? '',
      'location': locationController.text.trim(),
      'number_of_children': numChildrenController.text.trim(),
      'age_of_children': ageChildrenController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking updated successfully')),
    );

    Navigator.pop(context);
    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
        backgroundColor: const Color(0xFF8EB8E5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                  onPressed: isSubmitting ? null : _updateBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA6C9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Booking', style: TextStyle(color: Colors.white)),
                ),
              ),
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
