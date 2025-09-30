import 'package:flutter/material.dart';
import 'package:capstone/Scratches%20(ignore%20this)/constants.dart';

class OrDividerScreen extends StatelessWidget {
  const OrDividerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EBE6), // beige background
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
          width: size.width * 0.8,
          child: Row(
            children: <Widget>[
              buildDivider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              buildDivider(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded buildDivider() {
    return const Expanded(
      child: Divider(color: Color(0xFFD9D9D9), height: 1.5),
    );
  }
}
