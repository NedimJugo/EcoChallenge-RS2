import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/organization.dart';
import 'package:ecochallenge_desktop/providers/organization_provider.dart';
import 'package:ecochallenge_desktop/widgets/organization_form_dialog.dart';

class OrganizationManagementPage extends StatefulWidget {
  const OrganizationManagementPage({super.key});

  @override
  State<OrganizationManagementPage> createState() => _OrganizationManagementPageState();
}

class _OrganizationManagementPageState extends State<OrganizationManagementPage> {
  final OrganizationProvider _organizationProvider = OrganizationProvider();
  List<OrganizationResponse> _organizations = [];
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  int _totalCount = 0;
  
  // Filter controllers
  final TextEditingController _textController = TextEditingController();
  String? _selectedCategory;
  bool? _isVerifiedFilter;
  bool? _isActiveFilter;
  
  // Scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final searchObject = OrganizationSearchObject(
        text: _textController.text.isEmpty ? null : _textController.text,
        category: _selectedCategory,
        isVerified: _isVerifiedFilter,
        isActive: _isActiveFilter,
        page: _currentPage,
        pageSize: _pageSize,
        includeTotalCount: true,
      );

      final result = await _organizationProvider.get(filter: searchObject.toJson());
      setState(() {
        _organizations = result.items ?? [];
        _totalCount = result.totalCount ?? 0;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading organizations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      _textController.clear();
      _selectedCategory = null;
      _isVerifiedFilter = null;
      _isActiveFilter = null;
      _currentPage = 0;
    });
    _loadOrganizations();
  }

  void _showOrganizationForm([OrganizationResponse? organization]) {
    showDialog(
      context: context,
      builder: (context) => OrganizationFormDialog(
        organization: organization,
        onSaved: () {
          Navigator.pop(context);
          _loadOrganizations();
          _showSuccessSnackBar(organization == null ? 'Organization created successfully' : 'Organization updated successfully');
        },
      ),
    );
  }

  Future<void> _deleteOrganization(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this organization?'),
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
        await _organizationProvider.delete(id);
        _showSuccessSnackBar('Organization deleted successfully');
        _loadOrganizations();
      } catch (e) {
        _showErrorSnackBar('Error deleting organization: $e');
      }
    }
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
                          controller: _textController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Search by Name/Email/Phone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search, size: 18),
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
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value.isEmpty ? null : value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: DropdownButtonFormField<bool?>(
                        value: _isVerifiedFilter,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Verified Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                          prefixIcon: Icon(Icons.verified, size: 18),
                        ),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Verified'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Not Verified'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isVerifiedFilter = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: DropdownButtonFormField<bool?>(
                        value: _isActiveFilter,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Active Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                          prefixIcon: Icon(Icons.toggle_on, size: 18),
                        ),
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isActiveFilter = value;
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
                          _loadOrganizations();
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
                        onPressed: () => _showOrganizationForm(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Organization', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('Total: $_totalCount organizations', style: const TextStyle(fontSize: 14)),
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
                                    DataColumn(label: Text('Category')),
                                    DataColumn(label: Text('Contact Email')),
                                    DataColumn(label: Text('Verified')),
                                    DataColumn(label: Text('Active')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: _organizations.map((organization) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(organization.id.toString())),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              organization.name ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              organization.category ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 150,
                                            child: Text(
                                              organization.contactEmail ?? 'N/A',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Icon(
                                            organization.isVerified ? Icons.check_circle : Icons.cancel,
                                            color: organization.isVerified ? Colors.green : Colors.red,
                                            size: 18,
                                          ),
                                        ),
                                        DataCell(
                                          Icon(
                                            organization.isActive ? Icons.check_circle : Icons.cancel,
                                            color: organization.isActive ? Colors.green : Colors.red,
                                            size: 18,
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 18),
                                                color: Colors.blue,
                                                onPressed: () => _showOrganizationForm(organization),
                                                tooltip: 'Edit',
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 18),
                                                color: Colors.red,
                                                onPressed: () => _deleteOrganization(organization.id),
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
                              _loadOrganizations();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      onPressed: (_currentPage + 1) * _pageSize < _totalCount
                          ? () {
                              setState(() => _currentPage++);
                              _loadOrganizations();
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
    _textController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}