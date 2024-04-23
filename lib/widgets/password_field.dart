import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required TextEditingController passwordController,
  }) : _passwordController = passwordController;

  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _passwordController,
      keyboardType: TextInputType.visiblePassword,
      autocorrect: false,
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.lightBlue),
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: 'Password',
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
