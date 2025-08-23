import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:ecochallenge_desktop/widgets/balance_settings_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ecochallenge_desktop/models/balance_setting.dart';
import 'package:ecochallenge_desktop/providers/balance_setting_provider.dart';

class BalanceSettingManagementPage extends StatefulWidget {
  const BalanceSettingManagementPage({Key? key}) : super(key: key);

  @override
  State<BalanceSettingManagementPage> createState() => _BalanceSettingManagementPageState();
}

class _BalanceSettingManagementPageState extends State<BalanceSettingManagementPage> {
  final BalanceSettingProvider _balanceSettingProvider = BalanceSettingProvider();
  
  List<BalanceSettingResponse> _balanceSettings = [];
  BalanceSettingResponse? _currentBalance;
  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalCount = 0;
  
  // Filter controllers
  final TextEditingController _minBalanceController = TextEditingController();
  final TextEditingController _maxBalanceController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'UpdatedAt';
  bool _sortDesc = true;
  
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
      await _loadBalanceSettings();
      await _loadCurrentBalance();
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentBalance() async {
    try {
      final currentBalance = await _balanceSettingProvider.getCurrentBalance();
      setState(() {
        _currentBalance = currentBalance;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load current balance: $e');
    }
  }

  Future<void> _loadBalanceSettings() async {
    try {
      final searchObject = BalanceSettingSearchObject(
        page: _currentPage,
        pageSize: _pageSize,
        sortBy: _sortBy,
        desc: _sortDesc,
        fromDate: _fromDate,
        toDate: _toDate,
        minBalance: _minBalanceController.text.isNotEmpty 
            ? double.tryParse(_minBalanceController.text) 
            : null,
        maxBalance: _maxBalanceController.text.isNotEmpty 
            ? double.tryParse(_maxBalanceController.text) 
            : null,
      );

      final result = await _balanceSettingProvider.getBalanceSettings(searchObject: searchObject);
      
      setState(() {
        _balanceSettings = result.items ?? [];
        _totalCount = result.totalCount ?? 0;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load balance settings: $e');
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

  Future<void> _deleteBalanceSetting(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this balance setting?'),
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
        await _balanceSettingProvider.deleteBalanceSetting(id);
        _showSuccessSnackBar('Balance setting deleted successfully');
        _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to delete balance setting: $e');
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _minBalanceController.clear();
      _maxBalanceController.clear();
      _fromDate = null;
      _toDate = null;
      _sortBy = 'UpdatedAt';
      _sortDesc = true;
      _currentPage = 0;
    });
    _loadBalanceSettings();
  }

  void _showBalanceSettingForm([BalanceSettingResponse? balanceSetting]) {
    showDialog(
      context: context,
      builder: (context) => BalanceSettingFormDialog(
        balanceSetting: balanceSetting,
        onSaved: () {
          Navigator.pop(context);
          _loadData();
          _showSuccessSnackBar(balanceSetting == null ? 'Balance setting created successfully' : 'Balance setting updated successfully');
        },
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  Widget _buildCurrentBalanceCard() {
    if (_currentBalance == null) {
      return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Text('No balance setting found', style: TextStyle(fontSize: 14)),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _currentBalance!.isCriticalBalance 
            ? Colors.red[50] 
            : _currentBalance!.isLowBalance 
                ? Colors.orange[50] 
                : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _currentBalance!.isCriticalBalance 
              ? Colors.red[300]! 
              : _currentBalance!.isLowBalance 
                  ? Colors.orange[300]! 
                  : Colors.green[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _currentBalance!.isCriticalBalance 
                ? Icons.error 
                : _currentBalance!.isLowBalance 
                    ? Icons.warning 
                    : Icons.check_circle,
            color: _currentBalance!.isCriticalBalance 
                ? Colors.red[700] 
                : _currentBalance!.isLowBalance 
                    ? Colors.orange[700] 
                    : Colors.green[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance: ${_balanceSettingProvider.formatBalance(_currentBalance!.balanceLeft)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Balance: ${_balanceSettingProvider.formatBalance(_currentBalance!.wholeBalance)} | '
                  'Used: ${_balanceSettingProvider.formatBalance(_currentBalance!.usedBalance)} | '
                  'Usage: ${(100 - _currentBalance!.balancePercentage).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Current Balance Card
          _buildCurrentBalanceCard(),
          
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
                          controller: _minBalanceController,
                          style: const TextStyle(fontSize: 14),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min Balance',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money, size: 18),
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
                          controller: _maxBalanceController,
                          style: const TextStyle(fontSize: 14),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Balance',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money_off, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      height: 40,
                      child: InkWell(
                        onTap: _selectFromDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'From Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          child: Text(
                            _fromDate != null
                                ? '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'
                                : 'Select date',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      height: 40,
                      child: InkWell(
                        onTap: _selectToDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'To Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            isDense: true,
                          ),
                          child: Text(
                            _toDate != null
                                ? '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'
                                : 'Select date',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _currentPage = 0;
                          _loadBalanceSettings();
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
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _showBalanceSettingForm(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Balance Setting', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: forestGreen[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 150,
                      height: 36,
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'UpdatedAt', child: Text('Updated Date')),
                          DropdownMenuItem(value: 'WholeBalance', child: Text('Whole Balance')),
                          DropdownMenuItem(value: 'BalanceLeft', child: Text('Balance Left')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _sortDesc = !_sortDesc;
                          });
                          _loadBalanceSettings();
                        },
                        icon: Icon(_sortDesc ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
                        label: Text(_sortDesc ? 'Desc' : 'Asc', style: const TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('Total: $_totalCount balance settings', style: const TextStyle(fontSize: 14)),
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
                                  dataRowHeight: 48,
                                  headingRowHeight: 40,
                                  dataTextStyle: const TextStyle(fontSize: 12),
                                  headingTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  columns: const [
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('Whole Balance')),
                                    DataColumn(label: Text('Balance Left')),
                                    DataColumn(label: Text('Used Balance')),
                                    DataColumn(label: Text('Usage %')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Updated At')),
                                    DataColumn(label: Text('Updated By')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: _balanceSettings.map((balance) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(balance.id.toString())),
                                        DataCell(Text(_balanceSettingProvider.formatBalance(balance.wholeBalance))),
                                        DataCell(Text(_balanceSettingProvider.formatBalance(balance.balanceLeft))),
                                        DataCell(Text(_balanceSettingProvider.formatBalance(balance.usedBalance))),
                                        DataCell(Text('${(100 - balance.balancePercentage).toStringAsFixed(1)}%')),
                                        DataCell(
                                          Chip(
                                            label: Text(
                                              balance.isCriticalBalance ? 'Critical' : balance.isLowBalance ? 'Low' : 'Normal',
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                            backgroundColor: balance.isCriticalBalance 
                                                ? Colors.red[100] 
                                                : balance.isLowBalance 
                                                    ? Colors.orange[100] 
                                                    : Colors.green[100],
                                            labelStyle: TextStyle(
                                              color: balance.isCriticalBalance 
                                                  ? Colors.red[800] 
                                                  : balance.isLowBalance 
                                                      ? Colors.orange[800] 
                                                      : Colors.green[800],
                                            ),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              '${balance.updatedAt.day}/${balance.updatedAt.month}/${balance.updatedAt.year} ${balance.updatedAt.hour}:${balance.updatedAt.minute.toString().padLeft(2, '0')}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 100,
                                            child: Text(
                                              balance.updatedByName ?? 'System',
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
                                                onPressed: () => _showBalanceSettingForm(balance),
                                                tooltip: 'Edit',
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                                padding: EdgeInsets.zero,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, size: 18),
                                                color: Colors.red,
                                                onPressed: () => _deleteBalanceSetting(balance.id),
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
                              _loadBalanceSettings();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    IconButton(
                      onPressed: (_currentPage + 1) * _pageSize < _totalCount
                          ? () {
                              setState(() => _currentPage++);
                              _loadBalanceSettings();
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
    _minBalanceController.dispose();
    _maxBalanceController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }
}