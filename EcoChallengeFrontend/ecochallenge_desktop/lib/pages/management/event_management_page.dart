import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/event.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/providers/event_provider.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';


class EventManagementPage extends StatefulWidget {
  const EventManagementPage({Key? key}) : super(key: key);

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final EventProvider _eventProvider = EventProvider();
  final UserProvider _userProvider = UserProvider();
  
  List<EventResponse> _events = [];
  Map<int, UserResponse> _usersCache = {}; // Cache for user data
  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  
  // Filter controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();
  int? _selectedStatus;
  int? _selectedEventType;

  
  // Scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    try {
      final searchObject = EventSearchObject(
        page: _currentPage,
        pageSize: _pageSize,
        text: _titleController.text.isEmpty ? null : _titleController.text,
        status: _selectedStatus,
        type: _selectedEventType,
        creatorUserId: _creatorController.text.isEmpty ? null : int.tryParse(_creatorController.text),
      );

      final result = await _eventProvider.get(filter: searchObject.toJson());
      
      setState(() {
        _events = result.items ?? [];
        _totalCount = result.totalCount ?? 0;
      });

      // Load user data for creators
      await _loadCreatorData();
    } catch (e) {
      _showErrorSnackBar('Failed to load events: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCreatorData() async {
    final creatorIds = _events
        .map((event) => event.creatorUserId)
        .where((id) => !_usersCache.containsKey(id))
        .toSet();

    for (final creatorId in creatorIds) {
      try {
        final user = await _userProvider.getById(creatorId);
        _usersCache[creatorId] = user;
      } catch (e) {
        print('Failed to load user $creatorId: $e');
        // Continue loading other users even if one fails
      }
    }
    
    if (mounted) {
      setState(() {}); // Refresh UI with loaded user data
    }
  }

  String _getCreatorDisplayName(int creatorId) {
    final user = _usersCache[creatorId];
    if (user != null) {
      return '${user.firstName} ${user.lastName} (${user.username})';
    }
    return 'ID: $creatorId';
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

Future<void> _deleteEvent(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the event "$name"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _eventProvider.delete(id);
        _showSuccessSnackBar('Event deleted successfully');
        _loadEvents();
      } catch (e) {
        String errorMessage = 'You cannot delete this event because it is used by existing participants';

        // Check for specific error types
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('reference constraint') || 
            errorString.contains('foreign key') ||
            errorString.contains('being used')) {
          errorMessage = 'Cannot delete "$name" because it is currently being used by existing users. Please reassign or remove those users first.';
        } else if (errorString.contains('invalidoperationexception')) {
          // Extract the custom message from the exception
          final match = RegExp(r"Cannot delete user type.*").firstMatch(e.toString());
          if (match != null) {
            errorMessage = match.group(0) ?? errorMessage;
          }
        }
        
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _titleController.clear();
      _creatorController.clear();
      _selectedStatus = null;
      _selectedEventType = null;
      _currentPage = 0;
    });
    _loadEvents();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.event, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () {
                          _currentPage = 0;
                          _loadEvents();
                        },
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Search', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: oliveGreen[500],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _clearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    Text('Total: $_totalCount events', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          
          // Data Table with dual scrolling
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading events...'),
                      ],
                    ),
                  )
                : _events.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your search filters or create a new event',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                            scrollbars: false,
                          ),
                          child: RawScrollbar(
                            controller: _verticalScrollController,
                            thumbVisibility: true,
                            thickness: 12,
                            radius: const Radius.circular(6),
                            thumbColor: Colors.grey[400],
                            child: SingleChildScrollView(
                              controller: _verticalScrollController,
                              scrollDirection: Axis.vertical,
                              child: RawScrollbar(
                                controller: _horizontalScrollController,
                                thumbVisibility: true,
                                thickness: 12,
                                radius: const Radius.circular(6),
                                thumbColor: Colors.grey[400],
                                child: SingleChildScrollView(
                                  controller: _horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: MediaQuery.of(context).size.width - 16,
                                    ),
                                    child: DataTable(
                                      columnSpacing: 16,
                                      horizontalMargin: 12,
                                      dataRowHeight: 48,
                                      headingRowHeight: 40,
                                      dataTextStyle: const TextStyle(fontSize: 12),
                                      headingTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      columns: const [
                                        DataColumn(label: Text('ID')),
                                        DataColumn(label: Text('Title')),
                                        DataColumn(label: Text('Creator')),
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('Time')),
                                        DataColumn(label: Text('Participants')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Approved')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows: _events.map((event) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(event.id.toString())),
                                            DataCell(
                                              SizedBox(
                                                width: 200,
                                                child: Tooltip(
                                                  message: event.title ?? 'N/A',
                                                  child: Text(
                                                    event.title ?? 'N/A',
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              SizedBox(
                                                width: 180,
                                                child: Tooltip(
                                                  message: _getCreatorDisplayName(event.creatorUserId),
                                                  child: Text(
                                                    _getCreatorDisplayName(event.creatorUserId),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: _usersCache.containsKey(event.creatorUserId) 
                                                          ? Colors.black 
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${event.eventDate.day.toString().padLeft(2, '0')}/${event.eventDate.month.toString().padLeft(2, '0')}/${event.eventDate.year}',
                                              ),
                                            ),
                                            DataCell(
                                              Text(event.eventTime.substring(0, 5)), // Show only HH:MM
                                            ),
                                            DataCell(
                                              Text('${event.currentParticipants}/${event.maxParticipants}'),
                                            ),
                                            DataCell(
                                              Chip(
                                                label: Text(
                                                  'Status ${event.statusId}',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                backgroundColor: Colors.orange[100],
                                                labelStyle: TextStyle(color: Colors.orange[800]),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                            DataCell(
                                              Chip(
                                                label: Text(
                                                  event.adminApproved ? 'Yes' : 'No',
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                backgroundColor: event.adminApproved ? Colors.green[100] : Colors.red[100],
                                                labelStyle: TextStyle(color: event.adminApproved ? Colors.green[800] : Colors.red[800]),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(width: 4),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, size: 18),
                                                    color: Colors.red[600],
                                                    onPressed: () => _deleteEvent(event.id, event.title ?? 'Unknown Event'),
                                                    tooltip: 'Delete',
                                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
          
          // Pagination
          if (!_isLoading && _events.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${_currentPage + 1} of ${(_totalCount / _pageSize).ceil()} | Showing ${_events.length} of $_totalCount',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() => _currentPage--);
                                _loadEvents();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left, size: 20),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        tooltip: 'Previous page',
                      ),
                      IconButton(
                        onPressed: (_currentPage + 1) * _pageSize < _totalCount
                            ? () {
                                setState(() => _currentPage++);
                                _loadEvents();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right, size: 20),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        tooltip: 'Next page',
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

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}