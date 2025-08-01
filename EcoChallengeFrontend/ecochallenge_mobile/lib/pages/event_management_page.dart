import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_mobile/models/event.dart';
import 'package:ecochallenge_mobile/models/event_participant.dart';
import 'package:ecochallenge_mobile/models/user.dart';
import 'package:ecochallenge_mobile/providers/event_participant_provider.dart';
import 'package:ecochallenge_mobile/providers/user_provider.dart';

class EventManagementScreen extends StatefulWidget {
  final EventResponse event;

  const EventManagementScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  List<EventParticipantResponse> _participants = [];
  Map<int, UserResponse> _users = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      setState(() => _isLoading = true);
      
      final participantProvider = Provider.of<EventParticipantProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Get participants for this event
      final searchObject = EventParticipantSearchObject(
        eventId: widget.event.id,
        retrieveAll: true,
      );

      final result = await participantProvider.get(
        filter: searchObject.toJson(),
      );

      _participants = result.items ?? [];
      print('DEBUG: Found ${_participants.length} participants for event ${widget.event.id}');

      // Load user details for each participant using GetById
      for (final participant in _participants) {
        try {
          print('DEBUG: Loading user data for userId: ${participant.userId}');
          
          // Use the existing getUserById method from your UserProvider
          final user = await userProvider.getUserById(participant.userId);
          
          if (user != null) {
            _users[participant.userId] = user;
            print('DEBUG: Successfully loaded user: ${user.firstName} ${user.lastName}');
          } else {
            print('DEBUG: No user found for userId: ${participant.userId}');
          }
        } catch (e) {
          print('Error loading user ${participant.userId}: $e');
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading participants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeParticipant(EventParticipantResponse participant) async {
    final user = _users[participant.userId];
    final userName = user != null 
        ? '${user.firstName} ${user.lastName}'
        : 'Unknown User';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Participant'),
        content: Text('Are you sure you want to remove $userName from this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final participantProvider = Provider.of<EventParticipantProvider>(
          context, 
          listen: false,
        );
        
        final success = await participantProvider.removeParticipant(participant.id);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName removed from event'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _participants.removeWhere((p) => p.id == participant.id);
            _users.remove(participant.userId);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing participant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage: ${widget.event.title ?? "Event"}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Event Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title ?? 'Untitled Event',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_participants.length}/${widget.event.maxParticipants} participants',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              widget.event.adminApproved
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 16,
                              color: widget.event.adminApproved
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.event.adminApproved
                                  ? 'Approved'
                                  : 'Pending Approval',
                              style: TextStyle(
                                color: widget.event.adminApproved
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Participants List
                Expanded(
                  child: _participants.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No participants yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _participants.length,
                          itemBuilder: (context, index) {
                            final participant = _participants[index];
                            final user = _users[participant.userId];
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange[100],
                                  child: user?.profileImageUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            user!.profileImageUrl!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Text(
                                                user.firstName.isNotEmpty
                                                    ? user.firstName[0].toUpperCase()
                                                    : '?',
                                                style: TextStyle(
                                                  color: Colors.orange[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Text(
                                          user?.firstName.isNotEmpty == true
                                              ? user!.firstName[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  user != null
                                      ? '${user.firstName} ${user.lastName}'
                                      : 'Loading... (ID: ${participant.userId})',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (user?.email != null)
                                      Text(user!.email),
                                    Text(
                                      'Joined: ${_formatDate(participant.joinedAt)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeParticipant(participant),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
