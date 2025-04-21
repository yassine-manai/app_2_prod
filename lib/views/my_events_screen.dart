import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<dynamic> bookedEvents = [];
  bool isLoading = true;
  String errorMessage = '';
  String baseUrl = 'http://172.16.12.196:5050';

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

Future<void> _fetchUserEvents() async {
  try {
    setState(() {
      isLoading = true;
      errorMessage = '';
      bookedEvents = []; // Clear previous events
    });

    // Step 1: Get user profile with booked events
    final profileResponse = await http.get(
              Uri.parse('$baseUrl/mobile/get_profile?user_id=13'),

      headers: {'Content-Type': 'application/json'},
    );

    if (profileResponse.statusCode != 200) {
      throw Exception('Failed to load user profile: ${profileResponse.statusCode}');
    }

    print("Fetched event IDs: ${profileResponse.body}"); // Debugging line


    final profileData = json.decode(profileResponse.body);
    final List<int> eventIds = List<int>.from(profileData['event_id'] ?? []);


    if (eventIds.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Step 2: Get details for each booked event individually
    final List<dynamic> fetchedEvents = [];
    
    for (final eventId in eventIds) {
      try {
        final eventResponse = await http.get(
          Uri.parse('$baseUrl/mobile/get_events?event_id=$eventId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (eventResponse.statusCode == 200) {
          final eventData = json.decode(eventResponse.body);
          if (eventData is Map<String, dynamic>) {
            fetchedEvents.add(eventData);
          }
          // Update UI after each successful fetch for better UX
          setState(() {
            bookedEvents = List.from(fetchedEvents);
          });
        } else {
          debugPrint('Failed to load event $eventId: ${eventResponse.statusCode}');
        }
      } catch (e) {
        debugPrint('Error loading event $eventId: $e');
        // Continue with next event even if one fails
      }
    }

    if (fetchedEvents.isEmpty) {
      throw Exception('None of the booked events could be loaded');
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Error loading events: ${e.toString()}';
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserEvents,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (bookedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No events booked yet', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Discover and book exciting events',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
          
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUserEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookedEvents.length,
        itemBuilder: (context, index) {
          final event = bookedEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to event details
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                event['image'],
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.event, size: 64, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Untitled Event',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDate(event['start_date'])} - ${_formatDate(event['end_date'])}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        event['location'] ?? 'Location not specified',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}