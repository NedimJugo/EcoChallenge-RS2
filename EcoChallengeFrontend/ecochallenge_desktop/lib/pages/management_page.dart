import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/models/user_type.dart';
import 'package:ecochallenge_desktop/models/search_result.dart';
import 'package:ecochallenge_desktop/models/search_objects.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';
import 'package:ecochallenge_desktop/providers/user_type_provider.dart';
import 'package:ecochallenge_desktop/widgets/crud_dialog.dart';
import 'package:ecochallenge_desktop/widgets/filter_widget.dart';
import 'package:ecochallenge_desktop/widgets/pagination_widget.dart';
import 'package:ecochallenge_desktop/models/badge.dart';
import 'package:ecochallenge_desktop/models/location.dart';
import 'package:ecochallenge_desktop/providers/badge_provider.dart';
import 'package:ecochallenge_desktop/providers/location_provider.dart';
import 'package:ecochallenge_desktop/models/user_badge.dart';
import 'package:ecochallenge_desktop/models/waste_type.dart';
import 'package:ecochallenge_desktop/providers/user_badge_provider.dart';
import 'package:ecochallenge_desktop/providers/waste_type_provider.dart';
import 'package:ecochallenge_desktop/models/organization.dart';
import 'package:ecochallenge_desktop/providers/organization_provider.dart';

class ManagementPage extends StatefulWidget {
  @override
  _ManagementPageState createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Users', 'User Types', 'Badges', 'Locations', 'User Badges', 'Waste Types', 'Organizations'];
  
  late UserProvider _userProvider;
  late UserTypeProvider _userTypeProvider;
  late BadgeProvider _badgeProvider;
  late LocationProvider _locationProvider;
  late UserBadgeProvider _userBadgeProvider;
  late WasteTypeProvider _wasteTypeProvider;
  late OrganizationProvider _organizationProvider;
  
  SearchResult<UserResponse>? _userResults;
  SearchResult<UserType>? _userTypeResults;
  SearchResult<BadgeResponse>? _badgeResults;
  SearchResult<LocationResponse>? _locationResults;
  SearchResult<UserBadgeResponse>? _userBadgeResults;
  SearchResult<WasteTypeResponse>? _wasteTypeResults;
  SearchResult<OrganizationResponse>? _organizationResults;
  List<UserType> _allUserTypes = [];
  List<UserResponse> _allUsers = [];
  List<BadgeResponse> _allBadges = [];
  
  bool _isLoading = false;
  
  // Pagination and filtering
  UserSearchObject _userSearchObject = UserSearchObject();
  UserTypeSearchObject _userTypeSearchObject = UserTypeSearchObject();
  BadgeSearchObject _badgeSearchObject = BadgeSearchObject();
  LocationSearchObject _locationSearchObject = LocationSearchObject();
  UserBadgeSearchObject _userBadgeSearchObject = UserBadgeSearchObject();
  WasteTypeSearchObject _wasteTypeSearchObject = WasteTypeSearchObject();
  OrganizationSearchObject _organizationSearchObject = OrganizationSearchObject();
  Map<String, dynamic> _currentFilters = {};
  String _currentSortColumn = 'Id';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _userProvider = UserProvider();
    _userTypeProvider = UserTypeProvider();
    _badgeProvider = BadgeProvider();
    _locationProvider = LocationProvider();
    _userBadgeProvider = UserBadgeProvider();
    _wasteTypeProvider = WasteTypeProvider();
    _organizationProvider = OrganizationProvider();
    _loadUserTypes();
    _loadUsers();
    _loadBadges();
    _loadData();
  }

  Future<void> _loadUserTypes() async {
    try {
      _allUserTypes = await _userTypeProvider.getAllUserTypes();
    } catch (e) {
      print('Error loading user types: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final result = await _userProvider.get();
      _allUsers = result.items ?? [];
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadBadges() async {
    try {
      final result = await _badgeProvider.get();
      _allBadges = result.items ?? [];
    } catch (e) {
      print('Error loading badges: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      if (_selectedTabIndex == 0) {
        _userResults = await _userProvider.get(filter: _userSearchObject.toJson());
      } else if (_selectedTabIndex == 1) {
        _userTypeResults = await _userTypeProvider.get(filter: _userTypeSearchObject.toJson());
      } else if (_selectedTabIndex == 2) {
        _badgeResults = await _badgeProvider.get(filter: _badgeSearchObject.toJson());
      } else if (_selectedTabIndex == 3) {
        _locationResults = await _locationProvider.get(filter: _locationSearchObject.toJson());
      } else if (_selectedTabIndex == 4) {
        _userBadgeResults = await _userBadgeProvider.get(filter: _userBadgeSearchObject.toJson());
      } else if (_selectedTabIndex == 5) {
        _wasteTypeResults = await _wasteTypeProvider.get(filter: _wasteTypeSearchObject.toJson());
      } else if (_selectedTabIndex == 6) {
        _organizationResults = await _organizationProvider.get(filter: _organizationSearchObject.toJson());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onFilterChanged(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
      if (_selectedTabIndex == 0) {
        _userSearchObject = UserSearchObject(
          text: filters['text'],
          userTypeId: filters['userTypeId'],
          isActive: filters['isActive'],
          city: filters['city'],
          country: filters['country'],
          page: 0, // Reset to first page when filtering
          pageSize: _userSearchObject.pageSize,
          sortBy: _userSearchObject.sortBy,
          desc: _userSearchObject.desc,
        );
      } else if (_selectedTabIndex == 1) {
        _userTypeSearchObject = UserTypeSearchObject(
          name: filters['name'],
          page: 0, // Reset to first page when filtering
          pageSize: _userTypeSearchObject.pageSize,
          sortBy: _userTypeSearchObject.sortBy,
          desc: _userTypeSearchObject.desc,
        );
      } else if (_selectedTabIndex == 2) {
        _badgeSearchObject = BadgeSearchObject(
          name: filters['name'],
          badgeTypeId: filters['badgeTypeId'],
          page: 0,
          pageSize: _badgeSearchObject.pageSize,
          sortBy: _badgeSearchObject.sortBy,
          desc: _badgeSearchObject.desc,
        );
      } else if (_selectedTabIndex == 3) {
        _locationSearchObject = LocationSearchObject(
          name: filters['name'],
          city: filters['city'],
          country: filters['country'],
          locationType: filters['locationType'],
          page: 0,
          pageSize: _locationSearchObject.pageSize,
          sortBy: _locationSearchObject.sortBy,
          desc: _locationSearchObject.desc,
        );
      } else if (_selectedTabIndex == 4) {
        _userBadgeSearchObject = UserBadgeSearchObject(
          userId: filters['userId'],
          badgeId: filters['badgeId'],
          fromDate: filters['fromDate'] != null ? DateTime.parse(filters['fromDate']) : null,
          toDate: filters['toDate'] != null ? DateTime.parse(filters['toDate']) : null,
          page: 0,
          pageSize: _userBadgeSearchObject.pageSize,
          sortBy: _userBadgeSearchObject.sortBy,
          desc: _userBadgeSearchObject.desc,
        );
      } else if (_selectedTabIndex == 5) {
        _wasteTypeSearchObject = WasteTypeSearchObject(
          name: filters['name'],
          page: 0,
          pageSize: _wasteTypeSearchObject.pageSize,
          sortBy: _wasteTypeSearchObject.sortBy,
          desc: _wasteTypeSearchObject.desc,
        );
      } else if (_selectedTabIndex == 6) {
        _organizationSearchObject = OrganizationSearchObject(
          text: filters['text'],
          isVerified: filters['isVerified'],
          isActive: filters['isActive'],
          category: filters['category'],
          page: 0,
          pageSize: _organizationSearchObject.pageSize,
          sortBy: _organizationSearchObject.sortBy,
          desc: _organizationSearchObject.desc,
        );
      }
    });
    _loadData();
  }

  void _onPageChanged(int page) {
    setState(() {
      if (_selectedTabIndex == 0) {
        _userSearchObject.page = page;
      } else if (_selectedTabIndex == 1) {
        _userTypeSearchObject.page = page;
      } else if (_selectedTabIndex == 2) {
        _badgeSearchObject.page = page;
      } else if (_selectedTabIndex == 3) {
        _locationSearchObject.page = page;
      } else if (_selectedTabIndex == 4) {
        _userBadgeSearchObject.page = page;
      } else if (_selectedTabIndex == 5) {
        _wasteTypeSearchObject.page = page;
      } else if (_selectedTabIndex == 6) {
        _organizationSearchObject.page = page;
      }
    });
    _loadData();
  }

  void _onPageSizeChanged(int pageSize) {
    setState(() {
      if (_selectedTabIndex == 0) {
        _userSearchObject.pageSize = pageSize;
        _userSearchObject.page = 0; // Reset to first page
      } else if (_selectedTabIndex == 1) {
        _userTypeSearchObject.pageSize = pageSize;
        _userTypeSearchObject.page = 0; // Reset to first page
      } else if (_selectedTabIndex == 2) {
        _badgeSearchObject.pageSize = pageSize;
        _badgeSearchObject.page = 0;
      } else if (_selectedTabIndex == 3) {
        _locationSearchObject.pageSize = pageSize;
        _locationSearchObject.page = 0;
      } else if (_selectedTabIndex == 4) {
        _userBadgeSearchObject.pageSize = pageSize;
        _userBadgeSearchObject.page = 0;
      } else if (_selectedTabIndex == 5) {
        _wasteTypeSearchObject.pageSize = pageSize;
        _wasteTypeSearchObject.page = 0;
      } else if (_selectedTabIndex == 6) {
        _organizationSearchObject.pageSize = pageSize;
        _organizationSearchObject.page = 0;
      }
    });
    _loadData();
  }

  void _onSort(String column) {
    setState(() {
      if (_currentSortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _currentSortColumn = column;
        _sortAscending = true;
      }
      
      if (_selectedTabIndex == 0) {
        _userSearchObject.sortBy = column;
        _userSearchObject.desc = !_sortAscending;
      } else if (_selectedTabIndex == 1) {
        _userTypeSearchObject.sortBy = column;
        _userTypeSearchObject.desc = !_sortAscending;
      } else if (_selectedTabIndex == 2) {
        _badgeSearchObject.sortBy = column;
        _badgeSearchObject.desc = !_sortAscending;
      } else if (_selectedTabIndex == 3) {
        _locationSearchObject.sortBy = column;
        _locationSearchObject.desc = !_sortAscending;
      } else if (_selectedTabIndex == 4) {
        _userBadgeSearchObject.sortBy = column;
        _userBadgeSearchObject.desc = !_sortAscending;
      } else if (_selectedTabIndex == 5) {
        _wasteTypeSearchObject.sortBy = column;
        _wasteTypeSearchObject.desc = !_sortAscending;
      } else if (_selectedTabIndex == 6) {
        _organizationSearchObject.sortBy = column;
        _organizationSearchObject.desc = !_sortAscending;
      }
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          _buildFilterSection(),
          _buildContent(),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(),
            icon: Icon(Icons.add),
            label: Text('Add ${_tabs[_selectedTabIndex]}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Text('View table', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 16),
          ...List.generate(_tabs.length, (index) {
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_tabs[index]),
                selected: _selectedTabIndex == index,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTabIndex = index;
                      _currentFilters = {};
                    });
                    _loadData();
                  }
                },
                selectedColor: Colors.orange.withOpacity(0.2),
                backgroundColor: Colors.grey.withOpacity(0.1),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return FilterWidget(
      entityType: _tabs[_selectedTabIndex],
      userTypes: _allUserTypes,
      users: _allUsers,
      badges: _allBadges,
      onFilterChanged: _onFilterChanged,
      currentFilters: _currentFilters,
    );
  }

  Widget _buildContent() {
  return Expanded(
    child: Container(
      color: Colors.white,
      child: _selectedTabIndex == 0 ? _buildUsersTable() 
      : _selectedTabIndex == 1 ? _buildUserTypesTable()
      : _selectedTabIndex == 2 ? _buildBadgesTable()
      : _selectedTabIndex == 3 ? _buildLocationsTable()
      : _selectedTabIndex == 4 ? _buildUserBadgesTable()
      : _selectedTabIndex == 5 ? _buildWasteTypesTable()
      : _selectedTabIndex == 6 ? _buildOrganizationsTable()
      : _buildWasteTypesTable(),
    ),
  );
}

  Widget _buildUsersTable() {
  if (_userResults == null || _userResults!.items == null || _userResults!.items!.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 16,
            sortColumnIndex: _getUserColumnIndex(_currentSortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Id'),
              ),
              DataColumn(
                label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Username'),
              ),
              DataColumn(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('FirstName'),
              ),
              DataColumn(
                label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Email'),
              ),
              DataColumn(
                label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              DataColumn(
                label: Text('City', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('City'),
              ),
              DataColumn(
                label: Text('Country', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Country'),
              ),
              DataColumn(
                label: Text('User Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              DataColumn(
                label: Text('Points', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('TotalPoints'),
                numeric: true,
              ),
              DataColumn(
                label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('IsActive'),
              ),
              DataColumn(
                label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('CreatedAt'),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
            rows: _userResults!.items!.map((user) {
              return DataRow(cells: [
                DataCell(Text(user.id.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(user.username, style: TextStyle(fontSize: 11))),
                DataCell(Text('${user.firstName} ${user.lastName}', style: TextStyle(fontSize: 11))),
                DataCell(Text(user.email, style: TextStyle(fontSize: 11))),
                DataCell(Text(user.phoneNumber ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(user.city ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(user.country ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(user.userTypeName ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(user.totalPoints.toString(), style: TextStyle(fontSize: 11))),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: user.isActive ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: user.isActive ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(user.createdAt.toString().split(' ')[0], style: TextStyle(fontSize: 11))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.white, size: 12),
                        onPressed: () => _showViewDialog(user),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 12),
                        onPressed: () => _showEditUserDialog(user),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 12),
                        onPressed: () => _showDeleteConfirmation(() => _deleteUser(user.id)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildUserTypesTable() {
  if (_userTypeResults == null || _userTypeResults!.items == null || _userTypeResults!.items!.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No user types found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 16,
            sortColumnIndex: _getUserTypeColumnIndex(_currentSortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Id'),
              ),
              DataColumn(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Name'),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
            rows: _userTypeResults!.items!.map((userType) {
              return DataRow(cells: [
                DataCell(Text(userType.id.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(userType.name, style: TextStyle(fontSize: 11))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 12),
                        onPressed: () => _showEditUserTypeDialog(userType),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 12),
                        onPressed: () => _showDeleteConfirmation(() => _deleteUserType(userType.id)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

Widget _buildBadgesTable() {
  if (_badgeResults == null || _badgeResults!.items == null || _badgeResults!.items!.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No badges found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 16,
            sortColumnIndex: _getBadgeColumnIndex(_currentSortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Id'),
              ),
              DataColumn(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Name'),
              ),
              DataColumn(
                label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              DataColumn(
                label: Text('Badge Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              DataColumn(
                label: Text('Criteria Value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                numeric: true,
              ),
              DataColumn(
                label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('IsActive'),
              ),
              DataColumn(
                label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('CreatedAt'),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
            rows: _badgeResults!.items!.map((badge) {
              return DataRow(cells: [
                DataCell(Text(badge.id.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(badge.name ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(badge.description ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(badge.badgeTypeId.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(badge.criteriaValue.toString(), style: TextStyle(fontSize: 11))),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badge.isActive ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: badge.isActive ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(badge.createdAt.toString().split(' ')[0], style: TextStyle(fontSize: 11))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.white, size: 12),
                        onPressed: () => _showViewBadgeDialog(badge),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 12),
                        onPressed: () => _showEditBadgeDialog(badge),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 12),
                        onPressed: () => _showDeleteConfirmation(() => _deleteBadge(badge.id)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

Widget _buildLocationsTable() {
  if (_locationResults == null || _locationResults!.items == null || _locationResults!.items!.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No locations found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 16,
            sortColumnIndex: _getLocationColumnIndex(_currentSortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Id'),
              ),
              DataColumn(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Name'),
              ),
              DataColumn(
                label: Text('City', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('City'),
              ),
              DataColumn(
                label: Text('Country', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Country'),
              ),
              DataColumn(
                label: Text('Latitude', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                numeric: true,
              ),
              DataColumn(
                label: Text('Longitude', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                numeric: true,
              ),
              DataColumn(
                label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              DataColumn(
                label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('CreatedAt'),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
            rows: _locationResults!.items!.map((location) {
              return DataRow(cells: [
                DataCell(Text(location.id.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(location.name ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(location.city ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(location.country ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(location.latitude.toStringAsFixed(6), style: TextStyle(fontSize: 11))),
                DataCell(Text(location.longitude.toStringAsFixed(6), style: TextStyle(fontSize: 11))),
                DataCell(Text(location.locationType.displayName, style: TextStyle(fontSize: 11))),
                DataCell(Text(location.createdAt.toString().split(' ')[0], style: TextStyle(fontSize: 11))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.white, size: 12),
                        onPressed: () => _showViewLocationDialog(location),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 12),
                        onPressed: () => _showEditLocationDialog(location),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 12),
                        onPressed: () => _showDeleteConfirmation(() => _deleteLocation(location.id)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

Widget _buildUserBadgesTable() {
  if (_userBadgeResults == null || _userBadgeResults!.items == null || _userBadgeResults!.items!.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No user badges found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 16,
            sortColumnIndex: _getUserBadgeColumnIndex(_currentSortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Id'),
              ),
              DataColumn(
                label: Text('User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              DataColumn(
                label: Text('Badge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              DataColumn(
                label: Text('Earned At', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('EarnedAt'),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
            rows: _userBadgeResults!.items!.map((userBadge) {
              return DataRow(cells: [
                DataCell(Text(userBadge.id.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(userBadge.userId.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(userBadge.badgeId.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(userBadge.earnedAt.toString().split(' ')[0], style: TextStyle(fontSize: 11))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.white, size: 12),
                        onPressed: () => _showViewUserBadgeDialog(userBadge),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 12),
                        onPressed: () => _showEditUserBadgeDialog(userBadge),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 12),
                        onPressed: () => _showDeleteConfirmation(() => _deleteUserBadge(userBadge.id)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

Widget _buildWasteTypesTable() {
  if (_wasteTypeResults == null || _wasteTypeResults!.items == null || _wasteTypeResults!.items!.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No waste types found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 16,
            sortColumnIndex: _getWasteTypeColumnIndex(_currentSortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Id'),
              ),
              DataColumn(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Name'),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
            rows: _wasteTypeResults!.items!.map((wasteType) {
              return DataRow(cells: [
                DataCell(Text(wasteType.id.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(wasteType.name, style: TextStyle(fontSize: 11))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 12),
                        onPressed: () => _showEditWasteTypeDialog(wasteType),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 12),
                        onPressed: () => _showDeleteConfirmation(() => _deleteWasteType(wasteType.id)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

Widget _buildOrganizationsTable() {
  if (_organizationResults == null || _organizationResults!.items == null || _organizationResults!.items!.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No organizations found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  return Scrollbar(
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 16,
            sortColumnIndex: _getOrganizationColumnIndex(_currentSortColumn),
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Id'),
              ),
              DataColumn(
                label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Name'),
              ),
              DataColumn(
                label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('Category'),
              ),
              DataColumn(
                label: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('IsVerified'),
              ),
              DataColumn(
                label: Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onSort: (columnIndex, ascending) => _onSort('IsActive'),
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
            rows: _organizationResults!.items!.map((organization) {
              return DataRow(cells: [
                DataCell(Text(organization.id.toString(), style: TextStyle(fontSize: 11))),
                DataCell(Text(organization.name ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(Text(organization.category ?? 'N/A', style: TextStyle(fontSize: 11))),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: organization.isVerified ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      organization.isVerified ? 'Verified' : 'Unverified',
                      style: TextStyle(
                        color: organization.isVerified ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: organization.isActive ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      organization.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: organization.isActive ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.white, size: 12),
                        onPressed: () => _showViewOrganizationDialog(organization),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 12),
                        onPressed: () => _showEditOrganizationDialog(organization),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 12),
                        onPressed: () => _showDeleteConfirmation(() => _deleteOrganization(organization.id)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPagination() {
    if (_selectedTabIndex == 0 && _userResults != null) {
      final totalPages = ((_userResults!.totalCount ?? 0) / (_userSearchObject.pageSize ?? 20)).ceil();
      return PaginationWidget(
        currentPage: _userSearchObject.page ?? 0,
        totalPages: totalPages,
        totalItems: _userResults!.totalCount ?? 0,
        pageSize: _userSearchObject.pageSize ?? 20,
        onPageChanged: _onPageChanged,
        onPageSizeChanged: _onPageSizeChanged,
      );
    } else if (_selectedTabIndex == 1 && _userTypeResults != null) {
      final totalPages = ((_userTypeResults!.totalCount ?? 0) / (_userTypeSearchObject.pageSize ?? 20)).ceil();
      return PaginationWidget(
        currentPage: _userTypeSearchObject.page ?? 0,
        totalPages: totalPages,
        totalItems: _userTypeResults!.totalCount ?? 0,
        pageSize: _userTypeSearchObject.pageSize ?? 20,
        onPageChanged: _onPageChanged,
        onPageSizeChanged: _onPageSizeChanged,
      );
    } else if (_selectedTabIndex == 2 && _badgeResults != null) {
      final totalPages = ((_badgeResults!.totalCount ?? 0) / (_badgeSearchObject.pageSize ?? 20)).ceil();
      return PaginationWidget(
        currentPage: _badgeSearchObject.page ?? 0,
        totalPages: totalPages,
        totalItems: _badgeResults!.totalCount ?? 0,
        pageSize: _badgeSearchObject.pageSize ?? 20,
        onPageChanged: _onPageChanged,
        onPageSizeChanged: _onPageSizeChanged,
      );
    } else if (_selectedTabIndex == 3 && _locationResults != null) {
      final totalPages = ((_locationResults!.totalCount ?? 0) / (_locationSearchObject.pageSize ?? 20)).ceil();
      return PaginationWidget(
        currentPage: _locationSearchObject.page ?? 0,
        totalPages: totalPages,
        totalItems: _locationResults!.totalCount ?? 0,
        pageSize: _locationSearchObject.pageSize ?? 20,
        onPageChanged: _onPageChanged,
        onPageSizeChanged: _onPageSizeChanged,
      );
    } else if (_selectedTabIndex == 4 && _userBadgeResults != null) {
      final totalPages = ((_userBadgeResults!.totalCount ?? 0) / (_userBadgeSearchObject.pageSize ?? 20)).ceil();
      return PaginationWidget(
        currentPage: _userBadgeSearchObject.page ?? 0,
        totalPages: totalPages,
        totalItems: _userBadgeResults!.totalCount ?? 0,
        pageSize: _userBadgeSearchObject.pageSize ?? 20,
        onPageChanged: _onPageChanged,
        onPageSizeChanged: _onPageSizeChanged,
      );
    } else if (_selectedTabIndex == 5 && _wasteTypeResults != null) {
      final totalPages = ((_wasteTypeResults!.totalCount ?? 0) / (_wasteTypeSearchObject.pageSize ?? 20)).ceil();
      return PaginationWidget(
        currentPage: _wasteTypeSearchObject.page ?? 0,
        totalPages: totalPages,
        totalItems: _wasteTypeResults!.totalCount ?? 0,
        pageSize: _wasteTypeSearchObject.pageSize ?? 20,
        onPageChanged: _onPageChanged,
        onPageSizeChanged: _onPageSizeChanged,
      );
    } else if (_selectedTabIndex == 6 && _organizationResults != null) {
      final totalPages = ((_organizationResults!.totalCount ?? 0) / (_organizationSearchObject.pageSize ?? 20)).ceil();
      return PaginationWidget(
        currentPage: _organizationSearchObject.page ?? 0,
        totalPages: totalPages,
        totalItems: _organizationResults!.totalCount ?? 0,
        pageSize: _organizationSearchObject.pageSize ?? 20,
        onPageChanged: _onPageChanged,
        onPageSizeChanged: _onPageSizeChanged,
      );
    }
    return SizedBox.shrink();
  }

  int? _getUserColumnIndex(String column) {
    switch (column) {
      case 'Id': return 0;
      case 'Username': return 1;
      case 'FirstName': return 2;
      case 'Email': return 3;
      case 'City': return 5;
      case 'Country': return 6;
      case 'TotalPoints': return 8;
      case 'IsActive': return 9;
      case 'CreatedAt': return 10;
      default: return null;
    }
  }

  int? _getUserTypeColumnIndex(String column) {
    switch (column) {
      case 'Id': return 0;
      case 'Name': return 1;
      default: return null;
    }
  }

int? _getBadgeColumnIndex(String column) {
  switch (column) {
    case 'Id': return 0;
    case 'Name': return 1;
    case 'IsActive': return 5;
    case 'CreatedAt': return 6;
    default: return null;
  }
}

int? _getLocationColumnIndex(String column) {
  switch (column) {
    case 'Id': return 0;
    case 'Name': return 1;
    case 'City': return 2;
    case 'Country': return 3;
    case 'CreatedAt': return 7;
    default: return null;
  }
}

int? _getUserBadgeColumnIndex(String column) {
  switch (column) {
    case 'Id': return 0;
    case 'EarnedAt': return 3;
    default: return null;
  }
}

int? _getWasteTypeColumnIndex(String column) {
  switch (column) {
    case 'Id': return 0;
    case 'Name': return 1;
    default: return null;
  }
}

int? _getOrganizationColumnIndex(String column) {
  switch (column) {
    case 'Id': return 0;
    case 'Name': return 1;
    case 'Category': return 2;
    case 'IsVerified': return 3;
    case 'IsActive': return 4;
    default: return null;
  }
}

  void _showAddDialog() {
    if (_selectedTabIndex == 0) {
      _showEditUserDialog(null);
    } else if (_selectedTabIndex == 1) {
      _showEditUserTypeDialog(null);
    } else if (_selectedTabIndex == 2) {
      _showEditBadgeDialog(null);
    } else if (_selectedTabIndex == 3) {
      _showEditLocationDialog(null);
    } else if (_selectedTabIndex == 4) {
      _showEditUserBadgeDialog(null);
    } else if (_selectedTabIndex == 5) {
      _showEditWasteTypeDialog(null);
    } else if (_selectedTabIndex == 6) {
      _showEditOrganizationDialog(null);
    }
  }

  void _showEditUserDialog(UserResponse? user) {
    showDialog(
      context: context,
      builder: (context) => CrudDialog<UserResponse>(
        item: user,
        title: user == null ? 'Add User' : 'Edit User',
        fields: [
          CrudField(
            key: 'username',
            label: 'Username',
            type: CrudFieldType.text,
            isRequired: true,
            initialValue: user?.username,
          ),
          CrudField(
            key: 'email',
            label: 'Email',
            type: CrudFieldType.email,
            isRequired: true,
            initialValue: user?.email,
          ),
          if (user == null) // Only show password field for new users
            CrudField(
              key: 'passwordHash',
              label: 'Password',
              type: CrudFieldType.text,
              isRequired: true,
            ),
          CrudField(
            key: 'firstName',
            label: 'First Name',
            type: CrudFieldType.text,
            isRequired: true,
            initialValue: user?.firstName,
          ),
          CrudField(
            key: 'lastName',
            label: 'Last Name',
            type: CrudFieldType.text,
            isRequired: true,
            initialValue: user?.lastName,
          ),
          CrudField(
            key: 'phoneNumber',
            label: 'Phone Number',
            type: CrudFieldType.text,
            initialValue: user?.phoneNumber,
          ),
          CrudField(
            key: 'dateOfBirth',
            label: 'Date of Birth',
            type: CrudFieldType.date,
            initialValue: user?.dateOfBirth,
          ),
          CrudField(
            key: 'city',
            label: 'City',
            type: CrudFieldType.text,
            initialValue: user?.city,
          ),
          CrudField(
            key: 'country',
            label: 'Country',
            type: CrudFieldType.text,
            initialValue: user?.country,
          ),
          CrudField(
            key: 'userTypeId',
            label: 'User Type',
            type: CrudFieldType.dropdown,
            isRequired: true,
            initialValue: user?.userTypeId,
            dropdownItems: _allUserTypes.map((userType) => 
              DropdownItem(value: userType.id, label: userType.name)
            ).toList(),
          ),
          CrudField(
            key: 'isActive',
            label: 'Active',
            type: CrudFieldType.checkbox,
            initialValue: user?.isActive ?? true,
          ),
        ],
        onSave: (values) => _saveUser(user, values),
      ),
    );
  }

  void _showEditUserTypeDialog(UserType? userType) {
    showDialog(
      context: context,
      builder: (context) => CrudDialog<UserType>(
        item: userType,
        title: userType == null ? 'Add User Type' : 'Edit User Type',
        fields: [
          CrudField(
            key: 'name',
            label: 'Name',
            type: CrudFieldType.text,
            isRequired: true,
            initialValue: userType?.name,
          ),
        ],
        onSave: (values) => _saveUserType(userType, values),
      ),
    );
  }

void _showEditBadgeDialog(BadgeResponse? badge) {
  showDialog(
    context: context,
    builder: (context) => CrudDialog<BadgeResponse>(
      item: badge,
      title: badge == null ? 'Add Badge' : 'Edit Badge',
      fields: [
        CrudField(
          key: 'name',
          label: 'Name',
          type: CrudFieldType.text,
          isRequired: true,
          initialValue: badge?.name,
        ),
        CrudField(
          key: 'description',
          label: 'Description',
          type: CrudFieldType.text,
          initialValue: badge?.description,
        ),
        CrudField(
          key: 'badgeTypeId',
          label: 'Badge Type ID',
          type: CrudFieldType.number,
          isRequired: true,
          initialValue: badge?.badgeTypeId,
        ),
        CrudField(
          key: 'criteriaTypeId',
          label: 'Criteria Type ID',
          type: CrudFieldType.number,
          isRequired: true,
          initialValue: badge?.criteriaTypeId,
        ),
        CrudField(
          key: 'criteriaValue',
          label: 'Criteria Value',
          type: CrudFieldType.number,
          isRequired: true,
          initialValue: badge?.criteriaValue,
        ),
        CrudField(
          key: 'isActive',
          label: 'Active',
          type: CrudFieldType.checkbox,
          initialValue: badge?.isActive ?? true,
        ),
      ],
      onSave: (values) => _saveBadge(badge, values),
    ),
  );
}

void _showEditLocationDialog(LocationResponse? location) {
  showDialog(
    context: context,
    builder: (context) => CrudDialog<LocationResponse>(
      item: location,
      title: location == null ? 'Add Location' : 'Edit Location',
      fields: [
        CrudField(
          key: 'name',
          label: 'Name',
          type: CrudFieldType.text,
          initialValue: location?.name,
        ),
        CrudField(
          key: 'description',
          label: 'Description',
          type: CrudFieldType.text,
          initialValue: location?.description,
        ),
        CrudField(
          key: 'latitude',
          label: 'Latitude',
          type: CrudFieldType.text, // Using text for decimal input
          isRequired: true,
          initialValue: location?.latitude.toString(),
        ),
        CrudField(
          key: 'longitude',
          label: 'Longitude',
          type: CrudFieldType.text, // Using text for decimal input
          isRequired: true,
          initialValue: location?.longitude.toString(),
        ),
        CrudField(
          key: 'address',
          label: 'Address',
          type: CrudFieldType.text,
          initialValue: location?.address,
        ),
        CrudField(
          key: 'city',
          label: 'City',
          type: CrudFieldType.text,
          initialValue: location?.city,
        ),
        CrudField(
          key: 'country',
          label: 'Country',
          type: CrudFieldType.text,
          initialValue: location?.country,
        ),
        CrudField(
          key: 'postalCode',
          label: 'Postal Code',
          type: CrudFieldType.text,
          initialValue: location?.postalCode,
        ),
        CrudField(
          key: 'locationType',
          label: 'Location Type',
          type: CrudFieldType.dropdown,
          isRequired: true,
          initialValue: location?.locationType,
          dropdownItems: LocationType.values.map((type) => 
            DropdownItem(value: type, label: type.displayName)
          ).toList(),
        ),
      ],
      onSave: (values) => _saveLocation(location, values),
    ),
  );
}

void _showEditUserBadgeDialog(UserBadgeResponse? userBadge) {
  showDialog(
    context: context,
    builder: (context) => CrudDialog<UserBadgeResponse>(
      item: userBadge,
      title: userBadge == null ? 'Add User Badge' : 'Edit User Badge',
      fields: [
        CrudField(
          key: 'userId',
          label: 'User',
          type: CrudFieldType.dropdown,
          isRequired: true,
          initialValue: userBadge?.userId,
          dropdownItems: _allUsers.map((user) =>
              DropdownItem(value: user.id, label: user.username)).toList(),
        ),
        CrudField(
          key: 'badgeId',
          label: 'Badge',
          type: CrudFieldType.dropdown,
          isRequired: true,
          initialValue: userBadge?.badgeId,
          dropdownItems: _allBadges.map((badge) =>
              DropdownItem(value: badge.id, label: badge.name ?? 'N/A')).toList(),
        ),
        CrudField(
          key: 'earnedAt',
          label: 'Earned At',
          type: CrudFieldType.date,
          isRequired: true,
          initialValue: userBadge?.earnedAt,
        ),
      ],
      onSave: (values) => _saveUserBadge(userBadge, values),
    ),
  );
}

void _showEditWasteTypeDialog(WasteTypeResponse? wasteType) {
  showDialog(
    context: context,
    builder: (context) => CrudDialog<WasteTypeResponse>(
      item: wasteType,
      title: wasteType == null ? 'Add Waste Type' : 'Edit Waste Type',
      fields: [
        CrudField(
          key: 'name',
          label: 'Name',
          type: CrudFieldType.text,
          isRequired: true,
          initialValue: wasteType?.name,
        ),
      ],
      onSave: (values) => _saveWasteType(wasteType, values),
    ),
  );
}

void _showEditOrganizationDialog(OrganizationResponse? organization) {
  showDialog(
    context: context,
    builder: (context) => CrudDialog<OrganizationResponse>(
      item: organization,
      title: organization == null ? 'Add Organization' : 'Edit Organization',
      fields: [
        CrudField(
          key: 'name',
          label: 'Name',
          type: CrudFieldType.text,
          isRequired: true,
          initialValue: organization?.name,
        ),
        CrudField(
          key: 'category',
          label: 'Category',
          type: CrudFieldType.text,
          initialValue: organization?.category,
        ),
        CrudField(
          key: 'description',
          label: 'Description',
          type: CrudFieldType.text,
          initialValue: organization?.description,
        ),
        CrudField(
          key: 'website',
          label: 'Website',
          type: CrudFieldType.text,
          initialValue: organization?.website,
        ),
        CrudField(
          key: 'isVerified',
          label: 'Verified',
          type: CrudFieldType.checkbox,
          initialValue: organization?.isVerified ?? false,
        ),
        CrudField(
          key: 'isActive',
          label: 'Active',
          type: CrudFieldType.checkbox,
          initialValue: organization?.isActive ?? true,
        ),
      ],
      onSave: (values) => _saveOrganization(organization, values),
    ),
  );
}

  void _showViewDialog(UserResponse user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: Container(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', user.id.toString()),
                _buildDetailRow('Username', user.username),
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Name', '${user.firstName} ${user.lastName}'),
                _buildDetailRow('Phone', user.phoneNumber ?? 'N/A'),
                _buildDetailRow('Date of Birth', user.dateOfBirth?.toString().split(' ')[0] ?? 'N/A'),
                _buildDetailRow('City', user.city ?? 'N/A'),
                _buildDetailRow('Country', user.country ?? 'N/A'),
                _buildDetailRow('Total Points', user.totalPoints.toString()),
                _buildDetailRow('Total Cleanups', user.totalCleanups.toString()),
                _buildDetailRow('Events Organized', user.totalEventsOrganized.toString()),
                _buildDetailRow('Events Participated', user.totalEventsParticipated.toString()),
                _buildDetailRow('User Type', user.userTypeName ?? 'N/A'),
                _buildDetailRow('Active', user.isActive ? 'Yes' : 'No'),
                _buildDetailRow('Created', user.createdAt.toString().split('.')[0]),
                _buildDetailRow('Last Login', user.lastLogin?.toString().split('.')[0] ?? 'Never'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

void _showViewBadgeDialog(BadgeResponse badge) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Badge Details'),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', badge.id.toString()),
              _buildDetailRow('Name', badge.name ?? 'N/A'),
              _buildDetailRow('Description', badge.description ?? 'N/A'),
              _buildDetailRow('Badge Type ID', badge.badgeTypeId.toString()),
              _buildDetailRow('Criteria Type ID', badge.criteriaTypeId.toString()),
              _buildDetailRow('Criteria Value', badge.criteriaValue.toString()),
              _buildDetailRow('Active', badge.isActive ? 'Yes' : 'No'),
              _buildDetailRow('Created', badge.createdAt.toString().split('.')[0]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

void _showViewLocationDialog(LocationResponse location) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Location Details'),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', location.id.toString()),
              _buildDetailRow('Name', location.name ?? 'N/A'),
              _buildDetailRow('Description', location.description ?? 'N/A'),
              _buildDetailRow('Latitude', location.latitude.toString()),
              _buildDetailRow('Longitude', location.longitude.toString()),
              _buildDetailRow('Address', location.address ?? 'N/A'),
              _buildDetailRow('City', location.city ?? 'N/A'),
              _buildDetailRow('Country', location.country ?? 'N/A'),
              _buildDetailRow('Postal Code', location.postalCode ?? 'N/A'),
              _buildDetailRow('Location Type', location.locationType.displayName),
              _buildDetailRow('Created', location.createdAt.toString().split('.')[0]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

void _showViewUserBadgeDialog(UserBadgeResponse userBadge) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('User Badge Details'),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', userBadge.id.toString()),
              _buildDetailRow('User ID', userBadge.userId.toString()),
              _buildDetailRow('Badge ID', userBadge.badgeId.toString()),
              _buildDetailRow('Earned At', userBadge.earnedAt.toString().split('.')[0]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

void _showViewOrganizationDialog(OrganizationResponse organization) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Organization Details'),
      content: Container(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', organization.id.toString()),
              _buildDetailRow('Name',  organization.name ?? 'N/A'),
              _buildDetailRow('Category', organization.category ?? 'N/A'),
              _buildDetailRow('Description', organization.description ?? 'N/A'),
              _buildDetailRow('Website', organization.website ?? 'N/A'),
              _buildDetailRow('Verified', organization.isVerified ? 'Yes' : 'No'),
              _buildDetailRow('Active', organization.isActive ? 'Yes' : 'No'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUser(UserResponse? user, Map<String, dynamic> values) async {
    try {
      if (user == null) {
        // Create new user using UserInsertRequest
        final request = UserInsertRequest(
          username: values['username'],
          email: values['email'],
          passwordHash: values['passwordHash'] ?? 'defaultPassword123',
          firstName: values['firstName'],
          lastName: values['lastName'],
          phoneNumber: values['phoneNumber'],
          dateOfBirth: values['dateOfBirth'],
          city: values['city'],
          country: values['country'],
          userTypeId: values['userTypeId'] ?? 2,
          isActive: values['isActive'] ?? true,
        );
        await _userProvider.insert(request.toJson());
      } else {
        // Update existing user using UserUpdateRequest
        final request = UserUpdateRequest(
          username: values['username'],
          email: values['email'],
          firstName: values['firstName'],
          lastName: values['lastName'],
          phoneNumber: values['phoneNumber'],
          dateOfBirth: values['dateOfBirth'],
          city: values['city'],
          country: values['country'],
          userTypeId: values['userTypeId'],
          isActive: values['isActive'],
        );
        await _userProvider.update(user.id, request.toJson());
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User saved successfully')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user: $e')),
      );
    }
  }

  Future<void> _saveUserType(UserType? userType, Map<String, dynamic> values) async {
    try {
      final request = UserTypeRequest(
        name: values['name'],
      );

      if (userType == null) {
        await _userTypeProvider.insert(request.toJson());
      } else {
        await _userTypeProvider.update(userType.id, request.toJson());
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User type saved successfully')),
      );
      _loadUserTypes(); // Refresh user types list
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user type: $e')),
      );
    }
  }

Future<void> _saveBadge(BadgeResponse? badge, Map<String, dynamic> values) async {
  try {
    if (badge == null) {
      final request = BadgeInsertRequest(
        name: values['name'],
        description: values['description'],
        badgeTypeId: values['badgeTypeId'],
        criteriaTypeId: values['criteriaTypeId'],
        criteriaValue: values['criteriaValue'],
        isActive: values['isActive'] ?? true,
      );
      await _badgeProvider.insert(request.toJson());
    } else {
      final request = BadgeUpdateRequest(
        name: values['name'],
        description: values['description'],
        badgeTypeId: values['badgeTypeId'],
        criteriaTypeId: values['criteriaTypeId'],
        criteriaValue: values['criteriaValue'],
        isActive: values['isActive'],
      );
      await _badgeProvider.update(badge.id, request.toJson());
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Badge saved successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving badge: $e')),
    );
  }
}

Future<void> _saveLocation(LocationResponse? location, Map<String, dynamic> values) async {
  try {
    if (location == null) {
      final request = LocationInsertRequest(
        name: values['name'],
        description: values['description'],
        latitude: double.parse(values['latitude']),
        longitude: double.parse(values['longitude']),
        address: values['address'],
        city: values['city'],
        country: values['country'],
        postalCode: values['postalCode'],
        locationType: values['locationType'],
      );
      await _locationProvider.insert(request.toJson());
    } else {
      final request = LocationUpdateRequest(
        name: values['name'],
        description: values['description'],
        latitude: values['latitude'] != null ? double.parse(values['latitude']) : null,
        longitude: values['longitude'] != null ? double.parse(values['longitude']) : null,
        address: values['address'],
        city: values['city'],
        country: values['country'],
        postalCode: values['postalCode'],
        locationType: values['locationType'],
      );
      await _locationProvider.update(location.id, request.toJson());
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location saved successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving location: $e')),
    );
  }
}

Future<void> _saveUserBadge(UserBadgeResponse? userBadge, Map<String, dynamic> values) async {
  try {
    if (userBadge == null) {
      final request = UserBadgeInsertRequest(
        userId: values['userId'],
        badgeId: values['badgeId'],
        earnedAt: values['earnedAt'],
      );
      await _userBadgeProvider.insert(request.toJson());
    } else {
      final request = UserBadgeUpdateRequest(
        userId: values['userId'],
        badgeId: values['badgeId'],
        earnedAt: values['earnedAt'],
      );
      await _userBadgeProvider.update(userBadge.id, request.toJson());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User badge saved successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving user badge: $e')),
    );
  }
}

Future<void> _saveWasteType(WasteTypeResponse? wasteType, Map<String, dynamic> values) async {
  try {
    final request = WasteTypeRequest(
      name: values['name'],
    );

    if (wasteType == null) {
      await _wasteTypeProvider.insert(request.toJson());
    } else {
      await _wasteTypeProvider.update(wasteType.id, request.toJson());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Waste type saved successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving waste type: $e')),
    );
  }
}

Future<void> _saveOrganization(OrganizationResponse? organization, Map<String, dynamic> values) async {
  try {
    if (organization == null) {
      final request = OrganizationInsertRequest(
        name: values['name'],
        category: values['category'],
        description: values['description'],
        website: values['website'],
        isVerified: values['isVerified'] ?? false,
        isActive: values['isActive'] ?? true,
      );
      await _organizationProvider.insert(request.toJson());
    } else {
      final request = OrganizationUpdateRequest(
        name: values['name'],
        category: values['category'],
        description: values['description'],
        website: values['website'],
        isVerified: values['isVerified'],
        isActive: values['isActive'],
      );
      await _organizationProvider.update(organization.id, request.toJson());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Organization saved successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving organization: $e')),
    );
  }
}

  Future<void> _deleteUser(int id) async {
    try {
      await _userProvider.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

Future<void> _deleteBadge(int id) async {
  try {
    await _badgeProvider.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Badge deleted successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting badge: $e')),
    );
  }
}

Future<void> _deleteLocation(int id) async {
  try {
    await _locationProvider.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location deleted successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting location: $e')),
    );
  }
}

Future<void> _deleteUserBadge(int id) async {
  try {
    await _userBadgeProvider.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User badge deleted successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting user badge: $e')),
    );
  }
}

Future<void> _deleteWasteType(int id) async {
  try {
    await _wasteTypeProvider.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Waste type deleted successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting waste type: $e')),
    );
  }
}

Future<void> _deleteOrganization(int id) async {
  try {
    await _organizationProvider.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Organization deleted successfully')),
    );
    _loadData();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting organization: $e')),
    );
  }
}

  Future<void> _deleteUserType(int id) async {
    try {
      await _userTypeProvider.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User type deleted successfully')),
      );
      _loadUserTypes(); // Refresh user types list
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user type: $e')),
      );
    }
  }
}
