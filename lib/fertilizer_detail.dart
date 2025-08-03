import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FertilizerVerification extends StatefulWidget {
  const FertilizerVerification({super.key});

  @override
  _FertilizerVerificationState createState() => _FertilizerVerificationState();
}

class _FertilizerVerificationState extends State<FertilizerVerification> {
  List<Map<String, dynamic>> fertilizerDataList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFertilizerData();
  }

  Future<void> fetchFertilizerData() async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('fertilizerhistory')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> tempDataList = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('register')
            .where('email', isEqualTo: data['userEmail'])
            .limit(1)
            .get();

        Map<String, dynamic>? userDetails;
        if (userSnapshot.docs.isNotEmpty) {
          userDetails = userSnapshot.docs.first.data() as Map<String, dynamic>;
        }

        data['userDetails'] = userDetails;
        data['docId'] = doc.id;
        tempDataList.add(data);
      }
      
      setState(() {
        fertilizerDataList = tempDataList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyAndProcessPayment(
      String docId, double weight, Map<String, dynamic>? userDetails) async {
    if (userDetails == null) {
      print("User details not found!");
      return;
    }
    try {
      double totalRupees = weight * 5;
      String bankAccount = userDetails['bankAccount'] ?? 'N/A';
      String userEmail = userDetails['email'] ?? 'N/A';

      // Update fertilizer history first
      await FirebaseFirestore.instance.collection('fertilizerhistory').doc(docId).update({
        'status': 'Verified',
        'totalRupees': totalRupees,
        'paymentStatus': 'Processed',
      });

      print("✅ Fertilizer history updated successfully.");

      if (userEmail != 'N/A' && bankAccount != 'N/A') {
        // Check if payment already exists
        QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
            .collection('payments')
            .where('userEmail', isEqualTo: userEmail)
            .where('bankAccount', isEqualTo: bankAccount)
            .limit(1)
            .get();

        if (paymentSnapshot.docs.isNotEmpty) {
          // If exists, update the existing payment record
          String paymentDocId = paymentSnapshot.docs.first.id;
          double existingAmount = paymentSnapshot.docs.first['amountPaid'] ?? 0.0;

          await FirebaseFirestore.instance.collection('payments').doc(paymentDocId).update({
            'amountPaid': existingAmount + totalRupees,
            'timestamp': FieldValue.serverTimestamp(),
          });

          print("✅ Updated existing payment record for $userEmail.");
        } else {
          // If not, create a new payment entry
          await FirebaseFirestore.instance.collection('payments').add({
            'userEmail': userEmail,
            'bankAccount': bankAccount,
            'amountPaid': totalRupees,
            'timestamp': FieldValue.serverTimestamp(),
          });

          print("✅ New payment record created for $userEmail.");
        }
      } else {
        print("⚠️ Skipping payment entry: Missing user email or bank account.");
      }

      fetchFertilizerData();
    } catch (e) {
      print("❌ Error processing payment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizer Verification', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFertilizerData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: fertilizerDataList.length,
                itemBuilder: (context, index) {
                  return _buildVerificationCard(fertilizerDataList[index]);
                },
              ),
      ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> data) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format((data['timestamp'] as Timestamp).toDate());
    Map<String, dynamic>? userDetails = data['userDetails'];

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🌱 pH Level: ${data['pH'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("📅 Date: $formattedDate"),
            Text("👤 User: ${userDetails?['username'] ?? 'N/A'}"),
            Text("🏙️ District: ${userDetails?['district'] ?? 'N/A'}"),
            Text("🌆 City: ${userDetails?['city'] ?? 'N/A'}"),
            Text("📮 Pincode: ${userDetails?['pincode'] ?? 'N/A'}"),
            Text("🏤 Post: ${userDetails?['post'] ?? 'N/A'}"),
            Text("✉️ Email: ${data['userEmail']}"),
            Text("🏦 Bank Account: ${userDetails?['bankAccount'] ?? 'N/A'}"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showWeightEntryDialog(context, data['docId'], userDetails);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Access & Verify"),
            ),
            if (data['status'] == 'Verified')
              Text("✅ Verified - ₹${data['totalRupees'] ?? 'N/A'} Paid",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showWeightEntryDialog(BuildContext context, String docId, Map<String, dynamic>? userDetails) {
    TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Fertilizer Weight"),
          content: TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Weight (kg)"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                double weight = double.tryParse(weightController.text) ?? 0.0;
                if (weight > 0) {
                  verifyAndProcessPayment(docId, weight, userDetails);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Verify & Pay"),
            ),
          ],
        );
      },
    );
  }
}
