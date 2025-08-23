import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/badge.dart';
import 'package:ecochallenge_desktop/models/badge_type.dart';
import 'package:ecochallenge_desktop/providers/badge_provider.dart';
import 'package:ecochallenge_desktop/providers/badge_type_provider.dart';
import 'package:ecochallenge_desktop/widgets/badge_form_dialog.dart';

class BadgeManagementPage extends StatefulWidget {
  const BadgeManagementPage({super.key});

  @override
  State<BadgeManagementPage> createState() => _BadgeManagementPageState();
}

class _BadgeManagementPageState extends State<BadgeManagementPage> {
  final BadgeProvider _badgeProvider = BadgeProvider();
  final BadgeTypeProvider _badgeTypeProvider = BadgeTypeProvider();
  List<BadgeResponse> _badges = [];
  List<BadgeTypeResponse> _badgeTypes = [];
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalCount = 0;
  
  // Filter controllers
  final TextEditingController _nameController = TextEditingController();
  int? _selectedBadgeTypeId;
  
  // Scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBadgeTypes();
    _loadBadges();
  }

  Future<void> _loadBadgeTypes() async {
    try {
      final badgeTypes = await _badgeTypeProvider.getAll();
      setState(() {
        _badgeTypes = badgeTypes;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading badge types: $e');
    }
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);

    try {
      final searchObject = BadgeSearchObject(
        name: _nameController.text.isEmpty ? null : _nameController.text,
        badgeTypeId: _selectedBadgeTypeId,
        page: _currentPage,
        pageSize: _pageSize,
        includeTotalCount: true,
      );

      final result = await _badgeProvider.get(filter: searchObject.toJson());
      setState(() {
        _badges = result.items ?? [];
        _totalCount = result.totalCount ?? 0;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load badges: $e');
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

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _selectedBadgeTypeId = null;
      _currentPage = 0;
    });
    _loadBadges();
  }

  void _showBadgeForm([BadgeResponse? badge]) {
    showDialog(
      context: context,
      builder: (context) => BadgeFormDialog(
        badge: badge,
        badgeTypes: _badgeTypes,
        onSaved: () {
          Navigator.pop(context);
          _loadBadges();
          _showSuccessSnackBar(badge == null ? 'Badge created successfully' : 'Badge updated successfully');
        },
      ),
    );
  }

  // Replace your existing _deleteBadge method in BadgeManagementPage with this:

Future<void> _deleteBadge(int id, String name) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text('Are you sure you want to delete "$name"?'),
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
      print("Attempting to delete badge ID: $id, Name: $name");
      
      bool result = await _badgeProvider.deleteBadge(id);
      
      print("Delete operation result: $result");
      
      if (result) {
        _showSuccessSnackBar('Badge "$name" deleted successfully');
        await _loadBadges(); // Reload the list to reflect changes
      } else {
        _showErrorSnackBar('You cannot delete this badge because it is awarded to users');
      }
    } catch (e) {
      print("Delete operation exception: $e");
      
      // Handle specific error messages
      String errorMessage = 'Failed to delete badge "$name"';
      if (e.toString().contains('Cannot delete badge')) {
        errorMessage = 'Cannot delete badge "$name": It may have been awarded to users';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error: Please check your connection';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }
}

  String _getBadgeTypeName(int badgeTypeId) {
    final badgeType = _badgeTypes.firstWhere(
      (bt) => bt.id == badgeTypeId,
      orElse: () => BadgeTypeResponse(id: 0, name: 'Unknown'),
    );
    return badgeType.name;
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
                          controller: _nameController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: DropdownButtonFormField<int?>(
                        value: _selectedBadgeTypeId,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Badge Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                          prefixIcon: Icon(Icons.category, size: 18),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ..._badgeTypes.map((badgeType) => DropdownMenuItem<int?>(
                            value: badgeType.id,
                            child: Text(badgeType.name),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBadgeTypeId = value;
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
                          _loadBadges();
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
                        onPressed: () => _showBadgeForm(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Badge', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: forestGreen[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('Total: $_totalCount badges', style: const TextStyle(fontSize: 14)),
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
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Badge Type')),
                                    DataColumn(label: Text('Criteria Value')),
                                    DataColumn(label: Text('Active')),
                                    DataColumn(label: Text('Created')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: _badges.map((badge) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(badge.id.toString())),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              badge.name ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              _getBadgeTypeName(badge.badgeTypeId),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(badge.criteriaValue.toString())),
                                        DataCell(
                                          Icon(
                                            badge.isActive ? Icons.check_circle : Icons.cancel,
                                            color: badge.isActive ? Colors.green : Colors.red,
                                            size: 18,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${badge.createdAt.day}/${badge.createdAt.month}/${badge.createdAt.year}',
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 18),
                                                color: Colors.blue,
                                                onPressed: () => _showBadgeForm(badge),
                                                tooltip: 'Edit',
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 18),
                                                color: Colors.red,
                                                onPressed: () => _deleteBadge(badge.id, badge.name ?? 'Unknown'),
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
                              _loadBadges();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      onPressed: (_currentPage + 1) * _pageSize < _totalCount
                          ? () {
                              setState(() => _currentPage++);
                              _loadBadges();
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
    _nameController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}