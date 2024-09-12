// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:battleships/utils/utilities.dart'; 
import 'package:battleships/models/authentication.dart'; 
import 'dart:convert'; 
import 'package:battleships/views/login_screen.dart'; 
import 'package:battleships/views/main_app_screen.dart'; 

class RegistrationScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Register'),
      backgroundColor: const Color.fromARGB(255, 244, 243, 248), // Colorful AppBar
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(255, 93, 138, 154), Color.fromARGB(255, 5, 82, 133)], // Gradient colors
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildRegistrationForm(context),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUsernameField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 30),
        _buildRegisterButton(context),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: usernameController,
      decoration: _inputDecoration('Username'),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: true,
      decoration: _inputDecoration('Password'),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleRegistration(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 3, 41, 59),
      ),
      child: const Text('Register'),
    );
  }

  Future<void> _handleRegistration(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (!ValidationUtil.isValidUsername(username) || !ValidationUtil.isValidPassword(password)) {
      _showErrorDialog(context, 'Validation Error', 'Please make sure that the username and password are both at least 3 characters long.');
      return;
    }

    final user = User(username: username, password: password);
    NetworkUtil networkUtil = NetworkUtil(onUnauthorized: () => _navigateToLoginScreen(context));
    final response = await networkUtil.post('register', user.toJson());

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await StorageUtil.storeToken(authResponse.accessToken);
      await StorageUtil.storeUsername(username);

      _showSnackBar(context, 'Registration successful');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainAppScreen(username: username)));
    } else if (response.statusCode == 409) {
      _showErrorDialog(context, 'Registration Error', 'This username already exists. Please choose a different one.');
    } else {
      _showErrorDialog(context, 'Error', 'An unexpected error occurred during registration. Please try again.');
    }
  }

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
        ],
      ),
    );
  }
}
