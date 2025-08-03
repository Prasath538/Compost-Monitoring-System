import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userEmail;
  List<String> userBankAccounts = []; // List to store multiple bank accounts
  bool isLoading = true;
  List<Map<String, dynamic>> paymentHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchUserBankAccounts();
  }

  /// Fetch all bank accounts linked to the logged-in user from "register" collection
  Future<void> _fetchUserBankAccounts() async {
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    userEmail = user.email;

    try {
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('register') // 🔹 Ensure your Firestore collection is named correctly
          .where('email', isEqualTo: userEmail) // 🔹 Fetching based on user email
          .get();

      if (userDocs.docs.isNotEmpty) {
        for (var doc in userDocs.docs) {
          String? bankAccount = doc['bankAccount'];
          if (bankAccount != null && bankAccount.isNotEmpty) {
            userBankAccounts.add(bankAccount);
          }
        }
      }

      await _fetchPaymentHistory(); // Fetch payments after getting bank accounts
    } catch (e) {
      print("Error fetching user details: $e");
      setState(() => isLoading = false);
    }
  }

  /// Fetch payment history based on bank account matches
  Future<void> _fetchPaymentHistory() async {
    try {
      if (userBankAccounts.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('bankAccount', whereIn: userBankAccounts) // 🔹 Match payments with user's bank accounts
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> tempDataList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'amountPaid': data['amountPaid'] ?? 'N/A',
          'bankAccount': data['bankAccount'] ?? 'N/A',
          'userEmail': data['userEmail'] ?? 'N/A',
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
        };
      }).toList();

      setState(() {
        paymentHistory = tempDataList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching payment history: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: Colors.green.shade700,
        elevation: 5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentHistory.isEmpty
              ? const Center(child: Text("No payment history found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: paymentHistory.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(paymentHistory[index]);
                  },
                ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(data['timestamp']);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("💰 Amount Paid: ₹${data['amountPaid']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("🏦 Bank Account: ${data['bankAccount']}"),
            Text("📧 User Email: ${data['userEmail']}"),
            Text("📅 Date: $formattedDate"),
          ],
        ),
      ),
    );
  }
}
