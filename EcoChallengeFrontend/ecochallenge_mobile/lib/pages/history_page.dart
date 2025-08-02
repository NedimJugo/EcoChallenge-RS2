import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';
import 'package:ecochallenge_mobile/providers/event_provider.dart';
import 'package:ecochallenge_mobile/providers/request_provider.dart';
import 'package:ecochallenge_mobile/providers/event_participant_provider.dart';

class HistoryItem {
  final String id;
  final String name;
  final DateTime date;
  final bool isParticipant;
  final bool isRequest;
  final String status;
  final int? statusId; // Add this for debugging

  HistoryItem({
    required this.id,
    required this.name,
    required this.date,
    required this.isParticipant,
    required this.isRequest,
    this.status = "Ended",
    this.statusId,
  });
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _dateController = TextEditingController();
  bool _requestsOnly = false;
  bool _isLoading = true;
  List<HistoryItem> _allHistoryItems = [];
  List<HistoryItem> _filteredHistoryItems = [];
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int _totalPages = 1;

  DateTime? _selectedDate;

  // Debug info
  String _debugInfo = "";

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
    setState(() {
      _isLoading = true;
      _debugInfo = "Starting to load history data...\n";
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUserId;
      
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      setState(() {
        _debugInfo += "Current User ID: $currentUserId\n";
      });

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      final participantProvider = Provider.of<EventParticipantProvider>(context, listen: false);

      List<HistoryItem> historyItems = [];

      // STEP 1: Get user's participations
      setState(() {
        _debugInfo += "Fetching user participations...\n";
      });
      
      final participations = await participantProvider.getUserParticipations(currentUserId);
      
      setState(() {
        _debugInfo += "Found ${participations.length} participations\n";
      });

      // STEP 2: Get ALL events first, then filter
      setState(() {
        _debugInfo += "Fetching all events...\n";
      });

      final allEventsResult = await eventProvider.get(filter: {
        'retrieveAll': true,
        'pageSize': 1000, // Get a large number
      });

      final allEvents = allEventsResult.items ?? [];
      setState(() {
        _debugInfo += "Found ${allEvents.length} total events\n";
      });

      // STEP 3: Match participations with events
      for (final participation in participations) {
  // Use where().firstOrNull or try-catch approach
  final matchingEvents = allEvents.where((event) => event.id == participation.eventId);
  final matchingEvent = matchingEvents.isNotEmpty ? matchingEvents.first : null;

  if (matchingEvent != null) {
    setState(() {
      _debugInfo += "Event ${matchingEvent.id}: '${matchingEvent.title}' - Status: ${matchingEvent.statusId}\n";
    });

    // Add ALL participated events for now (we'll filter by status later)
    historyItems.add(HistoryItem(
      id: 'event_${matchingEvent.id}',
      name: matchingEvent.title ?? 'Unnamed Event',
      date: matchingEvent.eventDate,
      isParticipant: true,
      isRequest: false,
      statusId: matchingEvent.statusId,
    ));
  } else {
    setState(() {
      _debugInfo += "Could not find event with ID: ${participation.eventId}\n";
    });
  }
}

      // STEP 4: Get user's requests
      setState(() {
        _debugInfo += "Fetching user requests...\n";
      });

      final requestSearchResult = await requestProvider.get(filter: {
        'userId': currentUserId,
        'retrieveAll': true,
        'pageSize': 1000,
      });

      if (requestSearchResult.items != null) {
        setState(() {
          _debugInfo += "Found ${requestSearchResult.items!.length} requests\n";
        });

        for (final request in requestSearchResult.items!) {
          setState(() {
            _debugInfo += "Request ${request.id}: '${request.title}' - Status: ${request.statusId}\n";
          });

          // Add ALL requests for now
          historyItems.add(HistoryItem(
            id: 'request_${request.id}',
            name: request.title ?? 'Unnamed Request',
            date: request.completedAt ?? request.createdAt,
            isParticipant: false,
            isRequest: true,
            statusId: request.statusId,
          ));
        }
      }

      // Sort by date (most recent first)
      historyItems.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _allHistoryItems = historyItems;
        _debugInfo += "Total history items: ${historyItems.length}\n";
        _applyFilters();
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading history data: $e');
      setState(() {
        _isLoading = false;
        _debugInfo += "ERROR: $e\n";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading history: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

    // Apply requests only filter
    if (_requestsOnly) {
      filtered = filtered.where((item) => item.isRequest).toList();
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
      endIndex > _filteredHistoryItems.length ? _filteredHistoryItems.length : endIndex,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFD2691E),
        elevation: 0,
        centerTitle: true,
        actions: [
          // Debug button
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Debug Info'),
                  content: SingleChildScrollView(
                    child: Text(_debugInfo),
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
      body: Column(
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _requestsOnly,
                          onChanged: (value) {
                            setState(() {
                              _requestsOnly = value ?? false;
                              _applyFilters();
                            });
                          },
                          activeColor: Color(0xFFD2691E),
                        ),
                        Text(
                          'Requests only',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFD2691E)))
                : _filteredHistoryItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No history found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your completed activities will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Debug Info'),
                                    content: SingleChildScrollView(
                                      child: Text(_debugInfo),
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
                              child: Text('Show Debug Info'),
                            ),
                          ],
                        ),
                      )
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
        child: Row(
          children: [
            // Activity Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.isRequest ? Icons.cleaning_services : Icons.event,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            
            SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
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
                        ),
                      ),
                      if (item.isParticipant && !item.isRequest)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.people,
                            size: 16,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Text(
                        'Date: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormat('d.M.yyyy').format(item.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      Spacer(),
                      
                      // Status Badge with debug info
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.status} (${item.statusId})',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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

  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          if (_currentPage > 1)
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentPage--;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '<',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          
          // Page numbers
          ...List.generate(
            _totalPages > 5 ? 5 : _totalPages,
            (index) {
              int pageNumber;
              if (_totalPages <= 5) {
                pageNumber = index + 1;
              } else {
                if (_currentPage <= 3) {
                  pageNumber = index + 1;
                } else if (_currentPage >= _totalPages - 2) {
                  pageNumber = _totalPages - 4 + index;
                } else {
                  pageNumber = _currentPage - 2 + index;
                }
              }
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentPage = pageNumber;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == pageNumber ? Color(0xFFD2691E) : Colors.transparent,
                    border: Border.all(
                      color: _currentPage == pageNumber ? Color(0xFFD2691E) : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pageNumber.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _currentPage == pageNumber ? Colors.white : Colors.grey[700],
                      fontWeight: _currentPage == pageNumber ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Next button
          if (_currentPage < _totalPages)
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentPage++;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '>',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}