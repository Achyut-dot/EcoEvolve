import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: Colors.lightGreen[400],
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
      ),
      backgroundColor: Colors.transparent,
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('resources').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Show loading indicator
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Show error message
            }
            // Extract documents from snapshot
            final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

            // Separate videos and articles
            List<QueryDocumentSnapshot> videos = [];
            List<QueryDocumentSnapshot> articles = [];

            for (var document in documents) {
              final data = document.data() as Map<String, dynamic>;
              if (data['type'] == 'video') {
                videos.add(document);
              } else {
                articles.add(document);
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (videos.isNotEmpty) ...[
                  _buildCategory("Videos"),
                  const SizedBox(height: 8),
                  ..._buildResourceList(context, videos),
                ],
                if (articles.isNotEmpty) ...[
                  _buildCategory("Articles"),
                  const SizedBox(height: 8),
                  ..._buildResourceList(context, articles),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget to display category heading
  Widget _buildCategory(String category) {
    return Text(
      category,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Function to build list of resources
  List<Widget> _buildResourceList(BuildContext context, List<QueryDocumentSnapshot> documents) {
    return documents.map((document) {
      final data = document.data() as Map<String, dynamic>;
      IconData iconData = data['type'] == 'video' ? FontAwesomeIcons.play : FontAwesomeIcons.fileLines;
      return Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(iconData), // Use Font Awesome icon
          title: Text(data['title']),
          onTap: () {
            // Handle tap, open the resource URL if available
            if (data['url'] != null && data['url'] != '') {
              _launchURL(context, data['url']);
            } else {
              // Handle case where URL is not available
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('URL not available'),
              ));
            }
          },
        ),
      );
    }).toList();
  }

  // Function to launch URLs
  void _launchURL(BuildContext context, String url) async {
    Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }
}

void main() {
  runApp(const MaterialApp(
    home: LearnPage(),
  ));
}
