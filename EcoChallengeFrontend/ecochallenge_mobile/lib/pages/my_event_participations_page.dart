import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_mobile/models/event.dart';
import 'package:ecochallenge_mobile/models/event_participant.dart';
import 'package:ecochallenge_mobile/providers/event_provider.dart';
import 'package:ecochallenge_mobile/providers/event_participant_provider.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';

class EventParticipationsScreen extends StatefulWidget {
  const EventParticipationsScreen({Key? key}) : super(key: key);

  @override
  State<EventParticipationsScreen> createState() => _EventParticipationsScreenState();
}

class _EventParticipationsScreenState extends State<EventParticipationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<EventParticipationData> _allParticipations = [];
  List<EventParticipationData> _filteredParticipations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'upcoming'; // 'upcoming', 'all'

  @override
  void initState() {
    super.initState();
    _loadParticipations();
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
      _filterParticipations();
    });
  }

  void _filterParticipations() {
    List<EventParticipationData> filteredByTime = [];
    
    if (_selectedFilter == 'upcoming') {
      // Only show events that haven't passed
      final now = DateTime.now();
      filteredByTime = _allParticipations.where((participation) {
        final eventDateTime = _combineDateTime(
          participation.event.eventDate, 
          participation.event.eventTime
        );
        return eventDateTime.isAfter(now);
      }).toList();
    } else {
      filteredByTime = List.from(_allParticipations);
    }

    if (_searchQuery.isEmpty) {
      _filteredParticipations = filteredByTime;
    } else {
      _filteredParticipations = filteredByTime
          .where((participation) =>
              (participation.event.title?.toLowerCase().contains(_searchQuery) ?? false) ||
              (participation.event.description?.toLowerCase().contains(_searchQuery) ?? false))
          .toList();
    }

    // Sort by event date (ascending - nearest first)
    _filteredParticipations.sort((a, b) {
      final aDateTime = _combineDateTime(a.event.eventDate, a.event.eventTime);
      final bDateTime = _combineDateTime(b.event.eventDate, b.event.eventTime);
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

  Future<void> _loadParticipations() async {
    try {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final participantProvider = Provider.of<EventParticipantProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      
      if (authProvider.currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Get user's participations
      final participations = await participantProvider.getUserParticipations(
        authProvider.currentUserId!
      );

      // Get events for each participation
      List<EventParticipationData> participationData = [];
      
      for (final participation in participations) {
        try {
          final eventResult = await eventProvider.getById(participation.eventId);
          if (eventResult != null) {
            participationData.add(EventParticipationData(
              participation: participation,
              event: eventResult,
            ));
          }
        } catch (e) {
          print('Failed to load event ${participation.eventId}: $e');
          // Skip this participation if event can't be loaded
        }
      }
      
      setState(() {
        _allParticipations = participationData;
        _filterParticipations();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading participations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveEvent(EventParticipationData participationData) async {
    final eventDateTime = _combineDateTime(
      participationData.event.eventDate, 
      participationData.event.eventTime
    );
    
    if (eventDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot leave a past event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Event'),
        content: Text('Are you sure you want to leave "${participationData.event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final participantProvider = Provider.of<EventParticipantProvider>(context, listen: false);
        final success = await participantProvider.removeParticipant(
          participationData.participation.id
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully left the event'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Remove from local list
          setState(() {
            _allParticipations.removeWhere((p) => 
              p.participation.id == participationData.participation.id);
            _filterParticipations();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error leaving event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEventDetails(EventParticipationData participationData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsModal(
        participationData: participationData,
        onLeave: () {
          Navigator.of(context).pop();
          _leaveEvent(participationData);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Participations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: goldenBrown,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    hintText: 'Search participated events...',
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
                        color: forestGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${_filteredParticipations.length} events',
                        style: TextStyle(
                          color: Colors.white,
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
          
          // Participations List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredParticipations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_seat,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? (_selectedFilter == 'upcoming' 
                                      ? 'No upcoming participations'
                                      : 'No participations yet')
                                  : 'No participations found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join events to see them here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadParticipations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredParticipations.length,
                          itemBuilder: (context, index) {
                            final participationData = _filteredParticipations[index];
                            return ParticipationEventCard(
                              participationData: participationData,
                              onLeave: () => _leaveEvent(participationData),
                              onViewDetails: () => _showEventDetails(participationData),
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
          _filterParticipations();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? forestGreen : Colors.grey[200],
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

// Data class to hold participation and event data together
class EventParticipationData {
  final EventParticipantResponse participation;
  final EventResponse event;

  EventParticipationData({
    required this.participation,
    required this.event,
  });
}

class ParticipationEventCard extends StatelessWidget {
  final EventParticipationData participationData;
  final VoidCallback onLeave;
  final VoidCallback onViewDetails;

  const ParticipationEventCard({
    Key? key,
    required this.participationData,
    required this.onLeave,
    required this.onViewDetails,
  }) : super(key: key);

  DateTime get eventDateTime {
    final timeParts = participationData.event.eventTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(
      participationData.event.eventDate.year,
      participationData.event.eventDate.month,
      participationData.event.eventDate.day,
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
      return 'Event completed';
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

  Color get statusColor {
    switch (participationData.participation.status) {
      case AttendanceStatus.registered:
        return forestGreen;
      case AttendanceStatus.attended:
        return Colors.orange;
      case AttendanceStatus.completed:
        return Colors.green;
      case AttendanceStatus.cancelled:
        return Colors.red;
      case AttendanceStatus.noShow:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = participationData.event;
    final participation = participationData.participation;
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
                    height: 140,
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
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : const Icon(
                            Icons.event,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                  
                  // Participation Status Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        participation.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  
                  // Points earned badge
                  if (participation.pointsEarned > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${participation.pointsEarned}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                            fontSize: 16,
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
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.currentParticipants}/${event.maxParticipants}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date, Time and Joined Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.eventTime.substring(0, 5), // HH:MM
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Joined date
                  Row(
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Joined: ${participation.joinedAt.day}/${participation.joinedAt.month}/${participation.joinedAt.year}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
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
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // View Details Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.visibility, size: 14),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: forestGreen,
                            side: BorderSide(color: forestGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Leave Event Button
                      if (!isPastEvent && 
                          participation.status != AttendanceStatus.cancelled)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onLeave,
                            icon: const Icon(Icons.exit_to_app, size: 14),
                            label: const Text('Leave'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isPastEvent ? 'Completed' : 'Cancelled',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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

class EventDetailsModal extends StatelessWidget {
  final EventParticipationData participationData;
  final VoidCallback onLeave;

  const EventDetailsModal({
    Key? key,
    required this.participationData,
    required this.onLeave,
  }) : super(key: key);

  DateTime get eventDateTime {
    final timeParts = participationData.event.eventTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(
      participationData.event.eventDate.year,
      participationData.event.eventDate.month,
      participationData.event.eventDate.day,
      hour,
      minute,
    );
  }

  bool get isPastEvent {
    return eventDateTime.isBefore(DateTime.now());
  }

  Color get statusColor {
    switch (participationData.participation.status) {
      case AttendanceStatus.registered:
        return forestGreen;
      case AttendanceStatus.attended:
        return Colors.orange;
      case AttendanceStatus.completed:
        return Colors.green;
      case AttendanceStatus.cancelled:
        return Colors.red;
      case AttendanceStatus.noShow:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = participationData.event;
    final participation = participationData.participation;
    final imageUrl = event.photoUrls?.isNotEmpty == true 
        ? event.photoUrls!.first 
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Event Image
          if (imageUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.event,
                size: 64,
                color: Colors.grey,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Event Title
          Text(
            event.title ?? 'Untitled Event',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Status and Participants
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  participation.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${event.currentParticipants}/${event.maxParticipants}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Event Details
          const Text(
            'Event Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Date and Time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          

          
          // Description
          if (event.description != null && event.description!.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description!,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
          
          // Participation Details
          const Text(
            'Your Participation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(Icons.person_add, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Joined: ${participation.joinedAt.day}/${participation.joinedAt.month}/${participation.joinedAt.year}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          
          if (participation.pointsEarned > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.stars, size: 16, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  'Points earned: ${participation.pointsEarned}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Action Buttons
          if (!isPastEvent && participation.status != AttendanceStatus.cancelled)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onLeave();
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Leave Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPastEvent ? 'Event Completed' : 'Participation Cancelled',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}