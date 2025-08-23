import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:ecochallenge_desktop/models/location.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/providers/location_provider.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/gallery_showcase.dart';
import 'package:ecochallenge_desktop/providers/gallery_showcase_provider.dart';
import 'package:ecochallenge_desktop/widgets/gallery_showcase_form_dialog.dart';

class GalleryShowcaseManagementPage extends StatefulWidget {
  const GalleryShowcaseManagementPage({Key? key}) : super(key: key);

  @override
  State<GalleryShowcaseManagementPage> createState() => _GalleryShowcaseManagementPageState();
}

class _GalleryShowcaseManagementPageState extends State<GalleryShowcaseManagementPage> {
  final GalleryShowcaseProvider _galleryProvider = GalleryShowcaseProvider();
  
  List<GalleryShowcaseResponse> _galleryItems = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;

  final LocationProvider _locationProvider = LocationProvider();
  final UserProvider _userProvider = UserProvider();
  List<LocationResponse> _locations = [];
  List<UserResponse> _admins = [];
  int? _selectedLocationId;
  int? _selectedAdminId;
  
  // Filter controllers
  final TextEditingController _titleController = TextEditingController();
  bool? _isApprovedFilter;
  bool? _isFeaturedFilter;
  
  // Scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadLocations(),
        _loadAdmins(),
      ]);
      // Load gallery items after locations and admins are loaded
      await _loadGalleryItems();
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _locationProvider.getAllLocations();
      setState(() => _locations = locations);
      print('Loaded ${_locations.length} locations');
    } catch (e) {
      _showErrorSnackBar('Failed to load locations: $e');
    }
  }

  Future<void> _loadAdmins() async {
    try {
      // You might need to adjust this filter to get only admin users
      final result = await _userProvider.get(filter: {'userTypeId': 2}); // Assuming 2 is the ID for admin user type
      setState(() => _admins = result.items ?? []);
      print('Loaded ${_admins.length} admins');
    } catch (e) {
      _showErrorSnackBar('Failed to load admins: $e');
    }
  }

  Future<void> _loadGalleryItems() async {
    try {
      final searchObject = GalleryShowcaseSearchObject(
        page: _currentPage,
        pageSize: _pageSize,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        locationId: _selectedLocationId,
        createdByAdminId: _selectedAdminId,
        isApproved: _isApprovedFilter,
        isFeatured: _isFeaturedFilter,
      );

      final result = await _galleryProvider.get(filter: searchObject.toJson());
      
      setState(() {
        _galleryItems = result.items ?? [];
        _totalCount = result.totalCount ?? 0;
      });
      
      print('Loaded ${_galleryItems.length} gallery items');
    } catch (e) {
      _showErrorSnackBar('Failed to load gallery items: $e');
    }
  }

  // Helper methods to get location and admin names
  String _getLocationName(int? locationId) {
    if (locationId == null) return 'No Location';
    
    try {
      final location = _locations.firstWhere((loc) => loc.id == locationId);
      return location.name ?? 'Location $locationId';
    } catch (e) {
      return 'Location $locationId ';
    }
  }

  String _getAdminName(int? adminId) {
  if (adminId == null) return 'No Admin';
  
  try {
    final admin = _admins.firstWhere((admin) => admin.id == adminId);
    return '${admin.firstName} ${admin.lastName}'.trim();
  } catch (e) {
    return 'Admin $adminId';
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

  Future<void> _deleteGalleryItem(int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the gallery item "$name"?\n\nThis action cannot be undone.'),
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
        await _galleryProvider.delete(id);
        _showSuccessSnackBar('Gallery item deleted successfully');
        _loadGalleryItems();
      } catch (e) {
        String errorMessage = 'You cannot delete this gallery item because it is being used by existing tables';

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
      _selectedLocationId = null;
      _selectedAdminId = null;
      _isApprovedFilter = null;
      _isFeaturedFilter = null;
      _currentPage = 0;
    });
    _loadGalleryItems();
  }

  void _showGalleryItemForm([GalleryShowcaseResponse? item]) {
  showDialog(
    context: context,
    builder: (context) => GalleryShowcaseFormDialog(
      galleryItem: item,
      onSaved: () {
        // Remove Navigator.pop(context) - the dialog handles its own navigation!
        print('onSaved callback triggered in parent');
        setState(() {
          // Force rebuild
        });
        _loadGalleryItems();
        _showSuccessSnackBar(item == null 
            ? 'Gallery item created successfully' 
            : 'Gallery item updated successfully');
      },
    ),
  );
}

  void _showImagePreview(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(title),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text('Failed to load image'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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
                            prefixIcon: Icon(Icons.title, size: 18),
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
                        child: DropdownButtonFormField<int>(
                          value: _selectedLocationId,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('All Locations', style: TextStyle(color: Colors.black)),
                            ),
                            ..._locations.map((location) {
                              final locationName = location.name ?? 'Location ${location.id}';
                              return DropdownMenuItem<int>(
                                value: location.id,
                                child: Text(
                                  locationName.length > 20 ? '${locationName.substring(0, 20)}...' : locationName,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLocationId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: DropdownButtonFormField<bool>(
                        value: _isApprovedFilter,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Approval',
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
                            child: Text('Not Approved'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isApprovedFilter = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _currentPage = 0;
                          _loadGalleryItems();
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
                    const Spacer(),
                    const SizedBox(width: 16),
                    Text('Total: $_totalCount items', style: const TextStyle(fontSize: 14)),
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
                                  dataRowHeight: 64,
                                  headingRowHeight: 40,
                                  dataTextStyle: const TextStyle(fontSize: 12),
                                  headingTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  columns: const [
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('Title')),
                                    DataColumn(label: Text('Location')),
                                    DataColumn(label: Text('Admin')),
                                    DataColumn(label: Text('Before/After')),
                                    DataColumn(label: Text('Likes/Dislikes')),
                                    DataColumn(label: Text('Featured')),
                                    DataColumn(label: Text('Approved')),
                                    DataColumn(label: Text('Reported')),
                                    DataColumn(label: Text('Created At')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: _galleryItems.map((item) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(item.id.toString())),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              item.title ?? 'No title',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(_getLocationName(item.locationId))),
                                        DataCell(Text(_getAdminName(item.createdByAdminId))),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () => _showImagePreview(
                                                  item.beforeImageUrl, 
                                                  'Before Image'
                                                ),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Image.network(
                                                      item.beforeImageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.broken_image, size: 16);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              GestureDetector(
                                                onTap: () => _showImagePreview(
                                                  item.afterImageUrl, 
                                                  'After Image'
                                                ),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Image.network(
                                                      item.afterImageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.broken_image, size: 16);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text('${item.likesCount}/${item.dislikesCount}')),
                                        DataCell(
                                          Chip(
                                            label: Text(
                                              item.isFeatured ? 'Featured' : 'Not Featured',
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                            backgroundColor: item.isFeatured ? Colors.orange[100] : Colors.grey[200],
                                            labelStyle: TextStyle(
                                              color: item.isFeatured ? Colors.orange[800] : Colors.grey[600],
                                            ),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                        DataCell(
                                          Chip(
                                            label: Text(
                                              item.isApproved ? 'Approved' : 'Pending',
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                            backgroundColor: item.isApproved ? Colors.green[100] : Colors.red[100],
                                            labelStyle: TextStyle(
                                              color: item.isApproved ? Colors.green[800] : Colors.red[800],
                                            ),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                        DataCell(
                                          item.isReported 
                                              ? Chip(
                                                  label: Text(
                                                    'Reported (${item.reportCount})',
                                                    style: const TextStyle(fontSize: 10),
                                                  ),
                                                  backgroundColor: Colors.red[100],
                                                  labelStyle: TextStyle(color: Colors.red[800]),
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                )
                                              : const Text('Clean'),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 80,
                                            child: Text(
                                              '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 18),
                                                color: Colors.blue,
                                                onPressed: () => _showGalleryItemForm(item),
                                                tooltip: 'Edit',
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),

                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 18),
                                                color: Colors.red,
                                                onPressed: () => _deleteGalleryItem(item.id, item.title ?? 'N/A'),
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
                              _loadGalleryItems();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      onPressed: (_currentPage + 1) * _pageSize < _totalCount
                          ? () {
                              setState(() => _currentPage++);
                              _loadGalleryItems();
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
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}