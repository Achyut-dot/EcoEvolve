import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true; // Member variable to track password visibility

  Future<void> _signIn(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (email.contains("@gov")) {
        // Redirect to a specific view page for government users
        Navigator.pushReplacementNamed(context, '/govView');
      } else {
        // Redirect to the home page for other users
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Handle sign-in error
      debugPrint(e.toString());
      _showPasswordAlert('Incorrect email or password.');
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Handle sign-in with Google error
      debugPrint(e.toString());
    }
  }

  void _showPasswordAlert(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
  }

  void _toggleVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.lightGreen[100],
        body: Padding(
          padding: const EdgeInsets.only(top: 110.0), // Add top padding
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 220, // Adjust height for smaller image
                    child: Image.asset(
                      'assets/login_page.png',
                      fit: BoxFit.contain, // Adjust fit property
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(height: 10.0),
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    prefixIcon: Icons.lock,
                    obscureText: _isObscure,
                    toggleVisibility: _toggleVisibility,
                    isPassword: true, // Set isPassword to true for the password field
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to forget password screen
                            Navigator.pushNamed(context, '/forgetPassword');
                          },
                          child: const Text(
                            'Forget Password?',
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      _signIn(email, password, context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green[700],
                    ),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      _signInWithGoogle(context);
                    },
                    icon: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Image(
                        image: AssetImage('assets/google_logo.png'),
                        height: 24,
                        width: 24,
                      ),
                    ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Don\'t Have an Account? Sign Up',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(prefixIcon, color: Colors.black87),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.black87,
          ),
          onPressed: toggleVisibility ?? () {},
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: const TextStyle(color: Colors.black87),
      obscureText: obscureText,
      onChanged: (value) {
        /* Handle input changes */
      },
    );
  }
}
