import 'dart:io';
import 'package:ecochallenge_desktop/providers/admin_auth_provider.dart';
import 'package:ecochallenge_desktop/providers/request_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/request_participation.dart';
import '../models/gallery_showcase.dart';
import '../providers/request_participation_provider.dart';
import '../providers/gallery_showcase_provider.dart';
import '../widgets/large_image_viewer.dart';

class PaymentApprovalWidget extends StatefulWidget {
  final RequestParticipationResponse payment;
  final VoidCallback onBack;
  final double availableHeight;

  const PaymentApprovalWidget({
    Key? key,
    required this.payment,
    required this.onBack,
    required this.availableHeight,
  }) : super(key: key);

  @override
  _PaymentApprovalWidgetState createState() => _PaymentApprovalWidgetState();
}

class _PaymentApprovalWidgetState extends State<PaymentApprovalWidget> {
  late TextEditingController _cardHolderController;
  late TextEditingController _bankNameController;
  late TextEditingController _transactionController;
  late TextEditingController _reasonController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  bool _isLoading = false;
  
  // Gallery selection
  String? _selectedBeforeImage;
  String? _selectedAfterImage;
  
  // Validation errors
  Map<String, String> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _cardHolderController = TextEditingController(text: widget.payment.cardHolderName ?? '');
    _bankNameController = TextEditingController(text: widget.payment.bankName ?? '');
    _transactionController = TextEditingController(text: widget.payment.transactionNumber ?? '');
    _reasonController = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    // Add listeners to update UI when text changes
    _cardHolderController.addListener(_onFormChanged);
    _bankNameController.addListener(_onFormChanged);
    _transactionController.addListener(_onFormChanged);
    _reasonController.addListener(_onFormChanged);
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  // This method is called whenever any text field changes
  void _onFormChanged() {
    setState(() {
      // The setState will trigger a rebuild and recalculate button states
    });
  }

  bool _canApprove() {
    return _cardHolderController.text.trim().isNotEmpty &&
           _bankNameController.text.trim().isNotEmpty &&
           _transactionController.text.trim().isNotEmpty;
  }

  bool _canDeny() {
    return _reasonController.text.trim().isNotEmpty;
  }

  bool _canPost() {
    return _selectedBeforeImage != null && 
           _selectedAfterImage != null && 
           _titleController.text.trim().isNotEmpty &&
           _titleController.text.trim().length >= 3;
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.payment.photoUrls ?? [];
    final beforeImages = images.take((images.length / 2).ceil()).toList();
    final proofImages = images.skip((images.length / 2).ceil()).toList();
    
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
                  icon: Icon(Icons.arrow_back, color: Colors.green[600]),
                  onPressed: widget.onBack,
                ),
                SizedBox(width: 8),
                Icon(Icons.payment, color: Colors.green[600], size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment Approval #${widget.payment.id}',
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
                    'Pending Approval',
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
              child: Container(
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
                padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Before and Proof sections - Large images side by side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.photo_library, color: Colors.blue[600], size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Before',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: 280,
                                child: _buildLargeImageGrid(beforeImages, true),
                              ),
                              if (_validationErrors.containsKey('beforeImage'))
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    _validationErrors['beforeImage']!,
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
                        SizedBox(width: 40),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.verified, color: Colors.green[600], size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Proof',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Container(
                                height: 280,
                                child: _buildLargeImageGrid(proofImages, false),
                              ),
                              if (_validationErrors.containsKey('afterImage'))
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    _validationErrors['afterImage']!,
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
                    ),
                    SizedBox(height: 40),
                    
                    // Gallery section - Redesigned
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple[50]!, Colors.purple[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple[600],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.collections, color: Colors.white, size: 20),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Gallery Post',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              Spacer(),
                              ElevatedButton.icon(
                                onPressed: _canPost() ? _postToGallery : null,
                                icon: Icon(Icons.publish, size: 18),
                                label: Text('Post to Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _canPost() ? Colors.black87 : Colors.grey[400],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: _canPost() ? 2 : 0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          
                          // Title and Description fields
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField('Gallery Title', _titleController, 'title'),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField('Gallery Description', _descriptionController, 'description'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          
                          Text(
                            'Select one before and one proof image to post to gallery',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              // Selected before image
                              Expanded(
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedBeforeImage != null ? Colors.blue[600]! : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[200]!),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: _selectedBeforeImage != null
                                              ? Image.network(_selectedBeforeImage!, fit: BoxFit.cover)
                                              : Container(
                                                  color: Colors.grey[100],
                                                  child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 32),
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Before Image',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _selectedBeforeImage != null ? 'Selected' : 'Not selected',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              // Selected after image
                              Expanded(
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _selectedAfterImage != null ? Colors.green[600]! : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[200]!),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: _selectedAfterImage != null
                                              ? Image.network(_selectedAfterImage!, fit: BoxFit.cover)
                                              : Container(
                                                  color: Colors.grey[100],
                                                  child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 32),
                                                ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Proof Image',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _selectedAfterImage != null ? 'Selected' : 'Not selected',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // Payment information - Enhanced design
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo[50]!, Colors.indigo[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.indigo[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo[600],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.account_balance, color: Colors.white, size: 20),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Payment Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField('Card Holder Name', _cardHolderController, 'cardHolder'),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: _buildTextField('Bank Name', _bankNameController, 'bankName'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          _buildTextField('Card Transaction Number', _transactionController, 'transaction'),
                          SizedBox(height: 20),
                          _buildTextField('Reason for Decision', _reasonController, 'reason', maxLines: 4),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    
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
                    
                    // Action buttons - Enhanced design
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (_isLoading || !_canApprove()) ? null : _approvePayment,
                              icon: _isLoading 
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Icon(Icons.check_circle, size: 20),
                              label: Text(
                                _isLoading ? 'Processing...' : 'Approve Payment',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canApprove() ? Colors.green[600] : Colors.grey[400],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: _canApprove() ? 2 : 0,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (_isLoading || !_canDeny()) ? null : _denyPayment,
                              icon: Icon(Icons.cancel, size: 20),
                              label: Text(
                                'Deny Payment',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _canDeny() ? Colors.red[600] : Colors.grey[400],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: _canDeny() ? 2 : 0,
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
          ),
        ],
      ),
    );
  }

  Widget _buildLargeImageGrid(List<String> images, bool isBefore) {
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
        final hasImage = index < images.length;
        final imageUrl = hasImage ? images[index] : null;
        final isSelected = isBefore 
            ? _selectedBeforeImage == imageUrl
            : _selectedAfterImage == imageUrl;
        
        return GestureDetector(
          onTap: hasImage ? () {
            setState(() {
              if (isBefore) {
                _selectedBeforeImage = isSelected ? null : imageUrl;
              } else {
                _selectedAfterImage = isSelected ? null : imageUrl;
              }
              // Clear validation errors when user makes selection
              if (isBefore && _selectedBeforeImage != null) {
                _validationErrors.remove('beforeImage');
              }
              if (!isBefore && _selectedAfterImage != null) {
                _validationErrors.remove('afterImage');
              }
            });
          } : null,
          onLongPress: hasImage ? () => _showLargeImageViewer(imageUrl!) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? (isBefore ? Colors.blue[600]! : Colors.green[600]!)
                    : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? (isBefore ? Colors.blue : Colors.green).withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 8 : 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                children: [
                  if (hasImage)
                    Image.network(
                      imageUrl!,
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
                              SizedBox(height: 8),
                              Text('Failed to load', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.grey[400], size: 32),
                          SizedBox(height: 8),
                          Text('No image', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isBefore ? Colors.blue[600] : Colors.green[600],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String fieldKey, {int maxLines = 1}) {
    final hasError = _validationErrors.containsKey(fieldKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14),
          onChanged: (value) {
            // Clear validation error when user starts typing
            if (hasError && value.trim().isNotEmpty) {
              setState(() {
                _validationErrors.remove(fieldKey);
              });
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? Colors.red[400]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? Colors.red[600]! : Colors.indigo[600]!, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? Colors.red[400]! : Colors.grey[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: hasError ? Colors.red[50] : Colors.white,
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4),
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
    );
  }

  // Download image from URL and convert to File
  Future<File> _downloadImageAsFile(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    
    // Create a temporary file
    final tempDir = Directory.systemTemp;
    final fileName = imageUrl.split('/').last.split('?').first;
    final file = File('${tempDir.path}/$fileName');
    
    await file.writeAsBytes(bytes);
    return file;
  }

 void _postToGallery() async {
  
  if (!_canPost()) {
    return;
  }

  try {
    setState(() => _isLoading = true);
    
    final galleryProvider = Provider.of<GalleryShowcaseProvider>(context, listen: false);
    final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    
    // Get logged-in user
    final loggedInUser = authProvider.userData;
    if (loggedInUser == null) {
      throw Exception('No user logged in');
    }
    
    // Get the full request details to access locationId
    final request = await requestProvider.getById(widget.payment.requestId);
    final requestLocationId = request.locationId;
    
    // Download selected images as files
    final beforeImageFile = await _downloadImageAsFile(_selectedBeforeImage!);
    final afterImageFile = await _downloadImageAsFile(_selectedAfterImage!);
    
    // Create gallery showcase request with user and location
    final galleryRequest = GalleryShowcaseInsertRequest(
      requestId: widget.payment.requestId,
      locationId: requestLocationId,
      createdByAdminId: loggedInUser.id,
      beforeImage: beforeImageFile,
      afterImage: afterImageFile,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      isFeatured: false,
    );
    
    // Post to gallery
    await galleryProvider.createWithImages(galleryRequest);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.photo_library, color: Colors.white),
            SizedBox(width: 8),
            Text('Images posted to gallery: "${_titleController.text}"'),
          ],
        ),
        backgroundColor: Colors.green[600],
      ),
    );
    
    // Clear selections and form after posting
    setState(() {
      _selectedBeforeImage = null;
      _selectedAfterImage = null;
      _titleController.clear();
      _descriptionController.clear();
      _validationErrors.clear();
    });
    
    // Clean up temporary files
    await beforeImageFile.delete();
    await afterImageFile.delete();
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('Error posting to gallery: $e'),
          ],
        ),
        backgroundColor: Colors.red[600],
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _showLargeImageViewer(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => LargeImageViewer(
        imageUrl: imageUrl,
        allImages: widget.payment.photoUrls,
      ),
    );
  }

  void _approvePayment() async {
    
    if (!_canApprove()) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<RequestParticipationProvider>(context, listen: false);
      
      final updateRequest = RequestParticipationUpdateRequest(
        id: widget.payment.id,
        status: ParticipationStatus.approved,
        cardHolderName: _cardHolderController.text.trim(),
        bankName: _bankNameController.text.trim(),
        transactionNumber: _transactionController.text.trim(),
        adminNotes: _reasonController.text.trim().isNotEmpty ? _reasonController.text.trim() : null,
        approvedAt: DateTime.now(),
      );
      
      await provider.updateWithFormData(widget.payment.id, updateRequest);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Payment approved successfully'),
            ],
          ),
          backgroundColor: Colors.green[600],
        ),
      );
      
      widget.onBack();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error approving payment: $e'),
            ],
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _denyPayment() async {
    
    if (!_canDeny()) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<RequestParticipationProvider>(context, listen: false);
      
      final updateRequest = RequestParticipationUpdateRequest(
        id: widget.payment.id,
        status: ParticipationStatus.rejected,
        rejectionReason: _reasonController.text.trim(),
        adminNotes: _reasonController.text.trim(),
      );
      
      await provider.updateWithFormData(widget.payment.id, updateRequest);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 8),
              Text('Payment denied successfully'),
            ],
          ),
          backgroundColor: Colors.orange[600],
        ),
      );
      
      widget.onBack();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error denying payment: $e'),
            ],
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _cardHolderController.removeListener(_onFormChanged);
    _bankNameController.removeListener(_onFormChanged);
    _transactionController.removeListener(_onFormChanged);
    _reasonController.removeListener(_onFormChanged);
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    
    // Dispose controllers
    _cardHolderController.dispose();
    _bankNameController.dispose();
    _transactionController.dispose();
    _reasonController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}