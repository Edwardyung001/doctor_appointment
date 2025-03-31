import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final Function(String) onChanged;
  final bool isPassword;

  CustomTextField({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.isPassword = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        obscureText: widget.isPassword && !isPasswordVisible, // Toggle password visibility
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: Colors.teal.shade900),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(widget.icon, color: Colors.teal.shade700),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.teal.shade700,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible; // Toggle visibility
              });
            },
          )
              : null,
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "${widget.label} is required";
          return null;
        },
        onChanged: widget.onChanged,
      ),
    );
  }
}
