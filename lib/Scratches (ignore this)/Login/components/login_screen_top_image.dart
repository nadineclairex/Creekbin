import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60), // 👈 keep 60 here
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Center(
            child: SvgPicture.asset(
              "assets/icons/login.svg",
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),

          // Welcome text
          const Text(
            "Welcome!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),

          // Subtitle
          const Text(
            "Please log in to continue",
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
        ],
      ),
    );
  }
}
