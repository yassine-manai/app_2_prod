import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/event_models.dart';
import '../controllers/event_controller.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistering = false;
  bool _isUserRegistered = false;
  String _categoryName = 'Loading...';
  final EventController _eventController = EventController();

  @override
  void initState() {
    super.initState();
    _checkIfUserRegistered();
    _fetchCategoryName();
  }

  Future<void> _checkIfUserRegistered() async {
    final userId = 13;
    setState(() {
      _isUserRegistered = widget.event.userId.contains(userId);
    });
  }

Future<void> _fetchCategoryName() async {
  try {
    String category = await _eventController.getCategory(widget.event.category);
    setState(() {
      _categoryName = category;
    });
  } catch (e) {
    setState(() {
      _categoryName = "Unknown";
    });
  }
}

  Uint8List _decodeBase64Image(String base64String) {
    String base64Image = base64String.split(',').last;
    return base64Decode(base64Image);
  }

  Future<void> _registerForEvent() async {
    final isLoggedIn = true;
    

    setState(() {
      _isRegistering = true;
    });

    try {
      final success = await _eventController.bookEvent(context, widget.event.eventId);
      
      if (success) {
        setState(() {
          _isUserRegistered = true;
        });
      }
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: widget.event.image.startsWith('data:image')
                  ? Image.memory(
                      _decodeBase64Image(widget.event.image),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 48),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 48),
                      ),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            Icons.calendar_today,
                            'Start Date',
                            widget.event.startDate,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.event_available,
                            'End Date',
                            widget.event.endDate,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.location_on,
                            'Location',
                            widget.event.location,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.category,
                            'Category',
                            _categoryName,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            context,
                            Icons.attach_money,
                            'Price',
                            '${widget.event.price.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Capacity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildCapacitySection(context),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isUserRegistered || widget.event.userId.length >= widget.event.max_capacity || _isRegistering)
                          ? null
                          : _registerForEvent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isRegistering
                          ? const CircularProgressIndicator()
                          : Text(
                              _isUserRegistered
                                  ? 'Already Registered'
                                  : widget.event.userId.length < widget.event.max_capacity
                                      ? 'Register for Event'
                                      : 'Event is Full',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySection(BuildContext context) {
    final usersRegistered = widget.event.userId.length;
    final capacity = widget.event.max_capacity;
    final percentage = (usersRegistered / capacity).clamp(0.0, 1.0);
    
    Color indicatorColor;
    if (percentage < 0.5) {
      indicatorColor = Colors.green;
    } else if (percentage < 0.8) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.red;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendees',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$usersRegistered/$capacity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
            const SizedBox(height: 8),
            Text(
              _isUserRegistered
                  ? 'You are registered for this event!'
                  : percentage >= 1.0
                      ? 'This event is full'
                      : percentage >= 0.8
                          ? 'Almost full! Reserve your spot now.'
                          : percentage >= 0.5
                              ? 'Spots are filling up quickly.'
                              : 'Plenty of spots available.',
              style: TextStyle(
                color: _isUserRegistered ? Colors.blue : indicatorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
