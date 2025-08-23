import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/user_type.dart';
import 'package:ecochallenge_desktop/providers/user_type_provider.dart';
import 'package:ecochallenge_desktop/widgets/user_type_form_dialog.dart';

class UserTypeManagementPage extends StatefulWidget {
  const UserTypeManagementPage({Key? key}) : super(key: key);

  @override
  State<UserTypeManagementPage> createState() => _UserTypeManagementPageState();
}

class _UserTypeManagementPageState extends State<UserTypeManagementPage> {
  final UserTypeProvider _userTypeProvider = UserTypeProvider();
  
  List<UserType> _userTypes = [];
  bool _isLoading = false;

  // Scroll controllers
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserTypes();
  }

  Future<void> _loadUserTypes() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _userTypeProvider.get();
      setState(() {
        _userTypes = result.items ?? [];
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load user types: $e');
    } finally {
      setState(() => _isLoading = false);
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

  Future<void> _deleteUserType(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user type?'),
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
        await _userTypeProvider.delete(id);
        _showSuccessSnackBar('User type deleted successfully');
        _loadUserTypes();
      } catch (e) {
        _showErrorSnackBar('Failed to delete user type: $e');
      }
    }
  }

  void _showUserTypeForm([UserType? userType]) {
    showDialog(
      context: context,
      builder: (context) => UserTypeFormDialog(
        userType: userType,
        onSaved: () {
          Navigator.pop(context);
          _loadUserTypes();
          _showSuccessSnackBar(userType == null ? 'User type created successfully' : 'User type updated successfully');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              children: [
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _showUserTypeForm(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add User Type', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const Spacer(),
                Text('Total: ${_userTypes.length} user types', style: const TextStyle(fontSize: 14)),
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
                                columnSpacing: 20,
                                horizontalMargin: 16,
                                dataRowHeight: 48,
                                headingRowHeight: 40,
                                dataTextStyle: const TextStyle(fontSize: 12),
                                headingTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _userTypes.map((userType) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(userType.id.toString())),
                                      DataCell(
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            userType.name,
                                            overflow: TextOverflow.ellipsis,
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
                                              onPressed: () => _showUserTypeForm(userType),
                                              tooltip: 'Edit',
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 18),
                                              color: Colors.red,
                                              onPressed: () => _deleteUserType(userType.id),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}