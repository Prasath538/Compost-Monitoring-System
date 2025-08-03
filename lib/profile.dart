import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('register').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      }
    }
  }

  final Map<String, IconData> fieldIcons = {
    "username": Icons.person,
    "email": Icons.email,
    "mobileNumber": Icons.phone,
    "bankAccount": Icons.account_balance,
    "rationCard": Icons.credit_card,
    "street": Icons.location_on,
    "post": Icons.local_post_office,
    "city": Icons.location_city,
    "district": Icons.map,
    "pincode": Icons.pin,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/a5.jpg"), // ✅ Full Background Image
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userData == null
                ? const Center(child: Text("No user data found.", style: TextStyle(fontSize: 18, color: Colors.white)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.lightGreen,
                          child: Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                        const SizedBox(height: 20),

                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9), // ✅ Semi-transparent background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: userData!.entries.map((entry) {
                                return _buildProfileItem(entry.key, entry.value.toString());
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    bool isEditable = label == "username" || label == "mobileNumber" || label == "bankAccount";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(fieldIcons[label] ?? Icons.info, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _capitalize(label),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          
          if (isEditable)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () => _editField(label, value),
            ),
        ],
      ),
    );
  }

  void _editField(String field, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${_capitalize(field)}"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: "Enter new ${_capitalize(field)}",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              await _updateField(field, controller.text.trim());
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(String field, String newValue) async {
    if (newValue.isEmpty) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('register').doc(user.uid).update({
        field: newValue,
      });

      setState(() {
        userData![field] = newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${_capitalize(field)} updated successfully!"),
        backgroundColor: Colors.green,
      ));
    }

    Navigator.of(context, rootNavigator: true).pop();
  }

  String _capitalize(String text) {
    return text.isNotEmpty ? text[0].toUpperCase() + text.substring(1) : text;
  }
}
