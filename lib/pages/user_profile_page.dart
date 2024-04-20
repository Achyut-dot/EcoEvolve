import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../onboarding pages/login_page.dart';
import 'edit_profile_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _mobileNo = '';
  String _city = '';
  String _email = '';
  String _profilePhotoUrl = '';
  String _address = '';
  String _gender = '';

  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(user.uid).get();

        if (userSnapshot.exists) {
          Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

          if (userData != null) {
            setState(() {
              _name = userData['name'] ?? '';
              _mobileNo = userData['mobileNumber'] ?? '';
              _city = userData['city'] ?? '';
              _email = userData['email'] ?? '';
              _profilePhotoUrl = userData['userPhotoUrl'] ?? '';
              _address = userData['address'] ?? '';
              _gender = userData['gender'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user details: $e');
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                    ),
                    if (_profilePhotoUrl.isNotEmpty)
                      Positioned.fill(
                        child: ClipOval(
                          child: Image.network(
                            _profilePhotoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              _buildProfileEntry(
                FontAwesomeIcons.user,
                'Name',
                _name,
                iconColor: Colors.green[700],
              ),
              _buildProfileEntry(
                FontAwesomeIcons.phone,
                'Mobile No',
                _mobileNo,
                iconColor: Colors.green[700],
              ),
              _buildProfileEntry(
                FontAwesomeIcons.city,
                'City',
                _city,
                iconColor: Colors.green[700],
              ),
              _buildProfileEntry(
                FontAwesomeIcons.envelope,
                'Email',
                _email,
                iconColor: Colors.green[700],
              ),
              _buildProfileEntry(
                FontAwesomeIcons.house,
                'Address',
                _address,
                iconColor: Colors.green[700],
              ),
              _buildProfileEntry(
                FontAwesomeIcons.venusMars,
                'Gender',
                _gender,
                iconColor: Colors.green[700],
              ),
              const SizedBox(height: 40.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const EditProfilePage(userId: ''),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.lightGreen[200],
                    textStyle: const TextStyle(fontSize: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileEntry(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 24,
            color: iconColor ?? Colors.black,
          ),
          const SizedBox(width: 12.0),
          Text(
            label,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6.0),
          const Text(
            ':',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
void main() {
  runApp(MaterialApp(
    home: const UserProfilePage(),
    theme: ThemeData.light(),
    routes: {
      '/login': (context) => LoginPage(),
    },
  ));
}
