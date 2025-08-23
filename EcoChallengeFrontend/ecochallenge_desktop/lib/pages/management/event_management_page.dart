import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/event.dart';
import 'package:ecochallenge_desktop/providers/event_provider.dart';
import 'package:ecochallenge_desktop/widgets/event_form_dialog.dart';

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({Key? key}) : super(key: key);

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final EventProvider _eventProvider = EventProvider();
  
  List<EventResponse> _events = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  
  // Filter controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _creatorController = TextEditingController();
  int? _selectedStatus;
  int? _selectedEventType;
  bool? _selectedAdminApproved;
  
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
    } catch (e) {
      _showErrorSnackBar('Failed to load events: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _deleteEvent(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this event?'),
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
        await _eventProvider.deleteEvent(id);
        _showSuccessSnackBar('Event deleted successfully');
        _loadEvents();
      } catch (e) {
        _showErrorSnackBar('Failed to delete event: $e');
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _titleController.clear();
      _creatorController.clear();
      _selectedStatus = null;
      _selectedEventType = null;
      _selectedAdminApproved = null;
      _currentPage = 0;
    });
    _loadEvents();
  }

  void _showEventForm([EventResponse? event]) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        event: event,
        onSaved: () {
          Navigator.pop(context);
          _loadEvents();
          _showSuccessSnackBar(event == null ? 'Event created successfully' : 'Event updated successfully');
        },
      ),
    );
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
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _creatorController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Creator ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      height: 40,
                      child: DropdownButtonFormField<bool>(
                        value: _selectedAdminApproved,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Approved',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem<bool>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<bool>(
                            value: true,
                            child: Text('Approved'),
                          ),
                          DropdownMenuItem<bool>(
                            value: false,
                            child: Text('Pending'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAdminApproved = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _currentPage = 0;
                          _loadEvents();
                        },
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Search', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
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
                        onPressed: _clearFilters,
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
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEventForm(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Event', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
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
                ? const Center(child: CircularProgressIndicator())
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
                                            width: 150,
                                            child: Text(
                                              event.title ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(event.creatorUserId.toString())),
                                        DataCell(
                                          Text(
                                            '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                                          ),
                                        ),
                                        DataCell(Text(event.eventTime)),
                                        DataCell(Text('${event.currentParticipants}/${event.maxParticipants}')),
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
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 18),
                                                color: Colors.blue,
                                                onPressed: () => _showEventForm(event),
                                                tooltip: 'Edit',
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 18),
                                                color: Colors.red,
                                                onPressed: () => _deleteEvent(event.id),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page ${_currentPage + 1} of ${(_totalCount / _pageSize).ceil()}',
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
