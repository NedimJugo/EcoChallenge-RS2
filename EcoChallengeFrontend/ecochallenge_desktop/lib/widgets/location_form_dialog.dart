import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/location.dart';
import 'package:ecochallenge_desktop/providers/location_provider.dart';

class LocationFormDialog extends StatefulWidget {
  final LocationResponse? location;
  final VoidCallback onSaved;

  const LocationFormDialog({
    Key? key,
    this.location,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final LocationProvider _locationProvider = LocationProvider();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  
  LocationType _selectedLocationType = LocationType.other;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.location?.name ?? '');
    _descriptionController = TextEditingController(text: widget.location?.description ?? '');
    _latitudeController = TextEditingController(text: widget.location?.latitude.toString() ?? '');
    _longitudeController = TextEditingController(text: widget.location?.longitude.toString() ?? '');
    _addressController = TextEditingController(text: widget.location?.address ?? '');
    _cityController = TextEditingController(text: widget.location?.city ?? '');
    _countryController = TextEditingController(text: widget.location?.country ?? '');
    _postalCodeController = TextEditingController(text: widget.location?.postalCode ?? '');
    
    if (widget.location != null) {
      _selectedLocationType = widget.location!.locationType;
    }
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);

      if (widget.location == null) {
        // Create new location
        final request = LocationInsertRequest(
          name: _nameController.text.isEmpty ? null : _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          latitude: latitude,
          longitude: longitude,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          city: _cityController.text.isEmpty ? null : _cityController.text,
          country: _countryController.text.isEmpty ? null : _countryController.text,
          postalCode: _postalCodeController.text.isEmpty ? null : _postalCodeController.text,
          locationType: _selectedLocationType,
        );
        await _locationProvider.insert(request.toJson());
      } else {
        // Update existing location
        final request = LocationUpdateRequest(
          name: _nameController.text.isEmpty ? null : _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          latitude: latitude,
          longitude: longitude,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          city: _cityController.text.isEmpty ? null : _cityController.text,
          country: _countryController.text.isEmpty ? null : _countryController.text,
          postalCode: _postalCodeController.text.isEmpty ? null : _postalCodeController.text,
          locationType: _selectedLocationType,
        );
        await _locationProvider.update(widget.location!.id, request.toJson());
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save location: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.location == null ? 'Add New Location' : 'Edit Location',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<LocationType>(
                              value: _selectedLocationType,
                              decoration: const InputDecoration(
                                labelText: 'Location Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: LocationType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedLocationType = value!),
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
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Latitude is required';
                                final lat = double.tryParse(value!);
                                if (lat == null) return 'Enter a valid latitude';
                                if (lat < -90 || lat > 90) return 'Latitude must be between -90 and 90';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return 'Longitude is required';
                                final lng = double.tryParse(value!);
                                if (lng == null) return 'Enter a valid longitude';
                                if (lng < -180 || lng > 180) return 'Longitude must be between -180 and 180';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _countryController,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Postal Code',
                          border: OutlineInputBorder(),
                        ),
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
                    onPressed: _isLoading ? null : _saveLocation,
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
                        : Text(widget.location == null ? 'Create' : 'Update'),
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
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}
