import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  File? _imageFile;
  String _result = '';
  late AnimationController _animationController;
  String _currentLocation = '';
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _loadingUserData = true;
  String _greeting = '';
  String _userName = '';
  String? _selectedComplaint;
  String? _selectedWasteCategory;
  final String _selectedStatus = 'Received'; // Default status

  final List<String> _complaintOptions = [
    'Garbage Dump',
    'Yellow Spot',
    'Overflow of Septic Tanks',
    'Dead Animal(s)',
    'Dustbins not cleaned',
    'Garbage Vehicles not arrived',
    'Sweeping not done',
  ];

  final List<String> _wasteCategories = ['Dry Waste', 'Wet Waste'];

  bool _isComplaintValid = false;
  bool _complaintSubmitted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _getCurrentLocation();
    _loadUserData();
    _validateInputs(); // Initially validate inputs
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45.0), // Adjust the height as needed
        child: AppBar(
          backgroundColor: Colors.lightGreen[500],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "Eco Evolve", // Title text
            style: TextStyle(
              fontSize: 28, // Increased font size
              fontWeight: FontWeight.bold, // Bold font weight
              fontFamily: 'Roboto', // Custom font family
              color: Colors.black, // Text color
            ),
          ),
          actions: [
            IconButton(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingWithUserName(),
                const SizedBox(height: 20),
                const Text(
                  'Pollution is nothing but the resources we are not harvesting. We allow them to disperse because we’ve been ignorant of their value.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () {
                          _animationController.reset();
                          _pickImage();
                        },
                        icon: const FaIcon(FontAwesomeIcons.image),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.lightGreen[400],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () {
                          _animationController.reset();
                          _captureImage();
                        },
                        icon: const FaIcon(FontAwesomeIcons.camera),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: Colors.lightGreen[400],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_imageFile != null)
                  Column(
                    children: [
                      Image.file(
                        _imageFile!,
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Detected Labels:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Text(
                  'Current Location: $_currentLocation',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\nComplaint:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _complaintOptions.map((String complaint) {
                        IconData icon = FontAwesomeIcons.exclamation;
                        Color iconColor = Colors.black;

                        switch (complaint) {
                          case 'Garbage Dump':
                            icon = FontAwesomeIcons.trashCanArrowUp;
                            break;
                          case 'Yellow Spot':
                            icon = FontAwesomeIcons.triangleExclamation;
                            break;
                          case 'Overflow of Septic Tanks':
                            icon = FontAwesomeIcons.oilWell;
                            break;
                          case 'Dead Animal(s)':
                            icon = FontAwesomeIcons.paw;
                            break;
                          case 'Dustbins not cleaned':
                            icon = FontAwesomeIcons.solidTrashCan;
                            break;
                          case 'Garbage Vehicles not arrived':
                            icon = FontAwesomeIcons.carSide;
                            break;
                          case 'Sweeping not done':
                            icon = FontAwesomeIcons.broom;
                            break;
                        }

                        return RadioListTile<String>(
                          activeColor: Colors.black,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                complaint,
                                style: const TextStyle(color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                              FaIcon(
                                icon,
                                color: iconColor,
                              ),
                            ],
                          ),
                          value: complaint,
                          groupValue: _selectedComplaint,
                          onChanged: _isSubmitting ? null : (String? value) {
                            setState(() {
                              _selectedComplaint = value;
                              _validateInputs();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  'Waste Category:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _wasteCategories.map((String category) {
                      return Expanded(
                        child: RadioListTile<String>(
                          activeColor: Colors.black,
                          title: Text(
                            category,
                            style: const TextStyle(color: Colors.black),
                          ),
                          value: category,
                          groupValue: _selectedWasteCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedWasteCategory = newValue;
                              _validateInputs();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Enter description (Optional)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                if (_complaintSubmitted)
                  Column(
                    children: [
                      Text(
                        'Status: $_selectedStatus',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ElevatedButton(
                  onPressed: _isSubmitting || !_isComplaintValid ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Specify the button's background color
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                       width: MediaQuery.of(context).size.width * 0.8, // Set width according to screen width
                       height: 48, // Adjust height as needed
                       child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // Change progress color to black
                      ),
                    ),
                  )
                      : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8, // Set width according to screen width
                      child: const Center( // Center the text
                      child: Text(
                        'Submit Complaint',
                        style: TextStyle(
                          color: Colors.black, // Change text color to black
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingWithUserName() {
    return _loadingUserData
        ? const SizedBox.shrink()
        : Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
         if (_userName.isNotEmpty)
          Text(
            '$_greeting,',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.08, // Adjust the multiplier as needed
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          ),
        if (_userName.isNotEmpty)
          Text(
            _userName,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.08, // Adjust the multiplier as needed
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      _showMessage('No image selected.', isError: true);
      return;
    }
    setState(() {
      _imageFile = File(pickedFile.path);
      _detectLabels();
    });
    _animationController.forward();
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      _showMessage('No image captured.', isError: true);
      return;
    }
    setState(() {
      _imageFile = File(pickedFile.path);
      _detectLabels();
    });
    _animationController.forward();
  }

  Future<void> _detectLabels() async {
    final inputImage = InputImage.fromFile(_imageFile!);
    final ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    setState(() {
      _result = '';
      for (ImageLabel label in labels) {
        final String text = label.label;
        final double confidence = label.confidence;
        _result += '$text: ${confidence.toStringAsFixed(2)}\n';
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final loc.Location location = loc.Location();
      bool serviceEnabled;
      loc.PermissionStatus permissionGranted;
      loc.LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      final List<geo.Placemark> placemarks =
      await geo.placemarkFromCoordinates(
          locationData.latitude!, locationData.longitude!);
      if (placemarks.isNotEmpty) {
        final geo.Placemark placemark = placemarks.first;
        setState(() {
          _currentLocation =
              placemark.subLocality ?? placemark.locality ?? '';
          if (placemark.subLocality != null && placemark.locality != null) {
            _currentLocation =
            '${placemark.subLocality}, ${placemark.locality}';
          } else if (placemark.locality != null) {
            _currentLocation = placemark.locality!;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
    }
  }

  void _submitComplaint() async {
    setState(() {
      _isSubmitting = true;
    });

    if (_imageFile == null) {
      // Handle the case where _imageFile is null
      _showMessage('Image file is null. Please select an image.', isError: true);
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Get current date and time
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat('HH:mm:ss').format(now);

    // Save image to Firebase Storage
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('complaints')
        .child('$date$time.jpg');
    UploadTask uploadTask = storageRef.putFile(_imageFile!);

    try {
      await uploadTask;
      String imageUrl = await storageRef.getDownloadURL();

      // Get user ID and email
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        String userId = user.uid;
        String userEmail = user.email!;

        // Send complaint to Firestore
        await FirebaseFirestore.instance.collection('complaints').add({
          'date': date,
          'time': time,
          'complaint': _selectedComplaint,
          'wasteCategory': _selectedWasteCategory,
          'workingDays': DateFormat('EEEE').format(now),
          'raisedDate': date,
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'location': _currentLocation,
          'userId': userId,
          'userEmail': userEmail, // Include user email in the document
          'status': _selectedStatus,
        });

        setState(() {
          _complaintSubmitted = true;
        });
        _showMessage('Complaint submitted successfully!', isError: false);
      } else {
        _showMessage('User not authenticated!', isError: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending complaint: $e');
      }
      _showMessage(
          'Error submitting complaint. Please try again later.', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: isError ? Colors.black87 : Colors.white),
      ),
      backgroundColor: isError ? Colors.lightGreenAccent : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('name') && userData['name'] != null) {
            if (kDebugMode) {
              print('User data: $userData');
            }
            setState(() {
              _userName = userData['name'];
              _greeting = _getGreeting();
              _loadingUserData = false;
            });
            return;
          }
        }
      } else {
        _showMessage('User not authenticated!', isError: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }

    setState(() {
      _userName = 'User';
      _greeting = _getGreeting();
      _loadingUserData = false;
    });

    if (kDebugMode) {
      print('User name: $_userName');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _validateInputs() {
    setState(() {
      _isComplaintValid = _selectedComplaint != null &&
          _selectedComplaint!.isNotEmpty &&
          _selectedWasteCategory != null &&
          _selectedWasteCategory!.isNotEmpty;
    });
  }

  Future<void> _confirmLogout() async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmLogout ?? false) {
      _logout();
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _showMessage('Error occurred during logout.', isError: true);
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
