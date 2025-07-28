import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/user_type.dart';
import 'package:ecochallenge_desktop/models/location.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/models/badge.dart';

class FilterWidget extends StatefulWidget {
  final String entityType;
  final List<UserType> userTypes;
  final List<UserResponse> users;
  final List<BadgeResponse> badges;
  final Function(Map<String, dynamic>) onFilterChanged;
  final Map<String, dynamic> currentFilters;

  const FilterWidget({
    Key? key,
    required this.entityType,
    required this.userTypes,
    this.users = const [],
    this.badges = const [],
    required this.onFilterChanged,
    required this.currentFilters,
  }) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late TextEditingController _textController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;


  bool? _selectedIsVerified;

  int? _selectedUserTypeId;
  bool? _selectedIsActive;
  int? _selectedBadgeTypeId;
  LocationType? _selectedLocationType;
  int? _selectedUserId;
  int? _selectedBadgeId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentFilters['text']);
    _cityController = TextEditingController(text: widget.currentFilters['city']);
    _countryController = TextEditingController(text: widget.currentFilters['country']);
    _nameController = TextEditingController(text: widget.currentFilters['name']);
    _categoryController = TextEditingController(text: widget.currentFilters['category']);
    _selectedUserTypeId = widget.currentFilters['userTypeId'];
    _selectedIsActive = widget.currentFilters['isActive'];
    _selectedIsVerified = widget.currentFilters['isVerified'];
    _selectedBadgeTypeId = widget.currentFilters['badgeTypeId'];
    _selectedUserId = widget.currentFilters['userId'];
    _selectedBadgeId = widget.currentFilters['badgeId'];
    
    // Handle dates
    if (widget.currentFilters['fromDate'] != null) {
      _fromDate = DateTime.parse(widget.currentFilters['fromDate']);
    }
    if (widget.currentFilters['toDate'] != null) {
      _toDate = DateTime.parse(widget.currentFilters['toDate']);
    }
    
    // Handle LocationType from int
    if (widget.currentFilters['locationType'] != null) {
      _selectedLocationType = LocationType.values[widget.currentFilters['locationType']];
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Map<String, dynamic> filters = {};
    
    if (widget.entityType == 'Users') {
      if (_textController.text.isNotEmpty) filters['text'] = _textController.text;
      if (_selectedUserTypeId != null) filters['userTypeId'] = _selectedUserTypeId;
      if (_selectedIsActive != null) filters['isActive'] = _selectedIsActive;
      if (_cityController.text.isNotEmpty) filters['city'] = _cityController.text;
      if (_countryController.text.isNotEmpty) filters['country'] = _countryController.text;
    } else if (widget.entityType == 'User Types') {
      if (_nameController.text.isNotEmpty) filters['name'] = _nameController.text;
    } else if (widget.entityType == 'Badges') {
      if (_nameController.text.isNotEmpty) filters['name'] = _nameController.text;
      if (_selectedBadgeTypeId != null) filters['badgeTypeId'] = _selectedBadgeTypeId;
    } else if (widget.entityType == 'Locations') {
      if (_nameController.text.isNotEmpty) filters['name'] = _nameController.text;
      if (_cityController.text.isNotEmpty) filters['city'] = _cityController.text;
      if (_countryController.text.isNotEmpty) filters['country'] = _countryController.text;
      if (_selectedLocationType != null) filters['locationType'] = _selectedLocationType!.index;
    } else if (widget.entityType == 'User Badges') {
      if (_selectedUserId != null) filters['userId'] = _selectedUserId;
      if (_selectedBadgeId != null) filters['badgeId'] = _selectedBadgeId;
      if (_fromDate != null) filters['fromDate'] = _fromDate!.toIso8601String();
      if (_toDate != null) filters['toDate'] = _toDate!.toIso8601String();
    } else if (widget.entityType == 'Waste Types') {
      if (_nameController.text.isNotEmpty) filters['name'] = _nameController.text;
    }
    else if (widget.entityType == 'Organizations') {
  if (_textController.text.isNotEmpty) filters['text'] = _textController.text;
  if (_categoryController.text.isNotEmpty) filters['category'] = _categoryController.text;
  if (_selectedIsVerified != null) filters['isVerified'] = _selectedIsVerified;
  if (_selectedIsActive != null) filters['isActive'] = _selectedIsActive;
} 
    
    widget.onFilterChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      _textController.clear();
      _cityController.clear();
      _countryController.clear();
      _nameController.clear();
      _selectedUserTypeId = null;
      _selectedIsActive = null;
      _selectedBadgeTypeId = null;
      _selectedLocationType = null;
      _selectedUserId = null;
      _selectedBadgeId = null;
      _fromDate = null;
      _toDate = null;
    });
    widget.onFilterChanged({});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filter by',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: Text('Clear All', style: TextStyle(fontSize: 12)),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size(0, 32),
                ),
                child: Text('Search', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (widget.entityType == 'Users') ..._buildUserFilters(),
          if (widget.entityType == 'User Types') ..._buildUserTypeFilters(),
          if (widget.entityType == 'Badges') ..._buildBadgeFilters(),
          if (widget.entityType == 'Locations') ..._buildLocationFilters(),
          if (widget.entityType == 'User Badges') ..._buildUserBadgeFilters(),
          if (widget.entityType == 'Waste Types') ..._buildWasteTypeFilters(),
          if (widget.entityType == 'Organizations') ..._buildOrganizationFilters(),
        ],
      ),
    );
  }

  List<Widget> _buildUserFilters() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Search text',
                  hintText: 'Search by name, email, username...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 11),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<int?>(
                value: _selectedUserTypeId,
                decoration: InputDecoration(
                  labelText: 'User Type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<int?>(
                    value: null, 
                    child: Text('All Types', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  ...widget.userTypes.map((userType) => DropdownMenuItem<int?>(
                    value: userType.id,
                    child: Text(userType.name, style: TextStyle(fontSize: 12, color: Colors.black87)),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUserTypeId = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<bool?>(
                value: _selectedIsActive,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<bool?>(
                    value: null, 
                    child: Text('All Status', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  DropdownMenuItem<bool?>(
                    value: true, 
                    child: Text('Active', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  DropdownMenuItem<bool?>(
                    value: false, 
                    child: Text('Inactive', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedIsActive = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: TextField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildUserTypeFilters() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Search by name...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 11),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Expanded(flex: 4, child: SizedBox()), // Empty space
        ],
      ),
    ];
  }

  List<Widget> _buildBadgeFilters() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Search by badge name...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 11),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<int?>(
                value: _selectedBadgeTypeId,
                decoration: InputDecoration(
                  labelText: 'Badge Type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<int?>(
                    value: null, 
                    child: Text('All Types', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  // Add badge types here when available
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBadgeTypeId = value;
                  });
                },
              ),
            ),
          ),
          Expanded(flex: 3, child: SizedBox()), // Empty space
        ],
      ),
    ];
  }

  List<Widget> _buildLocationFilters() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Search by location name...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 11),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: TextField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<LocationType?>(
                value: _selectedLocationType,
                decoration: InputDecoration(
                  labelText: 'Location Type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<LocationType?>(
                    value: null, 
                    child: Text('All Types', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  ...LocationType.values.map((type) => DropdownMenuItem<LocationType?>(
                    value: type,
                    child: Text(type.displayName, style: TextStyle(fontSize: 12, color: Colors.black87)),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLocationType = value;
                  });
                },
              ),
            ),
          ),
          Expanded(child: SizedBox()), // Empty space
        ],
      ),
    ];
  }

  List<Widget> _buildUserBadgeFilters() {
    return [
      Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<int?>(
                value: _selectedUserId,
                decoration: InputDecoration(
                  labelText: 'User',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<int?>(
                    value: null, 
                    child: Text('All Users', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  ...widget.users.map((user) => DropdownMenuItem<int?>(
                    value: user.id,
                    child: Text('${user.firstName} ${user.lastName}', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<int?>(
                value: _selectedBadgeId,
                decoration: InputDecoration(
                  labelText: 'Badge',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<int?>(
                    value: null, 
                    child: Text('All Badges', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  ...widget.badges.map((badge) => DropdownMenuItem<int?>(
                    value: badge.id,
                    child: Text(badge.name ?? 'Badge ${badge.id}', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBadgeId = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: InkWell(
                onTap: () => _selectFromDate(),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    labelStyle: TextStyle(fontSize: 12),
                    suffixIcon: Icon(Icons.calendar_today, size: 16),
                  ),
                  child: Text(
                    _fromDate != null 
                        ? _fromDate!.toString().split(' ')[0]
                        : 'Select date',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: InkWell(
                onTap: () => _selectToDate(),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    labelStyle: TextStyle(fontSize: 12),
                    suffixIcon: Icon(Icons.calendar_today, size: 16),
                  ),
                  child: Text(
                    _toDate != null 
                        ? _toDate!.toString().split(' ')[0]
                        : 'Select date',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: SizedBox()), // Empty space
        ],
      ),
    ];
  }

  List<Widget> _buildWasteTypeFilters() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Search by waste type name...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 11),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Expanded(flex: 4, child: SizedBox()), // Empty space
        ],
      ),
    ];
  }
List<Widget> _buildOrganizationFilters() {
    return [
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Search text',
                  hintText: 'Search by name, email...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 11),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<bool?>(
                value: _selectedIsVerified,
                decoration: InputDecoration(
                  labelText: 'Verified',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<bool?>(
                    value: null, 
                    child: Text('All', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  DropdownMenuItem<bool?>(
                    value: true, 
                    child: Text('Verified', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  DropdownMenuItem<bool?>(
                    value: false, 
                    child: Text('Not Verified', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedIsVerified = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: DropdownButtonFormField<bool?>(
                value: _selectedIsActive,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelStyle: TextStyle(fontSize: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: TextStyle(fontSize: 12, color: Colors.black87),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem<bool?>(
                    value: null, 
                    child: Text('All Status', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  DropdownMenuItem<bool?>(
                    value: true, 
                    child: Text('Active', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                  DropdownMenuItem<bool?>(
                    value: false, 
                    child: Text('Inactive', style: TextStyle(fontSize: 12, color: Colors.black87))
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedIsActive = value;
                  });
                },
              ),
            ),
          ),
          Expanded(child: SizedBox()), // Empty space
        ],
      ),
    ];
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }
}