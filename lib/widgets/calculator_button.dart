import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
} 