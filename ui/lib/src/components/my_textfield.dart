import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;

  const MyTextfield(
      {super.key,
      this.controller,
      this.hintText = 'Hint Text',
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400] ?? Colors.grey
                  : Colors.grey[800] ?? Colors.grey,
            ),
          ),
          fillColor: Theme.of(context)
              .primaryColor
              .withOpacity(0.2), // 20% opacity for light theme
          filled: true,
        ),
      ),
    );
  }
}
