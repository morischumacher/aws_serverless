import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const CustomTextButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            vertical: 30, horizontal: 30), // Increase the height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Decrease the border radius
        ),
      ),
      child: child,
    );
  }
}
