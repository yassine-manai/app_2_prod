import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/event_models.dart';

class EventController {
  final String baseUrl = 'http://172.16.12.40:5050';

  /// Fetch events from the server
  Future<List<Event>> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mobile/get_events'));

      if (response.statusCode == 200) {
        List<dynamic> eventData = jsonDecode(response.body);
        return eventData.map((data) => Event.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

Future<String> getCategory(int categoryId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/mobile/get_categories?category_id=$categoryId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['category_name']; // Return category name instead of ID
    } else {
      throw Exception('Failed to load category for ID $categoryId: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching category for ID $categoryId: $e');
  }
}



  /// Book an event with a hardcoded user ID for testing
  Future<bool> bookEvent(BuildContext context, int eventId) async {
    final int userId = 13; // Hardcoded for testing

    print("Booking event: event_id=$eventId, user_id=$userId");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/book-event'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'event_id': eventId, 'user_id': userId}),
      );

      print("Book event response: status=${response.statusCode}, body=${response.body}");

      if (response.statusCode == 200) {
        _showMessage(context, 'Successfully registered for the event', isError: false);
        return true;
      } else if (response.statusCode == 409) {
        _showMessage(context, 'You are already registered for this event', isError: true);
      } else if (response.statusCode == 400) {
        Map<String, dynamic> errorResponse = jsonDecode(response.body);
        _showMessage(context, 'Registration failed: ${errorResponse['error']}', isError: true);
      } else {
        _showMessage(context, 'Failed to register for the event', isError: true);
      }
    } catch (e) {
      print("Book event error: $e");
      _showMessage(context, 'An unexpected error occurred', isError: true);
    }
    return false;
  }

  /// Display a snackbar message
  void _showMessage(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  
Future<List<Event>> searchEvents(String query) async {
  try {
    // Normalize the query to make search case-insensitive
    final normalizedQuery = query.toLowerCase().trim();
    
    // If the query is empty, return all events
    if (normalizedQuery.isEmpty) {
      return getEvents();
    }
    
    // Get all events and filter them based on the query
    final allEvents = await getEvents();
    
    // Filter events where title, description, or location contains the query
    return allEvents.where((event) {
      return event.title.toLowerCase().contains(normalizedQuery) ||
             event.location.toLowerCase().contains(normalizedQuery) ||
             event.location.toLowerCase().contains(normalizedQuery);
    }).toList();
  } catch (e) {
    print('Error searching events: $e');
    throw Exception('Failed to search events');
  }
}

}

