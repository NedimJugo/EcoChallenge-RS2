import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:ecochallenge_mobile/models/event_participant.dart';
import 'package:ecochallenge_mobile/models/request_participation.dart';
import 'package:ecochallenge_mobile/providers/request_participation_provider.dart';
import 'package:ecochallenge_mobile/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/request.dart';
import '../models/location.dart';
import '../providers/event_provider.dart';
import '../providers/request_provider.dart';
import '../providers/event_participant_provider.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import '../pages/event_detail_page.dart';
import '../pages/request_detail_page.dart';

class EventsListPage extends StatefulWidget {
  final String? initialFilter;
  
  const EventsListPage({Key? key, this.initialFilter}) : super(key: key);

  @override
  _EventsListPageState createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  List<EventResponse> _events = [];
  List<RequestResponse> _requests = [];
  List<LocationResponse> _locations = [];
  Map<int, LocationResponse> _locationMap = {};
  List<String> _cities = [];
  List<int> _userParticipatedEventIds = [];
  List<int> _userParticipatedRequestIds = [];
  bool _isLoading = true;
  bool _hasInitialized = false;
  String _selectedFilter = 'All';
  String? _selectedCity;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _loadData();
        _hasInitialized = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _loadData();
      _hasInitialized = true;
    }
  }

  Future<void> _loadData() async {
  if (!mounted) return;
  
  setState(() => _isLoading = true);
  
  try {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final participantProvider = Provider.of<EventParticipantProvider>(context, listen: false);
    final requestParticipationProvider = Provider.of<RequestParticipationProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Get current user ID
    final userId = authProvider.currentUserId;
    
    // Load locations first
    final locationsResult = await locationProvider.get();
    _locations = locationsResult.items ?? [];
    _locationMap = {for (var location in _locations) location.id: location};
    
    // Extract unique cities from locations
    Set<String> citySet = {};
    for (var location in _locations) {
      if (location.city != null && location.city!.isNotEmpty) {
        citySet.add(location.city!);
      }
    }
    _cities = citySet.toList()..sort();
    
    // Load user's participated events and requests
    if (userId != null) {
      // Load event participations
      final participantSearchObject = EventParticipantSearchObject(
        userId: userId,
        retrieveAll: true,
      );
      final participantsResult = await participantProvider.get(filter: participantSearchObject.toJson());
      _userParticipatedEventIds = participantsResult.items?.map((p) => p.eventId).toList() ?? [];
      
      // Load request participations
      final requestParticipationSearch = RequestParticipationSearchObject(
        userId: userId,
        retrieveAll: true,
      );
      final requestParticipations = await requestParticipationProvider.get(filter: requestParticipationSearch.toJson());
      _userParticipatedRequestIds = requestParticipations.items?.map((p) => p.requestId).toList() ?? [];
    } else {
      _userParticipatedEventIds = [];
      _userParticipatedRequestIds = [];
    }
    
    // Load active events (status = 1)
    final eventSearchObject = EventSearchObject(
      status: 2, // Active status
      retrieveAll: true,
    );
    
    // Load active requests (status = 1)
    final requestSearchObject = RequestSearchObject(
      status: 2, // Active status
      retrieveAll: true,
    );
    
    final eventsResult = await eventProvider.get(filter: eventSearchObject.toJson());
    final requestsResult = await requestProvider.get(filter: requestSearchObject.toJson());
    
    if (mounted) {
      setState(() {
        _events = eventsResult.items ?? [];
        _requests = requestsResult.items ?? [];
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading data: $e');
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }
}

Future<void> _handleRefresh() async {
  await _loadData();
}

List<dynamic> get _filteredItems {
  List<dynamic> allItems = [];
  
  // Filter events - exclude past events and events user has already joined
  List<EventResponse> filteredEvents = _events.where((event) {
    bool isParticipated = _userParticipatedEventIds.contains(event.id);
    bool isPastEvent = event.eventDate.isBefore(DateTime.now());
    
    // Skip events the user has already joined or are past
    if (isParticipated || isPastEvent) {
      return false;
    }
    
    bool matchesFilter = _selectedFilter == 'All' || _selectedFilter == 'Events';
    bool matchesCity = _selectedCity == null || 
        (_locationMap[event.locationId]?.city == _selectedCity);
    bool matchesDate = _selectedDateRange == null ||
        (event.eventDate.isAfter(_selectedDateRange!.start) &&
        event.eventDate.isBefore(_selectedDateRange!.end.add(Duration(days: 1))));
    
    return matchesFilter && matchesCity && matchesDate;
  }).toList();
  
  // Filter requests - exclude requests user has already participated in
  List<RequestResponse> filteredRequests = _requests.where((request) {
    bool isParticipated = _userParticipatedRequestIds.contains(request.id);
    
    // Skip requests the user has already participated in
    if (isParticipated) {
      return false;
    }
    
    bool matchesFilter = _selectedFilter == 'All' || _selectedFilter == 'Requests';
    bool matchesCity = _selectedCity == null || 
        (_locationMap[request.locationId]?.city == _selectedCity);
    bool matchesDate = _selectedDateRange == null ||
        (request.proposedDate != null &&
        request.proposedDate!.isAfter(_selectedDateRange!.start) && 
        request.proposedDate!.isBefore(_selectedDateRange!.end.add(Duration(days: 1))));
    
    return matchesFilter && matchesCity && matchesDate;
  }).toList();
  
  allItems.addAll(filteredEvents);
  allItems.addAll(filteredRequests);
  
  // Sort by date (events and requests with dates)
  allItems.sort((a, b) {
    DateTime? aDate = a is EventResponse ? a.eventDate : (a as RequestResponse).proposedDate;
    DateTime? bDate = b is EventResponse ? b.eventDate : (b as RequestResponse).proposedDate;
    
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  });
  
  return allItems;
}

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedCity = null;
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Available Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: goldenBrown,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          // Add debug info section
          
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildEventsList(),
          ),
        ],
      ),
      bottomNavigationBar: SharedBottomNavigation(currentIndex: 3),
    );
  }


  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: Icon(Icons.clear, size: 16, color: Color(0xFF8B4513)),
                label: Text(
                  'Clear Filters',
                  style: TextStyle(color: Color(0xFF8B4513), fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size(0, 0),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Type',
                  _selectedFilter,
                  ['All', 'Events', 'Requests'],
                  (value) => setState(() => _selectedFilter = value!),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCityDropdown(),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDateFilter(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontSize: 14)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedCity,
              isExpanded: true,
              hint: Text('All cities', style: TextStyle(fontSize: 14)),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All cities', style: TextStyle(fontSize: 14)),
                ),
                ..._cities.map((city) => DropdownMenuItem<String?>(
                  value: city,
                  child: Text(
                    city,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
              ],
              onChanged: (value) => setState(() => _selectedCity = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: _selectDateRange,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateRange == null ? 'All dates' : 'Custom',
                  style: TextStyle(fontSize: 14),
                ),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  Widget _buildEventsList() {
    final items = _filteredItems;
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No new events or requests available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Events you\'ve already joined are hidden',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            if (_selectedFilter != 'All' || _selectedCity != null || _selectedDateRange != null) ...[
              SizedBox(height: 8),
              TextButton(
                onPressed: _clearFilters,
                child: Text('Clear filters to see more results'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Available Events & Requests (${items.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is EventResponse) {
                  return _buildEventCard(item);
                } else if (item is RequestResponse) {
                  return _buildRequestCard(item);
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(EventResponse event) {
    final location = _locationMap[event.locationId];
    final isParticipated = _userParticipatedEventIds.contains(event.id);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToEventDetail(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Add debug indicator
              if (isParticipated)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'DEBUG: This event should be hidden (you are registered)',
                    style: TextStyle(color: Colors.red[800], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: event.photoUrls?.isNotEmpty == true
                          ? Image.network(
                              event.photoUrls!.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.event, size: 40, color: Colors.grey[600]),
                            )
                          : Icon(Icons.event, size: 40, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title ?? 'Untitled Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          event.description ?? 'No description available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location?.city ?? location?.name ?? 'Unknown Location',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(event.eventDate),
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            Spacer(),
                            Icon(Icons.people, size: 16, color: Colors.grey[500]),
                            SizedBox(width: 4),
                            Text(
                              '${event.currentParticipants}/${event.maxParticipants}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isParticipated ? Colors.grey : forestGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(  
                              isParticipated ? 'Joined' : 'Join',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(RequestResponse request) {
    final location = _locationMap[request.locationId];
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToRequestDetail(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: request.photoUrls?.isNotEmpty == true
                      ? Image.network(
                          request.photoUrls!.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.cleaning_services, size: 40, color: Colors.grey[600]),
                        )
                      : Icon(Icons.cleaning_services, size: 40, color: Colors.grey[600]),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title ?? 'Untitled Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      request.description ?? 'No description available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location?.city ?? location?.name ?? 'Unknown Location',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getUrgencyColor(request.urgencyLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            request.urgencyLevel.displayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        if (request.proposedDate != null) ...[
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            _formatDate(request.proposedDate!),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: forestGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'See Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getUrgencyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low:
        return Colors.green;
      case UrgencyLevel.medium:
        return Colors.orange;
      case UrgencyLevel.high:
        return Colors.red;
      case UrgencyLevel.critical:
        return Colors.red[900]!;
    }
  }

  void _navigateToEventDetail(EventResponse event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(event: event),
      ),
    ).then((_) {
      _hasInitialized = false;
      _loadData();
    });
  }

  void _navigateToRequestDetail(RequestResponse request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailPage(request: request),
      ),
    ).then((_) {
      _hasInitialized = false;
      _loadData();
    });
  }
}