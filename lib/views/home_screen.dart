import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/event_models.dart';
import '../widgets/search_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final EventController _eventController = EventController();
  final ScrollController _scrollController = ScrollController();
  
  List<Event> _events = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreEvents = true;
  static const int _pageSize = 10;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
    _setupScrollListener();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Load more when scrolled to 80% of the list
      if (_shouldLoadMore) {
        _loadMoreEvents();
      }
    });
  }
  
  bool get _shouldLoadMore => 
    _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
    !_isLoading &&
    _hasMoreEvents;
  
  Future<void> _loadEvents() async {
    if (_isRefreshing) return;
    
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _currentPage = 1;
      });
      
      final events = await _eventController.getEvents();
      
      setState(() {
        _events = events;
        _isLoading = false;
        _hasMoreEvents = events.length >= _pageSize;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events. Please check your connection.';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMoreEvents() async {
    if (_isLoading) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      _currentPage++;
  
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load more events', _loadMoreEvents);
    }
  }
  
  void _showErrorSnackBar(String message, VoidCallback onRetry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: onRetry,
        ),
      ),
    );
  }
  
  Future<void> _handleRefresh() async {
    if (_isLoading) return Future.value();
    
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadEvents();
    
    setState(() {
      _isRefreshing = false;
    });
    return Future.value();
  }
  
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  
  void _navigateToSearch() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SearchScreen(),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        tooltip: 'Scroll to top',
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }
  
  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.purple[200],
      title: Text(
        'Discover Events',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      

// Then modify the search IconButton in _buildAppBar method

      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
  icon: const Icon(Icons.search),
  tooltip: 'Search events',
  onPressed: _navigateToSearch,
),

        
      ],
    );
  }
  
  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _events.isEmpty) {
      return _buildLoadingView();
    }
    
    if (_errorMessage.isNotEmpty && _events.isEmpty) {
      return _buildErrorView(theme);
    }
    
    if (_events.isEmpty) {
      return _buildEmptyView(theme);
    }
    
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        itemCount: _events.length + (_hasMoreEvents ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _events.length) {
            return _buildLoadMoreIndicator();
          }
          
          return _buildEventCard(index);
        },
      ),
    );
  }
  
  Widget _buildEventCard(int index) {
    // Stagger animation based on index
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: EventCard(
        event: _events[index],
        onTap: () => _navigateToEventDetails(_events[index]),
      ),
    );
  }
  
  void _navigateToEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }
  
  Widget _buildLoadingView() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, __) => const EventCardSkeleton(),
    );
  }
  
  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Events Found',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new events',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}

class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 14,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  
  const EventCard({
    Key? key,
    required this.event,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSoldOut = _isEventSoldOut;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(isSoldOut, theme),
            _buildContentSection(theme),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageSection(bool isSoldOut, ThemeData theme) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildEventImage(),
        ),
        if (isSoldOut)
          Positioned(
            top: 12,
            right: 12,
            child: _buildSoldOutTag(theme),
          ),
      ],
    );
  }
  
  Widget _buildSoldOutTag(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'SOLD OUT',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildContentSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _buildLocationRow(theme),
          const SizedBox(height: 4),
          _buildDateRow(theme),
          const SizedBox(height: 12),
          _buildBottomRow(theme),
        ],
      ),
    );
  }
  
  Widget _buildLocationRow(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            event.location,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateRow(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          '${event.startDate} - ${event.endDate}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildBottomRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriceTag(theme),
        _buildCapacityIndicator(theme),
      ],
    );
  }
  
  Widget _buildPriceTag(ThemeData theme) {
    return Row(
      children: [
        Text(
          '\$${event.price.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (event.price == 0) 
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'FREE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildEventImage() {
    if (event.image.startsWith('data:image')) {
      return Image.memory(
        _decodeBase64Image(event.image),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    } else if (event.image.startsWith('http')) {
      return Image.network(
        event.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImageLoading(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
          );
        },
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }
  
  Widget _buildImageLoading({double? value}) {
    return Center(
      child: CircularProgressIndicator(
        value: value,
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.event,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }
  
  Widget _buildCapacityIndicator(ThemeData theme) {
    final usersRegistered = event.userId.length;
    final capacity = event.max_capacity;
    final percentage = _getCapacityPercentage;
    
    final CapacityStatus status = _getCapacityStatus;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            _buildStatusTag(theme, status),
            const SizedBox(width: 4),
            Text(
              '$usersRegistered/$capacity',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(status.color),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusTag(ThemeData theme, CapacityStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: status.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  double get _getCapacityPercentage {
    final usersRegistered = event.userId.length;
    final capacity = event.max_capacity;
    return (usersRegistered / capacity).clamp(0.0, 1.0);
  }
  
  CapacityStatus get _getCapacityStatus {
    final percentage = _getCapacityPercentage;
    
    if (percentage >= 1.0) {
      return CapacityStatus.full;
    } else if (percentage >= 0.8) {
      return CapacityStatus.limited;
    } else if (percentage >= 0.5) {
      return CapacityStatus.filling;
    } else {
      return CapacityStatus.available;
    }
  }
  
  bool get _isEventSoldOut => event.userId.length >= event.max_capacity;
  
  Uint8List _decodeBase64Image(String base64String) {
    String base64Image = base64String.split(',').last;
    return base64Decode(base64Image);
  }
}

class CapacityStatus {
  final String label;
  final Color color;
  
  const CapacityStatus._({required this.label, required this.color});
  
  static CapacityStatus get full => 
      const CapacityStatus._(label: 'FULL', color: Colors.red);
  
  static CapacityStatus get limited => 
      const CapacityStatus._(label: 'LIMITED', color: Colors.orange);
  
  static CapacityStatus get filling => 
      CapacityStatus._(label: 'FILLING', color: Colors.orange[300]!);
  
  static CapacityStatus get available => 
      const CapacityStatus._(label: 'AVAILABLE', color: Colors.green);
}
