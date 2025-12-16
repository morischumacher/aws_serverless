import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
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
