// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:battleships/utils/utilities.dart'; 
import 'package:battleships/models/authentication.dart'; 
import 'dart:convert'; 
import 'package:battleships/views/registration_screen.dart'; 
import 'package:battleships/views/main_app_screen.dart'; 

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Login'),
      backgroundColor: const Color.fromARGB(255, 244, 243, 248),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(255, 93, 138, 154), Color.fromARGB(255, 5, 82, 133)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUsernameField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 30),
        _buildLoginButton(context),
        const SizedBox(height: 20),
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

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleLogin(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 3, 41, 59),
      ),
      child: const Text('Login'),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (!ValidationUtil.isValidUsername(username) || !ValidationUtil.isValidPassword(password)) {
      _showErrorDialog(context, 'Invalid credentials', 'Please enter a valid username and password.');
      return;
    }

    final user = User(username: username, password: password);
    NetworkUtil networkUtil = NetworkUtil(onUnauthorized: () => _navigateToLoginScreen(context));
    final response = await networkUtil.post('login', user.toJson());

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      await StorageUtil.storeToken(authResponse.accessToken);
      await StorageUtil.storeUsername(username); 

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainAppScreen(username: username)),
      );
    } else {
      _showErrorDialog(context, 'Error', 'An error occurred. Please try again or register if you are a new user.');
    }
  }

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationScreen())),
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 189, 185, 185),
      ),
      child: const Text('New User? Register'),
    );
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
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }
}
