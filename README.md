# EcoEvolve: A Waste Management Application

The Eco Evolve Disposal Application revolutionizes waste management using modern technologies like mobile computing, machine learning, and computer vision using Google ML Kit. Available for iOS and Android via Flutter, the user-friendly app employs image recognition to help users sort waste correctly, promoting environmental stewardship. Features include real-time data and analytics via Firebase. The app educates users on recycling, enhancing waste management efficiency and supporting Sustainable Development Goals. Ultimately, Eco Evolve aims for zero landfill waste through innovative and sustainable practices.

## Features 

1. Getting Started Screen :
   - Primary interface developed using Flutter.
   - Features animations and interactive functions.
   - Includes brand-specific detailing like gradients, shadows, and custom fonts.
   - Smooth integration with app navigation.
   - Encourages user engagement towards environmental sustainability.

2. Login Screen :
   - Supports email/password and Google sign-in.
   - Adaptive interface for various devices.
   - Features password reset, sign-up, and error handling.
   - Custom styling elements consistent with brand guidelines.

3. Sign Up Screen :
   - Simplifies registration process with text inputs for user details.
   - Option to upload or take a profile picture.
   - Password validation and secure data storage in Firestore.
   - Distinguishes registration flow for government and regular users.

4. Forget Password Screen :
   - Allows users to reset their passwords via email.
   - Simple interface with text input and reset button.
   - Consistent design with the app's visual identity.
   - Handles internal errors and ensures quick password recovery.

5. Home Screen :
   - Enables submission of environmental complaints.
   - Uses Firebase, Google ML Kit, and geocoding for image processing and location-based complaints.
   - Stores complaint data securely in Firestore.
   - Personalized greeting and status feedback for users.

6. Learn Screen :
   - Repository of learning resources on environmental issues.
   - Fetches content dynamically from Cloud Firestore.
   - Organized navigation with "card" format display.
   - Interactive tool for sustainability education.

7. Status Screen :
   - Displays information about user-reported complaints.
   - Dynamic interface showing complaint details like type, description, date, location, and status.
   - Interactive elements for additional details and follow-up timelines.

8. Complaint Details Screen :
   - Provides detailed view of specific complaints.
   - Displays comprehensive complaint information from Firestore.
   - Interactive elements for better visualization and understanding of complaints.
   - Shows resolution timelines and allows feedback loops with authorities.

9. User Profile Screen :
   - Displays user profile data collected from Firestore.
   - Clean and customizable interface.
   - Users can view and update profile information.
   - Features stylish icons and secure logout option.

10. Edit Profile Screen :
    - Enables users to edit their profile data.
    - Pulls current user data from Firestore into form fields.
    - Allows profile picture upload and data updates with validation.
    - Account verification for email changes and progress feedback via Snackbars.

## Installation

  How to Use
Step 1:

 Download or clone this repo by using the link below:

   https://github.com/Achyut-dot/EcoEvolve.git

Step 2:
 Go to project root and execute the following command in console to get the required dependencies:

 flutter pub get 
  
## Dependencies Used  

The `pubspec.yaml` file for the Eco Evolve Disposal Application lists several dependencies necessary for the project. Here are the main dependencies and their purposes:

1. **firebase_core**: Core Firebase SDK for initializing Firebase in the app.
2. **cloud_firestore**: Access to Cloud Firestore for storing and retrieving data.
3. **firebase_auth**: Firebase authentication for user authentication.
4. **firebase_storage**: Firebase storage for storing files.
5. **image_picker**: Picking images from the gallery or camera.
6. **google_sign_in**: Google sign-in integration.
7. **google_ml_kit**: Machine learning features from Google.
8. **url_launcher**: Launching URLs in the app.
9. **location**: Access to the device's location.
10. **geocoding**: Converting addresses to coordinates and vice versa.
11. **intl**: Internationalization and localization support.
12. **photo_view**: Zoomable image widget.
13. **font_awesome_flutter**: Icons from Font Awesome.
14. **http**: Making HTTP requests.
15. **path_provider**: Accessing commonly used locations on the device’s file system.
16. **excel**: Reading and writing Excel files.

These dependencies enable the app to incorporate various functionalities like Firebase integration, image processing, location services, machine learning, and more, making it a robust and feature-rich platform for waste management.

## Folder Structure

Here is the core folder structure which flutter provides.

ECOEVOLVE
├── .dart_tool
├── .idea
├── android
├── assets
├── build
├── ios
├── lib
│   ├── onboarding_pages
│   │   ├── forget_password_page.dart
│   │   ├── getting_started_page.dart
│   │   ├── login_page.dart
│   │   └── sign_up_page.dart
│   ├── pages
│   │   ├── complaint_details_page.dart
│   │   ├── edit_profile_page.dart
│   │   ├── gov_view.dart
│   │   ├── home_page.dart
│   │   ├── learn_page.dart
│   │   ├── status_page.dart
│   │   ├── user_profile_page.dart
│   ├── bottom_nav_bar.dart
│   ├── firebase_options.dart
│   ├── main_screen.dart
│   └── main.dart
├── linux
├── macos
├── test
├── web
├── windows
├── .flutter-plugins
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
└── README.md

## Screenshot



