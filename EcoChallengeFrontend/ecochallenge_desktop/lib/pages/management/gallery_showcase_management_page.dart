import 'package:ecochallenge_desktop/layouts/constants.dart';
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
  
  // Filter controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationIdController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();
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
      await _loadGalleryItems();
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGalleryItems() async {
    try {
      final searchObject = GalleryShowcaseSearchObject(
        page: _currentPage,
        pageSize: _pageSize,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        locationId: _locationIdController.text.isNotEmpty 
            ? int.tryParse(_locationIdController.text) 
            : null,
        createdByAdminId: _adminIdController.text.isNotEmpty 
            ? int.tryParse(_adminIdController.text) 
            : null,
        isApproved: _isApprovedFilter,
        isFeatured: _isFeaturedFilter,
      );

      final result = await _galleryProvider.get(filter: searchObject.toJson());
      
      setState(() {
        _galleryItems = result.items ?? [];
        _totalCount = result.totalCount ?? 0;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load gallery items: $e');
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

  Future<void> _deleteGalleryItem(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this gallery item?'),
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
        _showErrorSnackBar('Failed to delete gallery item: $e');
      }
    }
  }

  Future<void> _toggleApprovalStatus(GalleryShowcaseResponse item) async {
    try {
      final updateRequest = GalleryShowcaseUpdateRequest(
        id: item.id,
        isApproved: !item.isApproved,
      );
      await _galleryProvider.update(item.id, updateRequest.toJson());
      _showSuccessSnackBar('Gallery item approval status updated successfully');
      _loadGalleryItems();
    } catch (e) {
      _showErrorSnackBar('Failed to update approval status: $e');
    }
  }

  Future<void> _toggleFeaturedStatus(GalleryShowcaseResponse item) async {
    try {
      final updateRequest = GalleryShowcaseUpdateRequest(
        id: item.id,
        isFeatured: !item.isFeatured,
      );
      await _galleryProvider.update(item.id, updateRequest.toJson());
      _showSuccessSnackBar('Gallery item featured status updated successfully');
      _loadGalleryItems();
    } catch (e) {
      _showErrorSnackBar('Failed to update featured status: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _titleController.clear();
      _locationIdController.clear();
      _adminIdController.clear();
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
          Navigator.pop(context);
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
                        child: TextField(
                          controller: _locationIdController,
                          style: const TextStyle(fontSize: 14),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Location ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on, size: 18),
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
                          controller: _adminIdController,
                          style: const TextStyle(fontSize: 14),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Admin ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.admin_panel_settings, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
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
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: DropdownButtonFormField<bool>(
                        value: _isFeaturedFilter,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Featured',
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
                            child: Text('Featured'),
                          ),
                          DropdownMenuItem<bool>(
                            value: false,
                            child: Text('Not Featured'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isFeaturedFilter = value;
                          });
                        },
                      ),
                    ),
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
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _showGalleryItemForm(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Gallery Item', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: forestGreen[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
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
                                    DataColumn(label: Text('Location ID')),
                                    DataColumn(label: Text('Admin ID')),
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
                                        DataCell(Text(item.locationId.toString())),
                                        DataCell(Text(item.createdByAdminId.toString())),
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
                                                icon: Icon(
                                                  item.isApproved ? Icons.remove_circle : Icons.check_circle,
                                                  size: 18,
                                                ),
                                                color: item.isApproved ? Colors.orange : Colors.green,
                                                onPressed: () => _toggleApprovalStatus(item),
                                                tooltip: item.isApproved ? 'Remove Approval' : 'Approve',
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  item.isFeatured ? Icons.star : Icons.star_border,
                                                  size: 18,
                                                ),
                                                color: item.isFeatured ? Colors.amber : Colors.grey,
                                                onPressed: () => _toggleFeaturedStatus(item),
                                                tooltip: item.isFeatured ? 'Remove Featured' : 'Make Featured',
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 18),
                                                color: Colors.red,
                                                onPressed: () => _deleteGalleryItem(item.id),
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
    _locationIdController.dispose();
    _adminIdController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}