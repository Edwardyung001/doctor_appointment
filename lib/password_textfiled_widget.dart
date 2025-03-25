import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final ValueChanged<String>? onChanged;

  PasswordTextField({
    required this.label,
    required this.icon,
    this.onChanged,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: !isPasswordVisible, // Toggle password visibility
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
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.teal.shade700,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "${widget.label} is required";
        return null;
      },
      onChanged: widget.onChanged,
    );
  }
}
