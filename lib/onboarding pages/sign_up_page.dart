import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  bool _passwordsMatch = true;
  bool _isGovernmentUser = false;
  File? _userPhoto;

  Future<void> _signUp(
      String name,
      String email,
      String password,
      String confirmPassword,
      String mobileNumber,
      String city,
      String address,
      String gender,
      File? userPhoto,
      BuildContext context,
      ) async {
    try {
      if (password != confirmPassword) {
        setState(() {
          _passwordsMatch = false;
        });
        return;
      }

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String userPhotoUrl = '';
      if (userPhoto != null) {
        userPhotoUrl =
        await _uploadUserPhoto(userCredential.user!.uid, userPhoto);
      }

      await _storeUserInfo(
        userCredential.user!.uid,
        name,
        email,
        mobileNumber,
        city,
        address,
        gender,
        userPhotoUrl,
      );

      // Navigate to the home page or any desired screen after signing up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle sign-up errors
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The email address is already in use by another account.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred during sign-up. Please try again later.'),
          ),
        );
        if (kDebugMode) {
          print('Sign-up error: $e');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred during sign-up. Please try again later.'),
        ),
      );
      if (kDebugMode) {
        print('Sign-up error: $e');
      }
    }
  }

  Future<String> _uploadUserPhoto(String userId, File userPhoto) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child('$userId.jpg');

      final UploadTask uploadTask = storageReference.putFile(userPhoto);
      final TaskSnapshot downloadUrl = await uploadTask.whenComplete(() {});
      final String url = await downloadUrl.ref.getDownloadURL();

      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading user photo: $e');
      }
      return '';
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _userPhoto = File(pickedFile.path);
      });
    }
    return _userPhoto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isGovernmentUser = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isGovernmentUser ? Colors.green[700] : Colors.grey[300],
                    ),
                    child: Text(
                      'Government User',
                      style: TextStyle(
                        color: _isGovernmentUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isGovernmentUser = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isGovernmentUser ? Colors.green[700] : Colors.grey[300],
                    ),
                    child: Text(
                      'Normal User',
                      style: TextStyle(
                        color: !_isGovernmentUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  // Show dialog to choose between camera and gallery
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Choose Image Source"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Camera"),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              final pickedImage = await _pickImage(ImageSource.camera);
                              if (pickedImage != null) {
                                // Handle picked image
                              }
                            },
                          ),
                          TextButton(
                            child: const Text("Gallery"),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              final pickedImage = await _pickImage(ImageSource.gallery);
                              if (pickedImage != null) {
                                // Handle picked image
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Profile Picture'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              if (_userPhoto != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: FileImage(_userPhoto!),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mobileNumberController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.black),
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                obscureText: true,
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  errorText: _passwordsMatch ? null : 'Passwords do not match',
                ),
                style: const TextStyle(color: Colors.black),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _passwordsMatch = _passwordController.text == value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _signUp(
                    _nameController.text,
                    _emailController.text,
                    _passwordController.text,
                    _confirmPasswordController.text,
                    _mobileNumberController.text,
                    _cityController.text,
                    _addressController.text,
                    _genderController.text,
                    _userPhoto,
                    context,
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _storeUserInfo(
      String userId,
      String name,
      String email,
      String mobileNumber,
      String city,
      String address,
      String gender,
      String userPhotoUrl,
      ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'mobileNumber': mobileNumber,
        'city': city,
        'address': address,
        'gender': gender,
        'userPhotoUrl': userPhotoUrl,
        'isGovernmentUser': _isGovernmentUser,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error storing user info: $e');
      }
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: const SignUpPage(),
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.lightGreen[100],
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.green[700],
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.black,
        filled: true,
        labelStyle: const TextStyle(color: Colors.black87),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    ),
  ));
}
