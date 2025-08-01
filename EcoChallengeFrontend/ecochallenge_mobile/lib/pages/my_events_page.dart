import 'package:ecochallenge_mobile/pages/event_management_page.dart';
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
    if (_searchQuery.isEmpty) {
      _filteredEvents = List.from(_allEvents);
    } else {
      _filteredEvents = _allEvents
          .where((event) =>
              event.title?.toLowerCase().contains(_searchQuery) ?? false)
          .toList();
    }
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

 // Update the _deleteEvent method in MyEventsScreen
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
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
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
                                  ? 'No events created yet'
                                  : 'No events found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
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
                            return EventCard(
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
}

class EventCard extends StatelessWidget {
  final EventResponse event;
  final VoidCallback onManage;
  final VoidCallback onDelete;

  const EventCard({
    Key? key,
    required this.event,
    required this.onManage,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.photoUrls?.isNotEmpty == true 
        ? event.photoUrls!.first 
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
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
                      child: ElevatedButton(
                        onPressed: event.adminApproved ? null : onManage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: event.adminApproved 
                              ? Colors.grey 
                              : Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          event.adminApproved ? 'Approved' : 'Manage',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}