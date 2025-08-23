import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/balance_setting.dart';
import 'package:ecochallenge_desktop/providers/balance_setting_provider.dart';

enum BalanceOperation { create, update, add, deduct, reset, adjust }

class BalanceSettingFormDialog extends StatefulWidget {
  final BalanceSettingResponse? balanceSetting;
  final VoidCallback onSaved;
  final BalanceOperation? operation;

  const BalanceSettingFormDialog({
    Key? key,
    this.balanceSetting,
    required this.onSaved,
    this.operation,
  }) : super(key: key);

  @override
  State<BalanceSettingFormDialog> createState() => _BalanceSettingFormDialogState();
}

class _BalanceSettingFormDialogState extends State<BalanceSettingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final BalanceSettingProvider _balanceSettingProvider = BalanceSettingProvider();
  
  late TextEditingController _wholeBalanceController;
  late TextEditingController _balanceLeftController;
  late TextEditingController _amountController;
  late TextEditingController _reasonController;
  
  BalanceOperation _selectedOperation = BalanceOperation.create;
  bool _isLoading = false;
  BalanceSettingResponse? _currentBalance;
  int _adminId = 1; // This should come from the current logged-in admin

  @override
  void initState() {
    super.initState();
    
    _wholeBalanceController = TextEditingController(
      text: widget.balanceSetting?.wholeBalance.toString() ?? ''
    );
    _balanceLeftController = TextEditingController(
      text: widget.balanceSetting?.balanceLeft.toString() ?? ''
    );
    _amountController = TextEditingController();
    _reasonController = TextEditingController();
    
    _selectedOperation = widget.operation ?? 
        (widget.balanceSetting == null ? BalanceOperation.create : BalanceOperation.update);
    
    _loadCurrentBalance();
  }

  Future<void> _loadCurrentBalance() async {
    try {
      final currentBalance = await _balanceSettingProvider.getCurrentBalance();
      setState(() {
        _currentBalance = currentBalance;
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  String _getDialogTitle() {
    switch (_selectedOperation) {
      case BalanceOperation.create:
        return 'Create Balance Setting';
      case BalanceOperation.update:
        return 'Update Balance Setting';
      case BalanceOperation.add:
        return 'Add Balance';
      case BalanceOperation.deduct:
        return 'Deduct Balance';
      case BalanceOperation.reset:
        return 'Reset Balance';
      case BalanceOperation.adjust:
        return 'Adjust Balance Left';
    }
  }

  Widget _buildCurrentBalanceInfo() {
    if (_currentBalance == null || _selectedOperation == BalanceOperation.create) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance Information:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text('Whole Balance: ${_balanceSettingProvider.formatBalance(_currentBalance!.wholeBalance)}'),
          Text('Balance Left: ${_balanceSettingProvider.formatBalance(_currentBalance!.balanceLeft)}'),
          Text('Used Balance: ${_balanceSettingProvider.formatBalance(_currentBalance!.usedBalance)}'),
          Text('Usage: ${(100 - _currentBalance!.balancePercentage).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildOperationSelector() {
    if (widget.balanceSetting != null || widget.operation != null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Operation Type:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<BalanceOperation>(
          value: _selectedOperation,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: BalanceOperation.create, child: Text('Create New Balance Setting')),
            DropdownMenuItem(value: BalanceOperation.add, child: Text('Add Balance')),
            DropdownMenuItem(value: BalanceOperation.deduct, child: Text('Deduct Balance')),
            DropdownMenuItem(value: BalanceOperation.reset, child: Text('Reset Balance')),
            DropdownMenuItem(value: BalanceOperation.adjust, child: Text('Adjust Balance Left')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedOperation = value!;
              _amountController.clear();
              _wholeBalanceController.clear();
              _balanceLeftController.clear();
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFormFields() {
    switch (_selectedOperation) {
      case BalanceOperation.create:
      case BalanceOperation.update:
        return Column(
          children: [
            TextFormField(
              controller: _wholeBalanceController,
              decoration: const InputDecoration(
                labelText: 'Whole Balance *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
                suffixText: 'BAM',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Whole balance is required';
                final amount = double.tryParse(value!);
                if (amount == null || amount < 0) return 'Enter a valid positive amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceLeftController,
              decoration: const InputDecoration(
                labelText: 'Balance Left *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
                suffixText: 'BAM',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Balance left is required';
                final amount = double.tryParse(value!);
                if (amount == null || amount < 0) return 'Enter a valid positive amount';
                
                final wholeBalance = double.tryParse(_wholeBalanceController.text);
                if (wholeBalance != null && amount > wholeBalance) {
                  return 'Balance left cannot exceed whole balance';
                }
                return null;
              },
            ),
          ],
        );
      
      case BalanceOperation.add:
      case BalanceOperation.deduct:
      case BalanceOperation.reset:
        return Column(
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _selectedOperation == BalanceOperation.reset 
                    ? 'New Balance Amount *' 
                    : 'Amount *',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_selectedOperation == BalanceOperation.add 
                    ? Icons.add_circle 
                    : _selectedOperation == BalanceOperation.deduct 
                        ? Icons.remove_circle 
                        : Icons.refresh),
                suffixText: 'BAM',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Amount is required';
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) return 'Enter a valid positive amount';
                
                if (_selectedOperation == BalanceOperation.deduct && _currentBalance != null) {
                  if (amount > _currentBalance!.balanceLeft) {
                    return 'Amount exceeds available balance (${_balanceSettingProvider.formatBalance(_currentBalance!.balanceLeft)})';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        );
      
      case BalanceOperation.adjust:
        return Column(
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'New Balance Left *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tune),
                suffixText: 'BAM',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'New balance left is required';
                final amount = double.tryParse(value!);
                if (amount == null || amount < 0) return 'Enter a valid positive amount';
                
                if (_currentBalance != null && amount > _currentBalance!.wholeBalance) {
                  return 'Balance left cannot exceed whole balance (${_balanceSettingProvider.formatBalance(_currentBalance!.wholeBalance)})';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        );
    }
  }

  Future<void> _saveBalanceSetting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      switch (_selectedOperation) {
        case BalanceOperation.create:
          final request = BalanceSettingInsertRequest(
            wholeBalance: double.parse(_wholeBalanceController.text),
            balanceLeft: double.parse(_balanceLeftController.text),
            updatedByAdminId: _adminId,
          );
          await _balanceSettingProvider.insertBalanceSetting(request);
          break;
        
        case BalanceOperation.update:
          if (widget.balanceSetting == null) return;
          final request = BalanceSettingUpdateRequest(
            id: widget.balanceSetting!.id,
            wholeBalance: double.parse(_wholeBalanceController.text),
            balanceLeft: double.parse(_balanceLeftController.text),
            updatedByAdminId: _adminId,
          );
          await _balanceSettingProvider.updateBalanceSetting(request);
          break;
        
        case BalanceOperation.add:
          await _balanceSettingProvider.addBalance(
            double.parse(_amountController.text),
            _adminId,
            reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
          );
          break;
        
        case BalanceOperation.deduct:
          await _balanceSettingProvider.deductBalance(
            double.parse(_amountController.text),
            _adminId,
            reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
          );
          break;
        
        case BalanceOperation.reset:
          await _balanceSettingProvider.resetBalance(
            double.parse(_amountController.text),
            _adminId,
            reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
          );
          break;
        
        case BalanceOperation.adjust:
          await _balanceSettingProvider.adjustBalanceLeft(
            double.parse(_amountController.text),
            _adminId,
            reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
          );
          break;
      }
      
      widget.onSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save balance setting: $e'),
          backgroundColor: Colors.red,
        ),
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
                _getDialogTitle(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOperationSelector(),
                      _buildCurrentBalanceInfo(),
                      _buildFormFields(),
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
                    onPressed: _isLoading ? null : _saveBalanceSetting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOperation == BalanceOperation.deduct 
                          ? Colors.red[700] 
                          : _selectedOperation == BalanceOperation.add 
                              ? Colors.green[700]
                              : Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_getButtonText()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_selectedOperation) {
      case BalanceOperation.create:
        return 'Create';
      case BalanceOperation.update:
        return 'Update';
      case BalanceOperation.add:
        return 'Add Balance';
      case BalanceOperation.deduct:
        return 'Deduct Balance';
      case BalanceOperation.reset:
        return 'Reset Balance';
      case BalanceOperation.adjust:
        return 'Adjust Balance';
    }
  }

  @override
  void dispose() {
    _wholeBalanceController.dispose();
    _balanceLeftController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}