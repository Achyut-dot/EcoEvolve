import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'complaint_details_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MaterialApp(
    home: StatusPage(),
  ));
}

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45.0), // Increased height for the AppBar
        child: AppBar(
          backgroundColor: Colors.lightGreen[500],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "Complaint Status", // Title text
            style: TextStyle(
              fontSize: 28, // Increased font size
              fontWeight: FontWeight.bold, // Bold font weight
              fontFamily: 'Roboto', // Custom font family
              color: Colors.black, // Text color
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent, // Set background color to transparent
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[300]!, Colors.lightGreen[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ComplaintList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ComplaintList extends StatelessWidget {
  const ComplaintList({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    final String? currentUserID = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserID == null) {
      return const Center(
        child: Text('User not authenticated.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .where('userId', isEqualTo: currentUserID)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No complaints found.'),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            final Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            final String complaintID = document.id; // Get the document ID (complaint ID)
            return Card(
              color: Colors.lightGreen[200], // Set greenish color to the card
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 2.0,
              child: ListTile(
                title: Text(data['complaint'] ?? 'No complaint type'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${data['description'] ?? 'No description'}'),
                    const SizedBox(height: 4),
                    Text('Location: ${data['location'] ?? 'Unknown location'}'),
                    const SizedBox(height: 4),
                    Text('Date: ${data['date'] ?? 'Unknown date'}'),
                    const SizedBox(height: 4),
                    Text('Status: ${data['status'] ?? 'No status'}'), // Display status
                    const SizedBox(height: 4),
                    Text('Complaint ID: $complaintID'), // Display complaint ID
                    const SizedBox(height: 4),
                    Text('Waste Category: ${data['wasteCategory'] ?? 'Unknown'}'), // Display waste category
                    const SizedBox(height: 4),
                    Text('Working Days: ${data['workingDays'] ?? 'Unknown'}'), // Display working days
                    const SizedBox(height: 4),
                    // Calculate and display Days to Complete along with Completion Date
                    _buildDaysToComplete(data),
                    const SizedBox(height: 4),
                    // Display detected labels
                    Text('Detected Labels: ${data['detectedLabels'] ?? 'No labels detected'}'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ComplaintDetailsPage(data: data, complaintID: complaintID)),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Function to calculate Days to Complete along with Completion Date
  Widget _buildDaysToComplete(Map<String, dynamic> data) {
    final DateTime startDate = DateTime.parse(data['date']);
    final DateTime? completionDate = data['completionDate'] != null ? (data['completionDate'] as Timestamp).toDate() : null;

    if (completionDate != null) {
      final int daysToComplete = completionDate.difference(startDate).inDays;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Days to Complete: $daysToComplete'),
          Text('Completed On: ${_formatDate(completionDate)}'),
        ],
      );
    } else {
      return const Text('Not completed yet');
    }
  }

  // Function to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
