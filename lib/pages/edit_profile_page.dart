import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.userId});

  final String userId;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  bool _updating = false;
  late User _user;
  late AnimationController _animationController;
  File? _imageFile;
  String _profilePhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _fetchUserDetails() async {
    try {
      _user = FirebaseAuth.instance.currentUser!;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();
      _nameController.text = userSnapshot['name'];
      _mobileController.text = userSnapshot['mobileNumber'];
      _cityController.text = userSnapshot['city'];
      _emailController.text = userSnapshot['email'];
      _addressController.text = userSnapshot['address'] ?? '';
      _genderController.text = userSnapshot['gender'] ?? '';
      // Load the user's profile photo URL if available
      String? photoUrl = userSnapshot['userPhotoUrl'];
      if (photoUrl!.isNotEmpty) {
        setState(() {
          _imageFile = null;
          _profilePhotoUrl = photoUrl; // Use null-aware operator to handle null value
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user details: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45.0),
        child: AppBar(
          backgroundColor: Colors.lightGreen[500],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "Edit Profile", // Title text
            style: TextStyle(
              fontSize: 28, // Increased font size
              fontWeight: FontWeight.bold, // Bold font weight
              fontFamily: 'Roboto', // Custom font family
              color: Colors.black, // Text color
            ),
          ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : _profilePhotoUrl.isNotEmpty
                        ? NetworkImage(_profilePhotoUrl) as ImageProvider<Object>?
                        : null,
                    child: _imageFile == null && _profilePhotoUrl.isEmpty
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),


                const SizedBox(height: 20),
                _buildFormField(
                    'Name', FontAwesomeIcons.user, _nameController),
                const SizedBox(height: 12),
                _buildFormField('Mobile Number', FontAwesomeIcons.phone,
                    _mobileController),
                const SizedBox(height: 12),
                _buildFormField(
                    'City', FontAwesomeIcons.city, _cityController),
                const SizedBox(height: 12),
                _buildFormField(
                    'Email', FontAwesomeIcons.envelope, _emailController),
                const SizedBox(height: 12),
                _buildFormField(
                    'Address', FontAwesomeIcons.house, _addressController),
                const SizedBox(height: 12),
                _buildFormField(
                    'Gender', FontAwesomeIcons.venusMars, _genderController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updating ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: Colors.lightGreen[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.grey.withOpacity(0.5),
                    elevation: 5,
                  ),
                  child: _updating
                      ? const CircularProgressIndicator()
                      : Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, IconData icon, TextEditingController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12.0, // Increase vertical padding slightly
        horizontal: 16.0,
      ),
      child: Row(
        children: [
          FaIcon(
            icon,
            color: Colors.green[700],
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: 1, // Set maxLines to 1 to keep the content in one line
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero, // Remove internal padding
                isDense: true, // Reduce the height of the text box
                labelStyle: const TextStyle(fontSize: 16), // Adjust font size
              ),
              style: const TextStyle(fontSize: 18), // Adjust font size
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() {
      _updating = true;
    });

    try {
      final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

      if (_imageFile != null) {
        // Upload the image to Firebase Storage
        final firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('${_user.uid}.jpg');
        await ref.putFile(_imageFile!);
        // Get the download URL of the uploaded image
        _profilePhotoUrl = await ref.getDownloadURL();
      }

      await users.doc(_user.uid).update({
        'name': _nameController.text,
        'mobileNumber': _mobileController.text,
        'city': _cityController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'gender': _genderController.text,
        'userPhotoUrl': _profilePhotoUrl, // Update the user photo URL in Firestore
      });

      await _user.verifyBeforeUpdateEmail(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      setState(() {
        _updating = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
