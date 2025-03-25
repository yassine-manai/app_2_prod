import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController {
  final String _baseUrl = 'http://172.16.12.40:5050';

  Future<bool> login(BuildContext context, String email, String password) async {
    print("Login attempt: email=$email");

    if (password.length < 6) {
      print("Login failed: Password too short");
      _showErrorDialog(context, 'Password must be at least 6 characters');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mobile/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("Login response: status=${response.statusCode}, body=${response.body}");

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacementNamed('/home');
        return true;
      } else {
        _showErrorDialog(context, 'Login failed. Please check your credentials.');
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      _showErrorDialog(context, 'An unexpected error occurred');
      return false;
    }
  }

  Future<bool> register(BuildContext context, String email, String password, String username) async {
    print("Register attempt: email=$email, username=$username");

    if (password.length < 6) {
      print("Register failed: Password too short");
      _showErrorDialog(context, 'Password must be at least 6 characters');
      return false;
    }

    if (username.length < 3) {
      print("Register failed: Username too short");
      _showErrorDialog(context, 'Username must be at least 3 characters');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mobile/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': username}),
      );

      print(response.request);
      print("Register response: status=${response.statusCode}, body=${response.body}");

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacementNamed('/login');
        return true;
      }else if (response.statusCode == 409) {
        _showErrorDialog(context, 'User already exists');
        return false;
      } 
      else {
        _showErrorDialog(context, 'Registration failed');
        return false;
      }
    } catch (e) {
      print("Register error: $e");
      _showErrorDialog(context, 'An unexpected error occurred');
      return false;
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }
}
