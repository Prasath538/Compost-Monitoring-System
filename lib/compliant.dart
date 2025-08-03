import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _complaintController = TextEditingController();
  bool isButtonEnabled = false;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _complaintController.addListener(() {
      setState(() {
        isButtonEnabled = _complaintController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> submitComplaint() async {
    if (_complaintController.text.isEmpty || user == null) return;

    try {
      await FirebaseFirestore.instance.collection('compliant').add({
        'complaint': _complaintController.text.trim(),
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
        'uid': user!.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint submitted successfully!")),
      );
      _complaintController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Page', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)], // Modern gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your complaint:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: TextField(
                  controller: _complaintController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(15),
                    border: InputBorder.none,
                    hintText: "Type your complaint here...",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? submitComplaint : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled ? Colors.blueAccent : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 5,
                  ),
                  child: const Text("Submit Complaint", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Complaint History:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('compliant')
                        .where('uid', isEqualTo: user?.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final complaints = snapshot.data?.docs ?? [];

                      if (complaints.isEmpty) {
                        return const Center(child: Text("No previous complaints found.", style: TextStyle(fontSize: 16)));
                      }

                      return ListView.builder(
                        itemCount: complaints.length,
                        itemBuilder: (context, index) {
                          final complaintData = complaints[index].data() as Map<String, dynamic>;
                          final String status = complaintData['status'] ?? 'Not Seen';

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(
                                complaintData['complaint'] ?? 'No details',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Status: $status"),
                              leading: Icon(
                                status == 'Pending' ? Icons.access_time : Icons.check_circle,
                                color: status == 'Pending' ? Colors.orange : Colors.green,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
