import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset("assets/images/main_top.png", width: 120),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset("assets/images/main_bottom.png", width: 120),
          ),
          child,
        ],
      ),
    );
  }
}
