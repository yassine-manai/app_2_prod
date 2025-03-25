
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/event_models.dart';
import '../views/event_detail_screen.dart';
import '../views/home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final EventController _eventController = EventController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Event> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    // Initial empty search to show all events
    _performSearch('');
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });
    
    try {
      final results = await _eventController.searchEvents(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search events. Please try again.';
        _isSearching = false;
      });
    }
  }
  
  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }
  
  void _navigateToEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.hintColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          style: theme.textTheme.titleMedium,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            // Debounce the search to avoid too many API calls
            Future.delayed(const Duration(milliseconds: 300), () {
              if (value == _searchController.text) {
                _performSearch(value);
              }
            });
          },
          onSubmitted: _performSearch,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(theme),
    );
  }
  
  Widget _buildBody(ThemeData theme) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _performSearch(_searchController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No matching events found',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Try different keywords or browse all events',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return EventCard(
          event: _searchResults[index],
          onTap: () => _navigateToEventDetails(_searchResults[index]),
        );
      },
    );
  }
}
