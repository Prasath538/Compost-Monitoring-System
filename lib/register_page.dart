import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _rationCardController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        var userCheck = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text.trim());
        if (userCheck.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email is already registered!"), backgroundColor: Colors.red),
          );
          return;
        }

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user!.sendEmailVerification();
        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('register').doc(uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'rationCard': _rationCardController.text.trim(),
          'street': _streetController.text.trim(),
          'post': _postController.text.trim(),
          'city': _cityController.text.trim(),
          'district': _districtController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'mobileNumber': _mobileNumberController.text.trim(),
          'bankAccount': _bankAccountController.text.trim(),
          'emailVerified': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent! Please verify before login."), backgroundColor: Colors.blue),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 5,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(_usernameController, "Username", Icons.person),
                      _buildTextField(_emailController, "Email", Icons.email, validator: _validateEmail),
                      _buildPasswordField(_passwordController, "Password"),
                      _buildPasswordField(_confirmPasswordController, "Confirm Password", isConfirm: true),
                      _buildTextField(_rationCardController, "Ration Card Number", Icons.credit_card),
                      _buildTextField(_streetController, "Street", Icons.location_on),
                      _buildTextField(_postController, "Post", Icons.local_post_office),
                      _buildTextField(_cityController, "City", Icons.location_city),
                      _buildTextField(_districtController, "District", Icons.map),
                      _buildTextField(_pincodeController, "Pincode", Icons.pin, validator: _validatePincode),
                      _buildTextField(_mobileNumberController, "Mobile Number", Icons.phone, validator: _validateMobile),
                      _buildTextField(_bankAccountController, "Bank Account Number", Icons.account_balance, validator: _validateBankAccount),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        onPressed: registerUser,
                        child: const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator ?? (value) => value!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, {bool isConfirm = false}) {
    return _buildTextField(controller, label, Icons.lock, validator: (value) => _validatePassword(value, isConfirm));
  }

  String? _validatePassword(String? value, bool isConfirm) {
    if (value == null || value.length < 6) return "Password must be at least 6 characters";
    if (isConfirm && value != _passwordController.text) return "Passwords do not match";
    return null;
  }

  String? _validateEmail(String? value) =>
      (value == null || value.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) ? "Enter a valid email" : null;
  
  String? _validatePincode(String? value) => (value == null || value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) ? "Enter a valid 6-digit pincode" : null;
  
  String? _validateMobile(String? value) => (value == null || value.length != 10 || !RegExp(r'^\d{10}$').hasMatch(value)) ? "Enter a valid 10-digit mobile number" : null;
  
  String? _validateBankAccount(String? value) => (value == null || !RegExp(r'^\d{9,18}$').hasMatch(value)) ? "Enter a valid bank account number" : null;
}
