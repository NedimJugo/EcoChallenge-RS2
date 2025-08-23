import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ecochallenge_desktop/models/gallery_showcase.dart';
import 'package:ecochallenge_desktop/providers/gallery_showcase_provider.dart';

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
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationIdController;
  late TextEditingController _adminIdController;
  late TextEditingController _requestIdController;
  late TextEditingController _eventIdController;
  
  bool _isFeatured = false;
  bool _isApproved = false;
  bool _isLoading = false;
  
  File? _beforeImage;
  File? _afterImage;
  String? _beforeImagePath;
  String? _afterImagePath;

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.galleryItem?.title ?? '');
    _descriptionController = TextEditingController(text: widget.galleryItem?.description ?? '');
    _locationIdController = TextEditingController(text: widget.galleryItem?.locationId.toString() ?? '');
    _adminIdController = TextEditingController(text: widget.galleryItem?.createdByAdminId.toString() ?? '');
    _requestIdController = TextEditingController(text: widget.galleryItem?.requestId?.toString() ?? '');
    _eventIdController = TextEditingController(text: widget.galleryItem?.eventId?.toString() ?? '');
    
    if (widget.galleryItem != null) {
      _isFeatured = widget.galleryItem!.isFeatured;
      _isApproved = widget.galleryItem!.isApproved;
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
            _beforeImagePath = result.files.single.name;
          } else {
            _afterImage = File(result.files.single.path!);
            _afterImagePath = result.files.single.name;
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
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_locationIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location ID is required')),
      );
      return;
    }

    if (_adminIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin ID is required')),
      );
      return;
    }

    // For new items, images are required
    if (widget.galleryItem == null && (_beforeImage == null || _afterImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Before and After images are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.galleryItem == null) {
        // Create new gallery item
        final request = GalleryShowcaseInsertRequest(
          locationId: int.parse(_locationIdController.text),
          createdByAdminId: int.parse(_adminIdController.text),
          beforeImage: _beforeImage!,
          afterImage: _afterImage!,
          title: _titleController.text.isEmpty ? null : _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          requestId: _requestIdController.text.isEmpty ? null : int.tryParse(_requestIdController.text),
          eventId: _eventIdController.text.isEmpty ? null : int.tryParse(_eventIdController.text),
          isFeatured: _isFeatured,
        );
        await _galleryProvider.createWithImages(request);
      } else {
        // Update existing gallery item
        final request = GalleryShowcaseUpdateRequest(
          id: widget.galleryItem!.id,
          locationId: _locationIdController.text.isEmpty ? null : int.tryParse(_locationIdController.text),
          createdByAdminId: _adminIdController.text.isEmpty ? null : int.tryParse(_adminIdController.text),
          title: _titleController.text.isEmpty ? null : _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          requestId: _requestIdController.text.isEmpty ? null : int.tryParse(_requestIdController.text),
          eventId: _eventIdController.text.isEmpty ? null : int.tryParse(_eventIdController.text),
          isFeatured: _isFeatured,
          isApproved: _isApproved,
        );
        await _galleryProvider.updateWithImages(
          widget.galleryItem!.id,
          request,
          beforeImage: _beforeImage,
          afterImage: _afterImage,
        );
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save gallery item: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
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
                      
                      // Location ID and Admin ID
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationIdController,
                              decoration: const InputDecoration(
                                labelText: 'Location ID *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Location ID is required';
                                if (int.tryParse(value!) == null) return 'Enter a valid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _adminIdController,
                              decoration: const InputDecoration(
                                labelText: 'Admin ID *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Admin ID is required';
                                if (int.tryParse(value!) == null) return 'Enter a valid number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Request ID and Event ID
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _requestIdController,
                              decoration: const InputDecoration(
                                labelText: 'Request ID (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true && int.tryParse(value!) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _eventIdController,
                              decoration: const InputDecoration(
                                labelText: 'Event ID (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isNotEmpty == true && int.tryParse(value!) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
    _locationIdController.dispose();
    _adminIdController.dispose();
    _requestIdController.dispose();
    _eventIdController.dispose();
    super.dispose();
  }
}