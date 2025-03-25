import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileController {
  // Hard-coded user ID for now
  final int userId = 13;
  final String baseUrl = "http://172.16.12.40:5050/mobile";

  // Profile data model
  Map<String, dynamic> _profileData = {};
  bool _isLoading = false;
  String _error = '';

  // Getters
  Map<String, dynamic> get profileData => _profileData;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch profile data
  Future<Map<String, dynamic>> getProfile() async {
    _isLoading = true;
    _error = '';
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_profile?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _profileData = data;
        return data;
      } else {
        _error = 'Failed to load profile: ${response.statusCode}';
        throw Exception(_error);
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      throw Exception(_error);
    } finally {
      _isLoading = false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    _isLoading = true;
    _error = '';
    
    try {
      // Using the PUT endpoint for profile updates
      final response = await http.put(
        Uri.parse('$baseUrl/update_profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'name': name,
          'email': email,
          if (password != null && password.isNotEmpty) 'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        await getProfile(); // Refresh profile data
        return true;
      } else {
        _error = 'Failed to update profile: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Top-up balance
  Future<bool> topUpBalance(int amount) async {
    _isLoading = true;
    _error = '';
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/topup_balance?user_id=$userId&balance=$amount'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        await getProfile(); // Refresh profile data to show updated balance
        return true;
      } else {
        _error = 'Failed to top-up balance: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
    }
  }

Future<bool> topUpStripe(int amount) async {
    _isLoading = true;
    _error = '';
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/topup_balance?user_id=$userId&balance=$amount'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        await getProfile(); // Refresh profile data to show updated balance
        return true;
      } else {
        _error = 'Failed to top-up balance: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Logout functionality
  Future<bool> logout(BuildContext context) async {
    // Clear local data (you might want to add shared preferences or other storage)
    _profileData = {};
    
    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    
    return true;
  }
}