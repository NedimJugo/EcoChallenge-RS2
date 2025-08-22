import 'package:ecochallenge_mobile/pages/event_management_page.dart';
import 'package:ecochallenge_mobile/pages/my_event_participations_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_mobile/models/event.dart';
import 'package:ecochallenge_mobile/providers/event_provider.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<EventResponse> _allEvents = [];
  List<EventResponse> _filteredEvents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'upcoming'; // 'upcoming', 'all'

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterEvents();
    });
  }

  void _filterEvents() {
    List<EventResponse> filteredByTime = [];
    
    if (_selectedFilter == 'upcoming') {
      // Only show events that haven't passed
      final now = DateTime.now();
      filteredByTime = _allEvents.where((event) {
        final eventDateTime = _combineDateTime(event.eventDate, event.eventTime);
        return eventDateTime.isAfter(now);
      }).toList();
    } else {
      filteredByTime = List.from(_allEvents);
    }

    if (_searchQuery.isEmpty) {
      _filteredEvents = filteredByTime;
    } else {
      _filteredEvents = filteredByTime
          .where((event) =>
    (event.title?.toLowerCase().contains(_searchQuery) ?? false) ||
    (event.description?.toLowerCase().contains(_searchQuery) ?? false))
          .toList();
    }

    // Sort by event date (ascending - nearest first)
    _filteredEvents.sort((a, b) {
      final aDateTime = _combineDateTime(a.eventDate, a.eventTime);
      final bDateTime = _combineDateTime(b.eventDate, b.eventTime);
      return aDateTime.compareTo(bDateTime);
    });
  }

  DateTime _combineDateTime(DateTime date, String time) {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  Future<void> _loadMyEvents() async {
    try {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      if (authProvider.currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Search for events created by the current user
      final searchObject = EventSearchObject(
        creatorUserId: authProvider.currentUserId,
        retrieveAll: true,
      );

      final result = await eventProvider.get(filter: searchObject.toJson());
      
      setState(() {
        _allEvents = result.items ?? [];
        _filterEvents();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent(EventResponse event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        final success = await eventProvider.deleteEvent(event.id);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Remove from local list
          setState(() {
            _allEvents.removeWhere((e) => e.id == event.id);
            _filterEvents();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _manageEvent(EventResponse event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventManagementScreen(event: event),
      ),
    );
  }

  void _navigateToParticipations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EventParticipationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange[400],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline, color: Colors.white),
            onPressed: _navigateToParticipations,
            tooltip: 'My Participations',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Filter Row
                Row(
                  children: [
                    const Text(
                      'Show: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildFilterChip('Upcoming', 'upcoming'),
                          const SizedBox(width: 8),
                          _buildFilterChip('All Events', 'all'),
                        ],
                      ),
                    ),
                    // Statistics
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${_filteredEvents.length} events',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Events List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? (_selectedFilter == 'upcoming' 
                                      ? 'No upcoming events created yet'
                                      : 'No events created yet')
                                  : 'No events found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _navigateToParticipations,
                              icon: const Icon(Icons.people_outline),
                              label: const Text('View My Participations'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMyEvents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            return EnhancedEventCard(
                              event: event,
                              onManage: () => _manageEvent(event),
                              onDelete: () => _deleteEvent(event),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _filterEvents();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[400] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class EnhancedEventCard extends StatelessWidget {
  final EventResponse event;
  final VoidCallback onManage;
  final VoidCallback onDelete;

  const EnhancedEventCard({
    Key? key,
    required this.event,
    required this.onManage,
    required this.onDelete,
  }) : super(key: key);

  DateTime get eventDateTime {
    final timeParts = event.eventTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(
      event.eventDate.year,
      event.eventDate.month,
      event.eventDate.day,
      hour,
      minute,
    );
  }

  bool get isPastEvent {
    return eventDateTime.isBefore(DateTime.now());
  }

  String get timeRemaining {
    final now = DateTime.now();
    if (eventDateTime.isBefore(now)) {
      return 'Event passed';
    }
    
    final difference = eventDateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes left';
    } else {
      return 'Starting soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.photoUrls?.isNotEmpty == true 
        ? event.photoUrls!.first 
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isPastEvent ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: isPastEvent ? 0.7 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Status Overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : const Icon(
                            Icons.event,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                  
                  // Status badges
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (event.adminApproved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Approved',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isPastEvent)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Past Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Time remaining badge
                  if (!isPastEvent)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeRemaining,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Participants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title ?? 'Untitled Event',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.currentParticipants}/${event.maxParticipants}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.eventTime.substring(0, 5), // HH:MM
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  if (event.description != null)
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (event.adminApproved || isPastEvent) ? null : onManage,
                          icon: Icon(
                            isPastEvent ? Icons.visibility : Icons.edit,
                            size: 16,
                          ),
                          label: Text(
                            isPastEvent 
                                ? 'View'
                                : (event.adminApproved ? 'Approved' : 'Manage'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPastEvent 
                                ? Colors.grey
                                : (event.adminApproved 
                                    ? Colors.grey 
                                    : Colors.green),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}