import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecochallenge_desktop/models/gallery_showcase.dart';
import 'package:ecochallenge_desktop/providers/gallery_showcase_provider.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';
import 'package:ecochallenge_desktop/providers/location_provider.dart';
import 'package:ecochallenge_desktop/providers/event_provider.dart';
import 'package:ecochallenge_desktop/providers/request_provider.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/models/location.dart';
import 'package:ecochallenge_desktop/models/event.dart';
import 'package:ecochallenge_desktop/models/request.dart';

class GalleryShowcaseFormDialog extends StatefulWidget {
  final GalleryShowcaseResponse? galleryItem;
  final VoidCallback onSaved;

  const GalleryShowcaseFormDialog({
    Key? key,
    this.galleryItem,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<GalleryShowcaseFormDialog> createState() => _GalleryShowcaseFormDialogState();
}

class _GalleryShowcaseFormDialogState extends State<GalleryShowcaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final GalleryShowcaseProvider _galleryProvider = GalleryShowcaseProvider();
  final UserProvider _userProvider = UserProvider();
  final LocationProvider _locationProvider = LocationProvider();
  final EventProvider _eventProvider = EventProvider();
  final RequestProvider _requestProvider = RequestProvider();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  bool _isFeatured = false;
  bool _isApproved = false;
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  File? _beforeImage;
  File? _afterImage;


  // Dropdown data
  List<LocationResponse> _locations = [];
  List<UserResponse> _users = [];
  List<EventResponse> _events = [];
  List<RequestResponse> _requests = [];

  // Selected values
  int? _selectedLocationId;
  int? _selectedAdminId;
  int? _selectedRequestId;
  int? _selectedEventId;

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.galleryItem?.title ?? '');
    _descriptionController = TextEditingController(text: widget.galleryItem?.description ?? '');
    
    // Initialize selected values from existing gallery item
    if (widget.galleryItem != null) {
      _selectedLocationId = widget.galleryItem!.locationId;
      _selectedAdminId = widget.galleryItem!.createdByAdminId;
      _selectedRequestId = widget.galleryItem!.requestId;
      _selectedEventId = widget.galleryItem!.eventId;
      _isFeatured = widget.galleryItem!.isFeatured;
      _isApproved = widget.galleryItem!.isApproved;
    }

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => _isLoadingData = true);
    
    try {
      // Load all dropdown data in parallel
      final results = await Future.wait([
        _locationProvider.getAllLocations(),
        _userProvider.get().then((result) => result.items ?? <UserResponse>[]),
        _eventProvider.get().then((result) => result.items ?? <EventResponse>[]),
        _requestProvider.get().then((result) => result.items ?? <RequestResponse>[]),
      ]);

      setState(() {
        _locations = results[0] as List<LocationResponse>;
        _users = results[1] as List<UserResponse>;
        _events = results[2] as List<EventResponse>;
        _requests = results[3] as List<RequestResponse>;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load dropdown data: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _pickImage(bool isBefore) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          if (isBefore) {
            _beforeImage = File(result.files.single.path!);
          } else {
            _afterImage = File(result.files.single.path!);

          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
      );
    }
  }

Future<void> _saveGalleryItem() async {
  print('_saveGalleryItem called'); // Debug
  
  if (!_formKey.currentState!.validate()) {
    print('Form validation failed'); // Debug
    return;
  }

  // Validate required fields
  if (_selectedLocationId == null) {
    print('Location not selected'); // Debug
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a location')),
    );
    return;
  }

  if (_selectedAdminId == null) {
    print('Admin not selected'); // Debug
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select an admin')),
    );
    return;
  }

  // For new items, images are required
  if (widget.galleryItem == null && (_beforeImage == null || _afterImage == null)) {
    print('Images not selected for new item'); // Debug
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Before and After images are required')),
    );
    return;
  }

  print('Starting save operation, isUpdate: ${widget.galleryItem != null}'); // Debug
  setState(() => _isLoading = true);

  try {
    if (widget.galleryItem == null) {
      print('Creating new gallery item'); // Debug
      final request = GalleryShowcaseInsertRequest(
        locationId: _selectedLocationId!,
        createdByAdminId: _selectedAdminId!,
        beforeImage: _beforeImage!,
        afterImage: _afterImage!,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        requestId: _selectedRequestId,
        eventId: _selectedEventId,
        isFeatured: _isFeatured,
      );
      await _galleryProvider.createWithImages(request);
      print('Create operation completed'); // Debug
    } else {
      print('Updating existing gallery item: ${widget.galleryItem!.id}'); // Debug
      final request = GalleryShowcaseUpdateRequest(
        locationId: _selectedLocationId,
        createdByAdminId: _selectedAdminId,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        requestId: _selectedRequestId,
        eventId: _selectedEventId,
        isFeatured: _isFeatured,
        isApproved: _isApproved,
      );
      
      print('Update request created, calling provider...'); // Debug
      await _galleryProvider.updateWithImages(
        widget.galleryItem!.id,
        request,
        beforeImage: _beforeImage,
        afterImage: _afterImage,
      );
      print('Update operation completed'); // Debug
    }
    
    print('Save successful, navigating back...'); // Debug
    
    // Check if widget is still mounted before navigation
    if (!mounted) {
      print('Widget not mounted, skipping navigation'); // Debug
      return;
    }
    
    // Stop loading first
    setState(() => _isLoading = false);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.galleryItem == null ? 
          'Gallery item created successfully!' : 
          'Gallery item updated successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Small delay to let the success message show
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Navigate back and call callback
    if (mounted) {
      print('Calling onSaved callback...'); // Debug
      widget.onSaved(); // Call callback first
      
      print('Popping dialog...'); // Debug
      Navigator.of(context).pop(); // Then pop dialog
    }
    
  } catch (e, stackTrace) {
    print('Error in _saveGalleryItem: $e'); // Debug
    print('StackTrace: $stackTrace'); // Debug
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save gallery item: $e'), 
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

  Widget _buildImagePicker({
    required String label,
    required bool isBefore,
    required String? imagePath,
    String? existingImageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () => _pickImage(isBefore),
            child: imagePath != null || existingImageUrl != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imagePath != null
                            ? Image.file(
                                File(imagePath),
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                existingImageUrl!,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.broken_image));
                                },
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                            onPressed: () => _pickImage(isBefore),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Click to select $label',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
          ),
        ),
        if (imagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Selected: $imagePath',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) getDisplayText,
    required dynamic Function(T) getValue,
    required void Function(T?) onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            getDisplayText(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired ? (value) {
        if (value == null) return '$label is required';
        return null;
      } : null,
      isExpanded: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: _isLoadingData
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading dropdown data...'),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.galleryItem == null ? 'Add New Gallery Item' : 'Edit Gallery Item',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Title and Description
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            
                            // Location and Admin dropdowns
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown<LocationResponse>(
                                    label: 'Location',
                                    value: _locations.where((l) => l.id == _selectedLocationId).firstOrNull,
                                    items: _locations,
                                    getDisplayText: (location) => location.name ?? 'Unknown Location',
                                    getValue: (location) => location.id,
                                    onChanged: (location) => setState(() => _selectedLocationId = location?.id),
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                               Expanded(
  child: _buildDropdown<UserResponse>(
    label: 'Admin',
    value: _users.where((u) => u.id == _selectedAdminId).firstOrNull,
    items: _users,
    getDisplayText: (user) {
      final firstName = user.firstName;
      final lastName = user.lastName;
      final fullName = '$firstName $lastName'.trim();
    
      return fullName.isEmpty ? user.email : fullName;
    },
    getValue: (user) => user.id,
    onChanged: (user) => setState(() => _selectedAdminId = user?.id),
    isRequired: true,
  ),
),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Request and Event dropdowns (optional)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown<RequestResponse>(
                                    label: 'Request',
                                    value: _requests.where((r) => r.id == _selectedRequestId).firstOrNull,
                                    items: _requests,
                                    getDisplayText: (request) => request.title ?? 'Request #${request.id}',
                                    getValue: (request) => request.id,
                                    onChanged: (request) => setState(() => _selectedRequestId = request?.id),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdown<EventResponse>(
                                    label: 'Event',
                                    value: _events.where((e) => e.id == _selectedEventId).firstOrNull,
                                    items: _events,
                                    getDisplayText: (event) => event.title ?? 'Event #${event.id}',
                                    getValue: (event) => event.id,
                                    onChanged: (event) => setState(() => _selectedEventId = event?.id),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Image Pickers
                            Row(
                              children: [
                                Expanded(
                                  child: _buildImagePicker(
                                    label: 'Before Image',
                                    isBefore: true,
                                    imagePath: _beforeImage?.path,
                                    existingImageUrl: widget.galleryItem?.beforeImageUrl,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildImagePicker(
                                    label: 'After Image',
                                    isBefore: false,
                                    imagePath: _afterImage?.path,
                                    existingImageUrl: widget.galleryItem?.afterImageUrl,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Switches
                            Row(
                              children: [
                                Expanded(
                                  child: SwitchListTile(
                                    title: const Text('Featured'),
                                    subtitle: const Text('Show in featured gallery'),
                                    value: _isFeatured,
                                    onChanged: (value) => setState(() => _isFeatured = value),
                                  ),
                                ),
                                if (widget.galleryItem != null)
                                  Expanded(
                                    child: SwitchListTile(
                                      title: const Text('Approved'),
                                      subtitle: const Text('Approve for public viewing'),
                                      value: _isApproved,
                                      onChanged: (value) => setState(() => _isApproved = value),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveGalleryItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(widget.galleryItem == null ? 'Create' : 'Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}