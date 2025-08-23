import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/models/user_type.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';
import 'package:ecochallenge_desktop/providers/user_type_provider.dart';
import 'package:ecochallenge_desktop/widgets/user_form_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserProvider _userProvider = UserProvider();
  final UserTypeProvider _userTypeProvider = UserTypeProvider();
  
  List<UserResponse> _users = [];
  List<UserType> _userTypes = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  
  // Filter controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  UserType? _selectedUserType;
  bool? _isActiveFilter;
  
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
      // Load user types for dropdown
      final userTypesResult = await _userTypeProvider.get();
      _userTypes = userTypesResult.items ?? [];
      
      // Load users with current filters
      await _loadUsers();
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _buildSearchText() {
  final hasUsername = _usernameController.text.isNotEmpty;
  final hasEmail = _emailController.text.isNotEmpty;
  
  if (hasUsername && hasEmail) {
    return '${_usernameController.text} ${_emailController.text}';
  } else if (hasUsername) {
    return _usernameController.text;
  } else if (hasEmail) {
    return _emailController.text;
  }
  return null;
}


  Future<void> _loadUsers() async {
    try {
      final searchObject = UserSearchObject(
        page: _currentPage,
        pageSize: _pageSize,
        text: _buildSearchText(),
        userTypeId: _selectedUserType?.id,
        isActive: _isActiveFilter,
      );

      

      final result = await _userProvider.get(filter: searchObject.toJson());
      
      setState(() {
        _users = result.items ?? [];
        _totalCount = result.totalCount ?? 0;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load users: $e');
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

  Future<void> _deleteUser(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
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
        await _userProvider.delete(id);
        _showSuccessSnackBar('User deleted successfully');
        _loadUsers();
      } catch (e) {
        _showErrorSnackBar('Failed to delete user: $e');
      }
    }
  }

  Future<void> _toggleUserStatus(UserResponse user) async {
    try {
      await _userProvider.updateUserStatus(user.id, !user.isActive);
      _showSuccessSnackBar('User status updated successfully');
      _loadUsers();
    } catch (e) {
      _showErrorSnackBar('Failed to update user status: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _usernameController.clear();
      _emailController.clear();
      _selectedUserType = null;
      _isActiveFilter = null;
      _currentPage = 0;
    });
    _loadUsers();
  }
  void _showUserForm([UserResponse? user]) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        userTypes: _userTypes,
        onSaved: () {
          Navigator.pop(context);
          _loadUsers();
          _showSuccessSnackBar(user == null ? 'User created successfully' : 'User updated successfully');
        },
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
                          controller: _usernameController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person, size: 18),
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
                          controller: _emailController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: DropdownButtonFormField<UserType>(
                        value: _selectedUserType,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        items: [
                          const DropdownMenuItem<UserType>(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ..._userTypes.map((type) {
                            return DropdownMenuItem<UserType>(
                              value: type,
                              child: Text(type.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: DropdownButtonFormField<bool>(
                        value: _isActiveFilter,
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem<bool>(
                            value: null,
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem<bool>(
                            value: true,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<bool>(
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
                          _loadUsers();
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
                        onPressed: () => _showUserForm(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add User', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('Total: $_totalCount users', style: const TextStyle(fontSize: 14)),
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
                        scrollbars: false, // We're using custom scrollbars
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
                                  DataColumn(label: Text('Username')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('User Type')),
                                  DataColumn(label: Text('Points')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _users.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user.id.toString())),
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            user.username,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            user.email,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            '${user.firstName} ${user.lastName}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            user.userTypeName ?? 'N/A',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(user.totalPoints.toString())),
                                      DataCell(
                                        Chip(
                                          label: Text(
                                            user.isActive ? 'Active' : 'Inactive',
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                          backgroundColor: user.isActive ? Colors.green[100] : Colors.red[100],
                                          labelStyle: TextStyle(
                                            color: user.isActive ? Colors.green[800] : Colors.red[800],
                                          ),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 18),
                                              color: Colors.blue,
                                              onPressed: () => _showUserForm(user),
                                              tooltip: 'Edit',
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                user.isActive ? Icons.block : Icons.check_circle,
                                                size: 18,
                                              ),
                                              color: user.isActive ? Colors.orange : Colors.green,
                                              onPressed: () => _toggleUserStatus(user),
                                              tooltip: user.isActive ? 'Deactivate' : 'Activate',
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 18),
                                              color: Colors.red,
                                              onPressed: () => _deleteUser(user.id),
                                              tooltip: 'Delete',
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }                                ).toList(),
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
                              _loadUsers();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      onPressed: (_currentPage + 1) * _pageSize < _totalCount
                          ? () {
                              setState(() => _currentPage++);
                              _loadUsers();
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
    _usernameController.dispose();
    _emailController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}