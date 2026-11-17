import 'package:flutter/material.dart';

/// The big glowing title used at the top of every menu screen.
class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;

  const TitleText(this.text, {super.key, this.fontSize = 50.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black,
          shadows: const [
            Shadow(
              blurRadius: 20.0,
              color: Colors.white,
              offset: Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }
}
