import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';
import 'package:ecochallenge_mobile/providers/event_provider.dart';
import 'package:ecochallenge_mobile/providers/request_provider.dart';
import 'package:ecochallenge_mobile/providers/event_participant_provider.dart';
import 'package:ecochallenge_mobile/providers/request_participation_provider.dart';
import 'package:ecochallenge_mobile/models/request_participation.dart';

class HistoryItem {
  final String id;
  final String name;
  final DateTime date;
  final DateTime? eventDateTime;
  final bool isParticipant;
  final bool isRequest;
  final bool isRequestParticipation; // New field for request participations
  final bool isCreatedByUser;
  final String status;
  final int? statusId;
  final String? description;
  final double? rewardMoney;
  final int? rewardPoints;
  final String? rejectionReason;

  HistoryItem({
    required this.id,
    required this.name,
    required this.date,
    this.eventDateTime,
    required this.isParticipant,
    required this.isRequest,
    this.isRequestParticipation = false,
    this.isCreatedByUser = false,
    this.status = "Ended",
    this.statusId,
    this.description,
    this.rewardMoney,
    this.rewardPoints,
    this.rejectionReason,
  });
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _dateController = TextEditingController();
  String _filterType = 'all'; // 'all', 'events', 'requests', 'participations'
  bool _isLoading = true;
  List<HistoryItem> _allHistoryItems = [];
  List<HistoryItem> _filteredHistoryItems = [];

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int _totalPages = 1;

  DateTime? _selectedDate;

  // Debug info (consider removing in production)
  String _debugInfo = "";
  bool _showDebugInfo = false; // Toggle for production

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      if (_showDebugInfo) _debugInfo = "Starting to load history data...\n";
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUserId;

      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Current User ID: $currentUserId\n";
        });
      }

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(
        context,
        listen: false,
      );
      final participantProvider = Provider.of<EventParticipantProvider>(
        context,
        listen: false,
      );
      final requestParticipationProvider =
          Provider.of<RequestParticipationProvider>(context, listen: false);

      List<HistoryItem> historyItems = [];
      final now = DateTime.now();

      // STEP 1: Get user's event participations
      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Fetching user event participations...\n";
        });
      }

      final participations = await participantProvider.getUserParticipations(
        currentUserId,
      );

      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Found ${participations.length} event participations\n";
        });
      }

      // STEP 2: Get ALL events first, then filter
      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Fetching all events...\n";
        });
      }

      final allEventsResult = await eventProvider.get(
        filter: {'retrieveAll': true, 'pageSize': 1000},
      );

      final allEvents = allEventsResult.items ?? [];
      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Found ${allEvents.length} total events\n";
        });
      }

      // STEP 3: Process participated events that have passed
      for (final participation in participations) {
        try {
          final matchingEvent = allEvents.firstWhere(
            (event) => event.id == participation.eventId,
          );

          // Get event date and time
          DateTime? eventDateTime = _getEventDateTime(matchingEvent);

          if (_showDebugInfo) {
            setState(() {
              _debugInfo +=
                  "Participated Event ${matchingEvent.id}: '${matchingEvent.title}' - DateTime: $eventDateTime\n";
            });
          }

          // Only include events that have passed (date/time is before now)
          if (eventDateTime != null && eventDateTime.isBefore(now)) {
            historyItems.add(
              HistoryItem(
                id: 'event_participation_${matchingEvent.id}',
                name: matchingEvent.title ?? 'Unnamed Event',
                date: eventDateTime,
                eventDateTime: eventDateTime,
                isParticipant: true,
                isRequest: false,
                isRequestParticipation: false,
                isCreatedByUser: false,
                status: 'Participated',
                statusId: matchingEvent.statusId,
                description: matchingEvent.description,
              ),
            );
          }
        } catch (e) {
          if (_showDebugInfo) {
            setState(() {
              _debugInfo +=
                  "Could not find event with ID: ${participation.eventId} - Error: $e\n";
            });
          }
        }
      }

      // STEP 4: Get user-created events that have passed
      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Fetching user-created events...\n";
        });
      }

      final userCreatedEventsResult = await eventProvider.get(
        filter: {
          'createdBy': currentUserId,
          'retrieveAll': true,
          'pageSize': 1000,
        },
      );

      final userCreatedEvents = userCreatedEventsResult.items ?? [];
      if (_showDebugInfo) {
        setState(() {
          _debugInfo +=
              "Found ${userCreatedEvents.length} user-created events\n";
        });
      }

      // Add user-created events that have passed
      for (final event in userCreatedEvents) {
        DateTime? eventDateTime = _getEventDateTime(event);

        if (_showDebugInfo) {
          setState(() {
            _debugInfo +=
                "Created Event ${event.id}: '${event.title}' - DateTime: $eventDateTime\n";
          });
        }

        // Include events that have passed (date/time is before now)
        if (eventDateTime != null && eventDateTime.isBefore(now)) {
          // Check if this event is already in history items (from participation)
          bool alreadyIncluded = historyItems.any(
            (item) => item.id == 'event_participation_${event.id}',
          );

          if (!alreadyIncluded) {
            historyItems.add(
              HistoryItem(
                id: 'event_created_${event.id}',
                name: event.title ?? 'Unnamed Event',
                date: eventDateTime,
                eventDateTime: eventDateTime,
                isParticipant: false,
                isRequest: false,
                isRequestParticipation: false,
                isCreatedByUser: true,
                status: 'Created',
                statusId: event.statusId,
                description: event.description,
              ),
            );
          } else {
            // Update the existing item to show both created and participated
            final existingIndex = historyItems.indexWhere(
              (item) => item.id == 'event_participation_${event.id}',
            );
            if (existingIndex != -1) {
              final existingItem = historyItems[existingIndex];
              historyItems[existingIndex] = HistoryItem(
                id: existingItem.id,
                name: existingItem.name,
                date: existingItem.date,
                eventDateTime: existingItem.eventDateTime,
                isParticipant: true,
                isRequest: false,
                isRequestParticipation: false,
                isCreatedByUser: true, // Both created and participated
                status: 'Created & Participated',
                statusId: existingItem.statusId,
                description: existingItem.description,
              );
            }
          }
        }
      }

      // STEP 5: Get user's request participations (approved/rejected)
      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Fetching user request participations...\n";
        });
      }

      final requestParticipationSearchObject = RequestParticipationSearchObject(
        userId: currentUserId,
        retrieveAll: true,
        pageSize: 1000,
      );

      final requestParticipationsResult = await requestParticipationProvider
          .get(filter: requestParticipationSearchObject.toJson());

      if (requestParticipationsResult.items != null) {
        if (_showDebugInfo) {
          setState(() {
            _debugInfo +=
                "Found ${requestParticipationsResult.items!.length} request participations\n";
          });
        }

        // Get all requests to get details
        final allRequestsResult = await requestProvider.get(
          filter: {'retrieveAll': true, 'pageSize': 1000},
        );
        final allRequests = allRequestsResult.items ?? [];

        for (final requestParticipation in requestParticipationsResult.items!) {
          if (_showDebugInfo) {
            setState(() {
              _debugInfo +=
                  "Request Participation ${requestParticipation.id}: Status: ${requestParticipation.status.displayName}\n";
            });
          }

          // Only include approved or rejected participations
          if (requestParticipation.status == ParticipationStatus.approved ||
              requestParticipation.status == ParticipationStatus.rejected) {
            try {
              final matchingRequest = allRequests.firstWhere(
                (request) => request.id == requestParticipation.requestId,
              );

              historyItems.add(
                HistoryItem(
                  id: 'request_participation_${requestParticipation.id}',
                  name: matchingRequest.title ?? 'Unnamed Request',
                  date:
                      requestParticipation.approvedAt ??
                      requestParticipation.submittedAt,
                  isParticipant: true,
                  isRequest: false,
                  isRequestParticipation: true,
                  isCreatedByUser: false,
                  status: requestParticipation.status.displayName,
                  statusId: requestParticipation.status.index,
                  description: matchingRequest.description,
                  rewardMoney: requestParticipation.rewardMoney,
                  rewardPoints: requestParticipation.rewardPoints,
                  rejectionReason: requestParticipation.rejectionReason,
                ),
              );
            } catch (e) {
              if (_showDebugInfo) {
                setState(() {
                  _debugInfo +=
                      "Could not find request with ID: ${requestParticipation.requestId} - Error: $e\n";
                });
              }
            }
          }
        }
      }

      // STEP 6: Get user-created requests (that have participations - approved/rejected)
      if (_showDebugInfo) {
        setState(() {
          _debugInfo += "Fetching user-created requests...\n";
        });
      }

      final userCreatedRequestsResult = await requestProvider.get(
        filter: {
          'createdBy': currentUserId,
          'retrieveAll': true,
          'pageSize': 1000,
        },
      );

      final userCreatedRequests = userCreatedRequestsResult.items ?? [];
      if (_showDebugInfo) {
        setState(() {
          _debugInfo +=
              "Found ${userCreatedRequests.length} user-created requests\n";
        });
      }

      // For each user-created request, get participations that are approved/rejected
      for (final request in userCreatedRequests) {
        final requestParticipationSearchForRequest =
            RequestParticipationSearchObject(
              requestId: request.id,
              retrieveAll: true,
              pageSize: 1000,
            );

        try {
          final participationsForRequest = await requestParticipationProvider
              .get(filter: requestParticipationSearchForRequest.toJson());

          if (participationsForRequest.items != null) {
            final completedParticipations = participationsForRequest.items!
                .where(
                  (p) =>
                      p.status == ParticipationStatus.approved ||
                      p.status == ParticipationStatus.rejected,
                )
                .toList();

            if (completedParticipations.isNotEmpty) {
              // Add one item representing the request with completed participations
              historyItems.add(
                HistoryItem(
                  id: 'request_created_${request.id}',
                  name: request.title ?? 'Unnamed Request',
                  date: request.createdAt,
                  isParticipant: false,
                  isRequest: true,
                  isRequestParticipation: false,
                  isCreatedByUser: true,
                  status:
                      'Request Created (${completedParticipations.length} responses)',
                  statusId: request.statusId,
                  description: request.description,
                ),
              );
            }
          }
        } catch (e) {
          if (_showDebugInfo) {
            setState(() {
              _debugInfo +=
                  "Error getting participations for request ${request.id}: $e\n";
            });
          }
        }
      }

      // Sort by date (most recent first)
      historyItems.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _allHistoryItems = historyItems;
          if (_showDebugInfo)
            _debugInfo += "Total history items: ${historyItems.length}\n";
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading history data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_showDebugInfo) _debugInfo += "ERROR: $e\n";
        });

        _showErrorSnackBar('Error loading history: $e');
      }
    }
  }

  // Helper method to get event date and time
  DateTime? _getEventDateTime(dynamic event) {
    if (event.eventDate == null) return null;

    if (event.eventTime != null) {
      // Combine date and time
      return _combineDateTime(event.eventDate!, event.eventTime!);
    } else {
      // If no time specified, use end of day for comparison
      return DateTime(
        event.eventDate!.year,
        event.eventDate!.month,
        event.eventDate!.day,
        23,
        59,
        59,
      );
    }
  }

  // Helper method to combine date and time string
  DateTime? _combineDateTime(DateTime date, String timeString) {
    try {
      // Parse time string (assuming format like "14:30" or "2:30 PM")
      final timeFormat = RegExp(
        r'^(\d{1,2}):(\d{2})(?:\s*(AM|PM))?$',
        caseSensitive: false,
      );
      final match = timeFormat.firstMatch(timeString.trim());

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        String? period = match.group(3)?.toUpperCase();

        // Handle 12-hour format
        if (period != null) {
          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }
        }

        return DateTime(date.year, date.month, date.day, hour, minute);
      }

      // Try alternative parsing with DateFormat
      final timeFormatter = DateFormat.Hm(); // HH:mm format
      final parsedTime = timeFormatter.parse(timeString);
      return DateTime(
        date.year,
        date.month,
        date.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      print('Error parsing time: $timeString - $e');
      return null;
    }
  }

  void _applyFilters() {
    List<HistoryItem> filtered = List.from(_allHistoryItems);

    // Apply date filter
    if (_selectedDate != null) {
      filtered = filtered.where((item) {
        return DateUtils.isSameDay(item.date, _selectedDate);
      }).toList();
    }

    // Apply type filter
    switch (_filterType) {
      case 'events':
        filtered = filtered
            .where((item) => !item.isRequest && !item.isRequestParticipation)
            .toList();
        break;
      case 'requests':
        filtered = filtered.where((item) => item.isRequest).toList();
        break;
      case 'participations':
        filtered = filtered
            .where((item) => item.isRequestParticipation)
            .toList();
        break;
      // 'all' shows everything
    }

    setState(() {
      _filteredHistoryItems = filtered;
      _totalPages = (_filteredHistoryItems.length / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;
      if (_currentPage > _totalPages) _currentPage = 1;
    });
  }

  List<HistoryItem> _getCurrentPageItems() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= _filteredHistoryItems.length) {
      return [];
    }

    return _filteredHistoryItems.sublist(
      startIndex,
      endIndex > _filteredHistoryItems.length
          ? _filteredHistoryItems.length
          : endIndex,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
        _applyFilters();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
      _applyFilters();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: goldenBrown,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          if (_showDebugInfo)
            IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Debug Info'),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: SingleChildScrollView(
                        child: Text(
                          _debugInfo,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Color(0xFFD2691E),
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),

                  // Date filter
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: InputDecoration(
                            hintText: 'MM/DD/YYYY',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFD2691E)),
                            ),
                            suffixIcon: _selectedDate != null
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: _clearDateFilter,
                                  )
                                : Icon(Icons.calendar_today),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Type filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        SizedBox(width: 8),
                        _buildFilterChip('Events', 'events'),
                        SizedBox(width: 8),
                        _buildFilterChip('My Requests', 'requests'),
                        SizedBox(width: 8),
                        _buildFilterChip('Request Responses', 'participations'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD2691E),
                      ),
                    )
                  : _filteredHistoryItems.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _getCurrentPageItems().length,
                            itemBuilder: (context, index) {
                              final item = _getCurrentPageItems()[index];
                              return _buildHistoryCard(item);
                            },
                          ),
                        ),

                        // Pagination
                        if (_totalPages > 1) _buildPagination(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
          _applyFilters();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? forestGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? forestGreen : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_filterType) {
      case 'events':
        message = 'No past events found';
        break;
      case 'requests':
        message = 'No completed requests found';
        break;
      case 'participations':
        message = 'No request responses found';
        break;
      default:
        message = 'No history found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your completed activities will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (_showDebugInfo) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Debug Info'),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: SingleChildScrollView(
                        child: Text(
                          _debugInfo,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD2691E),
                foregroundColor: Colors.white,
              ),
              child: Text('Show Debug Info'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Activity Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(item),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(item),
                    color: _getIconColor(item),
                    size: 24,
                  ),
                ),

                SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildActivityBadge(item),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    DateFormat('MMM d, yyyy').format(item.date),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 8),

                          // Status Badge
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
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

            // Additional info for request participations
            if (item.isRequestParticipation) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.rewardMoney != null && item.rewardMoney! > 0) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Reward: ${item.rewardMoney!.toStringAsFixed(2)} KM',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.rewardPoints != null &&
                        item.rewardPoints! > 0) ...[
                      if (item.rewardMoney != null && item.rewardMoney! > 0)
                        SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stars, size: 16, color: Colors.orange),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Points: ${item.rewardPoints}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.rejectionReason != null &&
                        item.rejectionReason!.isNotEmpty) ...[
                      if ((item.rewardMoney != null && item.rewardMoney! > 0) ||
                          (item.rewardPoints != null && item.rewardPoints! > 0))
                        SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Reason: ${item.rejectionReason}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Description (if available)
            if (item.description != null && item.description!.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                item.description!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBadge(HistoryItem item) {
    if (item.isRequestParticipation) {
      return Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFFE8F5E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.task_alt, size: 16, color: Color(0xFF4CAF50)),
      );
    } else if (item.isRequest && item.isCreatedByUser) {
      return Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.create, size: 16, color: Color(0xFFFF9800)),
      );
    } else if (item.isParticipant && item.isCreatedByUser) {
      return Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFFE1F5FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.group_work, size: 16, color: Color(0xFF0277BD)),
      );
    } else if (item.isParticipant) {
      return Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.people, size: 16, color: Color(0xFF1976D2)),
      );
    } else if (item.isCreatedByUser) {
      return Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.create, size: 16, color: Color(0xFFFF9800)),
      );
    }
    return SizedBox.shrink();
  }

  IconData _getActivityIcon(HistoryItem item) {
    if (item.isRequestParticipation) {
      return item.status.toLowerCase() == 'approved'
          ? Icons.check_circle
          : Icons.cancel;
    } else if (item.isRequest) {
      return Icons.cleaning_services;
    } else {
      return Icons.event;
    }
  }

  Color _getIconBackgroundColor(HistoryItem item) {
    if (item.isRequestParticipation) {
      return item.status.toLowerCase() == 'approved'
          ? Color(0xFFE8F5E8)
          : Color(0xFFFFEBEE);
    } else if (item.isRequest) {
      return Color(0xFFE8F5E8);
    } else {
      return Color(0xFFE3F2FD);
    }
  }

  Color _getIconColor(HistoryItem item) {
    if (item.isRequestParticipation) {
      return item.status.toLowerCase() == 'approved'
          ? Color(0xFF4CAF50)
          : Color(0xFFF44336);
    } else if (item.isRequest) {
      return Color(0xFF4CAF50);
    } else {
      return Color(0xFF2196F3);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return forestGreen;
      case 'rejected':
        return Color(0xFFF44336);
      case 'participated':
        return Color(0xFF2196F3);
      case 'created':
        return goldenBrown;
      case 'created & participated':
        return oliveGreen;
      default:
        if (status.contains('responses')) {
          return oliveGreen;
        }
        return oliveGreen;
    }
  }

  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $_currentPage of $_totalPages',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous button
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
                icon: Icon(Icons.chevron_left),
                color: Color(0xFFD2691E),
              ),

              // Page numbers (simplified for mobile)
              ...List.generate(_totalPages > 3 ? 3 : _totalPages, (index) {
                int pageNumber;
                if (_totalPages <= 3) {
                  pageNumber = index + 1;
                } else {
                  if (_currentPage <= 2) {
                    pageNumber = index + 1;
                  } else if (_currentPage >= _totalPages - 1) {
                    pageNumber = _totalPages - 2 + index;
                  } else {
                    pageNumber = _currentPage - 1 + index;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentPage = pageNumber;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _currentPage == pageNumber
                          ? forestGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: _currentPage == pageNumber
                            ? forestGreen
                            : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pageNumber.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: _currentPage == pageNumber
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: _currentPage == pageNumber
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),

              // Next button
              IconButton(
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
                icon: Icon(Icons.chevron_right),
                color: Color(0xFFD2691E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
