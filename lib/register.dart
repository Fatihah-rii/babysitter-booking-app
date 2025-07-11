import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();

  bool isLoading = false;
  bool passwordVisible = false;
  int? numberOfChildren;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'fullName': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'emergencyContactName': emergencyNameController.text.trim(),
          'emergencyContactPhone': emergencyPhoneController.text.trim(),
          'numberOfChildren': numberOfChildren,
          'role': 'parent',
          'created_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: const Color(0xFF8EB8E5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildInputField(
                controller: nameController,
                label: "Full Name",
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: emailController,
                label: "Email",
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || !value.contains('@') ? "Enter a valid email" : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: phoneController,
                label: "Phone Number",
                keyboardType: TextInputType.phone,
                validator: (value) {
                    if (value == null || value.isEmpty) return "Enter phone number";

                    // Remove dashes and spaces before validating
                    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

                    final phoneRegex = RegExp(r'^01[0-9]{8,9}$');
                    if (!phoneRegex.hasMatch(cleaned)) {
                      return "Enter valid Malaysian phone number";
                    }

                    return null;
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: addressController,
                label: "Address",
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter address" : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: emergencyNameController,
                label: "Emergency Contact Name",
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter contact name" : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: emergencyPhoneController,
                label: "Emergency Contact Phone",
                keyboardType: TextInputType.phone,
                validator: (value) {
                    if (value == null || value.isEmpty) return "Enter phone number";

                    // Remove dashes and spaces before validating
                    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

                    final phoneRegex = RegExp(r'^01[0-9]{8,9}$');
                    if (!phoneRegex.hasMatch(cleaned)) {
                      return "Enter valid Malaysian phone number";
                    }

                    return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: numberOfChildren,
                decoration: InputDecoration(
                  labelText: "Number of Children",
                  filled: true,
                  fillColor: const Color(0xFFF0F4FF),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: List.generate(10, (index) => index).map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    numberOfChildren = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select number of children' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: passwordController,
                label: "Password",
                obscureText: !passwordVisible,
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => passwordVisible = !passwordVisible),
                ),
                validator: (value) =>
                    value == null || value.length < 6 ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA6C9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Register", style: TextStyle(color: Colors.white)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF0F4FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
