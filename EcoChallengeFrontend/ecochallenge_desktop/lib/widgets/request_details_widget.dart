import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../models/location.dart';
import '../providers/request_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/large_image_viewer.dart';
import '../widgets/openstreet_map_widget.dart';

class RequestDetailsWidget extends StatefulWidget {
  final RequestResponse request;
  final VoidCallback onBack;
  final double availableHeight;

  const RequestDetailsWidget({
    Key? key,
    required this.request,
    required this.onBack,
    required this.availableHeight,
  }) : super(key: key);

  @override
  _RequestDetailsWidgetState createState() => _RequestDetailsWidgetState();
}

class _RequestDetailsWidgetState extends State<RequestDetailsWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _rewardController;
  late TextEditingController _pointsController;
  
  UrgencyLevel _selectedUrgency = UrgencyLevel.medium;
  EstimatedAmount _selectedAmount = EstimatedAmount.medium;
  LocationResponse? _selectedLocation;
  List<LocationResponse> _locations = [];
  bool _isLoading = false;
   bool _locationsLoaded = false;
  
  // Validation errors
  Map<String, String> _validationErrors = {};
  
  // Focus nodes for better UX
  late FocusNode _titleFocus;
  late FocusNode _descriptionFocus;
  late FocusNode _rewardFocus;
  late FocusNode _pointsFocus;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
    _loadLocations();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.request.title ?? '');
    _descriptionController = TextEditingController(text: widget.request.description ?? '');
    _rewardController = TextEditingController(text: widget.request.actualRewardMoney.toString());
    _pointsController = TextEditingController(text: widget.request.actualRewardPoints.toString());
    
    // Initialize with current request values
    _selectedUrgency = widget.request.urgencyLevel;
    _selectedAmount = widget.request.estimatedAmount;
    
    // Add listeners for real-time validation
    _titleController.addListener(_validateFields);
    _descriptionController.addListener(_validateFields);
    _rewardController.addListener(_validateFields);
    _pointsController.addListener(_validateFields);
  }

  void _initializeFocusNodes() {
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _rewardFocus = FocusNode();
    _pointsFocus = FocusNode();
  }

  void _loadLocations() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final locations = await locationProvider.getAllLocations();
      
      setState(() {
        _locations = locations;
        _locationsLoaded = true;
        
        // Find and set the selected location based on the request's locationId
        if (_locations.isNotEmpty) {
          try {
            _selectedLocation = _locations.firstWhere(
              (loc) => loc.id == widget.request.locationId,
            );
            print('Found matching location: ${_selectedLocation?.name} (ID: ${_selectedLocation?.id})');
          } catch (e) {
            print('No matching location found for ID: ${widget.request.locationId}');
            // If no exact match, set to first location as fallback
            _selectedLocation = _locations.first;
            print('Using fallback location: ${_selectedLocation?.name} (ID: ${_selectedLocation?.id})');
          }
        }
      });
      
      // Validate after loading locations
      _validateFields();
      
    } catch (e) {
      print('Error loading locations: $e');
      setState(() {
        _locationsLoaded = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading locations: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  void _validateFields() {
    setState(() {
      _validationErrors.clear();
      
      // Title validation
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        _validationErrors['title'] = 'Title is required';
      } else if (title.length < 5) {
        _validationErrors['title'] = 'Title must be at least 5 characters long';
      } else if (title.length > 100) {
        _validationErrors['title'] = 'Title cannot exceed 100 characters';
      }
      
      // Description validation
      final description = _descriptionController.text.trim();
      if (description.isEmpty) {
        _validationErrors['description'] = 'Description is required';
      } else if (description.length < 10) {
        _validationErrors['description'] = 'Description must be at least 10 characters long';
      } else if (description.length > 1000) {
        _validationErrors['description'] = 'Description cannot exceed 1000 characters';
      }
      
      // Reward amount validation
      final rewardText = _rewardController.text.trim();
      if (rewardText.isEmpty) {
        _validationErrors['reward'] = 'Reward amount is required';
      } else {
        final reward = double.tryParse(rewardText);
        if (reward == null) {
          _validationErrors['reward'] = 'Reward amount must be a valid number';
        } else if (reward < 1) {
          _validationErrors['reward'] = 'Reward amount must be at least 1 KM';
        } else if (reward > 10000) {
          _validationErrors['reward'] = 'Reward amount cannot exceed 10,000 KM';
        }
      }
      
      // Points validation
      final pointsText = _pointsController.text.trim();
      if (pointsText.isEmpty) {
        _validationErrors['points'] = 'Reward points are required';
      } else {
        final points = int.tryParse(pointsText);
        if (points == null) {
          _validationErrors['points'] = 'Reward points must be a valid whole number';
        } else if (points < 10) {
          _validationErrors['points'] = 'Reward points must be at least 10';
        } else if (points > 100000) {
          _validationErrors['points'] = 'Reward points cannot exceed 100,000';
        }
      }
      
      // Location validation
      if (_selectedLocation == null && _locationsLoaded) {
        _validationErrors['location'] = 'Please select a location';
      }
    });
  }

  bool _canApprove() {
    _validateFields();
    return _validationErrors.isEmpty &&
           _titleController.text.trim().isNotEmpty &&
           _descriptionController.text.trim().length >= 10 &&
           double.tryParse(_rewardController.text.trim()) != null &&
           int.tryParse(_pointsController.text.trim()) != null &&
           _selectedLocation != null &&
           _locationsLoaded;
  }

  // Enhanced text field builder with better validation
  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    String fieldKey, {
    int maxLines = 1,
    int? maxLength,
    String? suffix,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    String? helperText,
  }) {
    final hasError = _validationErrors.containsKey(fieldKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (maxLength != null)
              Spacer(),
            if (maxLength != null)
              Text(
                '${controller.text.length}/$maxLength',
                style: TextStyle(
                  fontSize: 12,
                  color: controller.text.length > maxLength * 0.9
                     ? Colors.orange[600]
                     : Colors.grey[600],
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? Colors.red[400]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? Colors.red[600]! : Colors.blue[600]!, 
                width: 2
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? Colors.red[400]! : Colors.grey[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixText: suffix,
            filled: true,
            fillColor: hasError ? Colors.red[50] : Colors.grey[50],
            helperText: helperText,
            helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
            counterText: '', // Hide default counter
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _validationErrors[fieldKey]!,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.availableHeight,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header - Fixed at top
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
                  onPressed: widget.onBack,
                ),
                SizedBox(width: 8),
                Icon(Icons.assignment, color: Colors.blue[600], size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.request.title ?? 'Request Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Pending Review',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Images and controls
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(right: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.45,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Images',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),
                          // 2x2 Image grid
                          Container(
                            height: 240,
                            child: _buildImageGrid(widget.request.photoUrls ?? []),
                          ),
                          SizedBox(height: 32),
                          // Urgency and Amount selectors
                          _buildUrgencySelector(),
                          SizedBox(height: 24),
                          _buildAmountSelector(),
                          SizedBox(height: 32),
                          // Award section
                          _buildAwardSection(),
                          SizedBox(height: 32),
                          
                          // Validation Summary
                          if (_validationErrors.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.red[600], size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Please fix the following issues:',
                                        style: TextStyle(
                                          color: Colors.red[800],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  ...(_validationErrors.values.map((error) => Padding(
                                    padding: EdgeInsets.only(left: 28, bottom: 4),
                                    child: Text(
                                      '• $error',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ))),
                                ],
                              ),
                            ),
                          
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: (_isLoading || !_canApprove()) ? null : _approveRequest,
                                  icon: _isLoading
                                       ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Icon(Icons.check_circle, size: 20),
                                  label: Text(_isLoading ? 'Processing...' : 'Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _canApprove() ? Colors.green[600] : Colors.grey[400],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _denyRequest,
                                  icon: Icon(Icons.cancel, size: 20),
                                  label: Text('Deny'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[600],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right side - Form and map
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(left: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.45,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              'Title *', 
                              _titleController, 
                              'title',
                              maxLength: 100,
                              focusNode: _titleFocus,
                              helperText: 'Enter a clear, descriptive title',
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                              'Description *', 
                              _descriptionController, 
                              'description', 
                              maxLines: 4,
                              maxLength: 1000,
                              focusNode: _descriptionFocus,
                              helperText: 'Provide detailed information about the request',
                            ),
                            SizedBox(height: 20),
                            _buildLocationDropdown(),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: _buildTextField(
                                    'Reward Points *', 
                                    _pointsController, 
                                    'points',
                                    keyboardType: TextInputType.number,
                                    focusNode: _pointsFocus,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    helperText: 'Points to award (10-100,000)',
                                  ),
                                ),
                                SizedBox(width: 16),
                                Flexible(
                                  flex: 1,
                                  child: _buildTextField(
                                    'Reward Amount *', 
                                    _rewardController, 
                                    'reward', 
                                    suffix: 'KM',
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    focusNode: _rewardFocus,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                    helperText: 'Monetary reward (1-10,000 KM)',
                                  ),
                                ),
                              ],
                            ),
                            
                            // Cross-field validation error
                            if (_validationErrors.containsKey('proportion'))
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _validationErrors['proportion']!,
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            
                            SizedBox(height: 20),
                            Text(
                              'Location Map:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _selectedLocation != null
                                    ? OpenStreetMapWidget(
                                        latitude: _selectedLocation!.latitude,
                                        longitude: _selectedLocation!.longitude,
                                        locationName: _selectedLocation!.name ?? 'Selected Location',
                                      )
                                    : Container(
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                                              SizedBox(height: 8),
                                              Text(
                                                'Select location to view map',
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> images) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: index < images.length ? () => _showLargeImageViewer(images[index]) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: index < images.length
                  ? Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.grey[400], size: 32),
                              SizedBox(height: 4),
                              Text('Failed to load', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.grey[400], size: 32),
                          SizedBox(height: 4),
                          Text('No image', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgency Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: UrgencyLevel.values.map((level) {
            final isSelected = _selectedUrgency == level;
            Color getColor() {
              switch (level) {
                case UrgencyLevel.low: return Colors.green;
                case UrgencyLevel.medium: return Colors.orange;
                case UrgencyLevel.high: return Colors.red;
                case UrgencyLevel.critical: return Colors.purple;
              }
            }
            
            final color = getColor();
            
            return GestureDetector(
              onTap: () => setState(() => _selectedUrgency = level),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  level.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EstimatedAmount.values.map((amount) {
            final isSelected = _selectedAmount == amount;
            Color getColor() {
              switch (amount) {
                case EstimatedAmount.small: return Colors.green;
                case EstimatedAmount.medium: return Colors.blue;
                case EstimatedAmount.large: return Colors.orange;
                case EstimatedAmount.huge: return Colors.red;
              }
            }
            
            final color = getColor();
            
            return GestureDetector(
              onTap: () => setState(() => _selectedAmount = amount),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  amount.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAwardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Award And Price Suggestion',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.blue[600], size: 32),
                    SizedBox(height: 8),
                    Text('Price', style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text(
                      '${_rewardController.text} KM',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[50]!, Colors.green[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.stars, color: Colors.green[600], size: 32),
                    SizedBox(height: 8),
                    Text('Points', style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text(
                      '${_pointsController.text} pts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

Widget _buildLocationDropdown() {
  final hasError = _validationErrors.containsKey('location');
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Location *',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 8),
      DropdownButtonFormField<LocationResponse>(
        value: _selectedLocation,
        style: TextStyle(fontSize: 14, color: Colors.black87),
        isExpanded: true,  // Add this line to make the dropdown expand
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hasError ? Colors.red[400]! : Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hasError ? Colors.red[600]! : Colors.blue[600]!, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: hasError ? Colors.red[400]! : Colors.grey[300]!),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: hasError ? Colors.red[50] : Colors.grey[50],
          helperText: 'Select the location for this request',
          helperStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        items: _locations.map((location) {
          return DropdownMenuItem<LocationResponse>(
            value: location,
            child: Text(
              location.name ?? 'Location ${location.id}',
              overflow: TextOverflow.ellipsis,  // Add text overflow handling
            ),
          );
        }).toList(),
        onChanged: (LocationResponse? newValue) {
          setState(() {
            _selectedLocation = newValue;
            if (newValue != null) {
              _validationErrors.remove('location');
            }
          });
        },
      ),
      if (hasError)
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
              SizedBox(width: 4),
              Expanded(  // Ensure error text doesn't overflow
                child: Text(
                  _validationErrors['location']!,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

  void _showLargeImageViewer(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => LargeImageViewer(
        imageUrl: imageUrl,
        allImages: widget.request.photoUrls,
      ),
    );
  }

   void _approveRequest() async {
    if (!_canApprove()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please fix all validation errors before approving'),
            ],
          ),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<RequestProvider>(context, listen: false);
      
      // Create update request - make sure all required fields are included
      final updateRequest = RequestUpdateRequest(
        id: widget.request.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        locationId: _selectedLocation?.id,
        urgencyLevel: _selectedUrgency,
        estimatedAmount: _selectedAmount,
        statusId: 2, // Approved status
        actualRewardPoints: int.tryParse(_pointsController.text.trim()) ?? widget.request.actualRewardPoints,
        actualRewardMoney: double.tryParse(_rewardController.text.trim()) ?? widget.request.actualRewardMoney,
        approvedAt: DateTime.now(),
        // Include wasteTypeId to maintain referential integrity
        wasteTypeId: widget.request.wasteTypeId,
      );
      
      print('Sending approve request with data: ${updateRequest.toJson()}');
      
      await provider.update(widget.request.id, updateRequest);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Request approved successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
          ),
        );
        
        widget.onBack();
      }
    } catch (e) {
      String errorMessage = 'Error approving request: ${e.toString()}';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 5),
          ),
        );
      }
      
      print('Detailed error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _denyRequest() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Deny Request'),
      content: Text('Are you sure you want to deny this request? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
          child: Text('Deny', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  
  if (confirmed != true) return;
  
  setState(() => _isLoading = true);
  
  try {
    final provider = Provider.of<RequestProvider>(context, listen: false);
    
    final updateRequest = RequestUpdateRequest(
      id: widget.request.id,
      statusId: 3, // Denied status
      rejectionReason: 'Denied by admin',
      wasteTypeId: widget.request.wasteTypeId,
      locationId: widget.request.locationId, // Add this line
    );
    
    print('Sending deny request with data: ${updateRequest.toJson()}');
    
    await provider.update(widget.request.id, updateRequest);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 8),
              Text('Request denied successfully'),
            ],
          ),
          backgroundColor: Colors.orange[600],
        ),
      );
      
      widget.onBack();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error denying request: ${e.toString()}'),
            ],
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    }
    print('Detailed error: $e');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _pointsController.dispose();
    
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _rewardFocus.dispose();
    _pointsFocus.dispose();
    
    super.dispose();
  }
}
