import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'NavigationScreens/dashboard_screen.dart';
import 'NavigationScreens/navbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showSubtitle = false;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  final RegExp emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // simple email pattern
  final RegExp passwordRegex =
      RegExp(r'^[A-Za-z0-9]{8,}$'); // at least 8 chars, letters+numbers only

  Future<void> _validateAndLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final emailText = emailController.text.trim();
    final passwordText = passwordController.text;

    bool hasError = false;
    if (emailText.isEmpty) {
      _emailError = "Email is required";
      hasError = true;
    } else if (!emailRegex.hasMatch(emailText)) {
      _emailError = "Enter a valid email address (e.g., example@gmail.com)";
      hasError = true;
    }

    if (passwordText.isEmpty) {
      _passwordError = "Password is required";
      hasError = true;
    } else if (!passwordRegex.hasMatch(passwordText)) {
      _passwordError =
          "Password must be at least 8 characters\nand contain no special characters.";
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc('N9A1SFKWpLli9g9VlZDl')
          .get();

      var userDoc = doc;
      if (!userDoc.exists) {
        // Fallback: try to find by email in case the doc id differs
        final query = await FirebaseFirestore.instance
            .collection('user')
            .where('email', isEqualTo: emailText)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          userDoc = query.docs.first;
        }
      }

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final data = userDoc.data();
      // debug
      // ignore: avoid_print
      print('login: found user doc id=${userDoc.id} data=$data');
      final storedEmail = (data?['email'] ?? '').toString().trim();
      final storedPassword = (data?['password'] ?? '').toString();

      if (emailText != storedEmail || passwordText != storedPassword) {
        setState(() {
          _passwordError = 'Invalid email or password';
          _isLoading = false;
        });
        return;
      }

      // Success
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navbar()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5879CC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 50),
                    if (_showSubtitle) ...[
                      const Text(
                        "\"Need an account? Please visit your Barangay office and they’ll create one for you.\"",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      const SizedBox(height: 30),
                    ],
                    const Text("Your Email",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your email",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        enabledBorder: _inputBorder(Colors.grey.shade300),
                        focusedBorder: _inputBorder(primaryColor),
                        errorBorder: _inputBorder(Colors.red),
                        focusedErrorBorder: _inputBorder(Colors.red),
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Password",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your password",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        enabledBorder: _inputBorder(Colors.grey.shade300),
                        focusedBorder: _inputBorder(primaryColor),
                        errorBorder: _inputBorder(Colors.red),
                        focusedErrorBorder: _inputBorder(Colors.red),
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text("Forgot password?",
                            style: TextStyle(color: primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _validateAndLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Continue",
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSubtitle = true;
                    });
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don’t have an account? ",
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: TextStyle(
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
