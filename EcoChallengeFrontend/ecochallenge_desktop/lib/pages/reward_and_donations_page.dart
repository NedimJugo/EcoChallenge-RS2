import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ecochallenge_desktop/models/request_participation.dart';
import 'package:ecochallenge_desktop/providers/request_participation_provider.dart';
import 'package:ecochallenge_desktop/providers/donation_provider.dart';
import 'package:ecochallenge_desktop/models/donation.dart';

enum FinanceFilter {
  all,
  pending,
  processed,
}

class RewardsPage extends StatefulWidget {
  final int? currentUserId; // Finance manager ID
  
  const RewardsPage({Key? key, this.currentUserId}) : super(key: key);

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final RequestParticipationProvider _requestParticipationProvider = RequestParticipationProvider();
  final DonationProvider _donationProvider = DonationProvider();

  // Request Participations data
  List<RequestParticipationResponse> _requestParticipations = [];
  int _requestParticipationsCurrentPage = 0;
  int _requestParticipationsPageSize = 10;
  int _requestParticipationsTotalCount = 0;
  int _requestParticipationsTotalPages = 0;
  bool _requestParticipationsLoading = false;
  String _requestParticipationsSortBy = "submittedAt";
  bool _requestParticipationsSortDesc = true;
  FinanceFilter _financeFilter = FinanceFilter.pending;

  // Donations data
  List<DonationResponse> _donations = [];
  int _donationsCurrentPage = 0;
  int _donationsPageSize = 5;
  int _donationsTotalCount = 0;
  int _donationsTotalPages = 0;
  bool _donationsLoading = false;
  String _donationsSortBy = 'Amount';
  bool _donationsSortDesc = true;

  // Selected participations for download
  Set<int> _selectedParticipations = Set<int>();

  // Controllers for finance processing modal
  final TextEditingController _financeNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRequestParticipations();
    _loadDonations();
  }

  Future<void> _loadRequestParticipations() async {
    setState(() {
      _requestParticipationsLoading = true;
    });

    try {
      final searchObject = RequestParticipationSearchObject(
        page: _requestParticipationsCurrentPage,
        pageSize: _requestParticipationsPageSize,
        sortBy: _requestParticipationsSortBy,
        desc: _requestParticipationsSortDesc,
        status: ParticipationStatus.approved, // Only load approved ones
        financeStatus: _financeFilter == FinanceFilter.all 
            ? null 
            : _financeFilter == FinanceFilter.pending 
                ? FinanceStatus.pending 
                : FinanceStatus.processed,
      );

      final result = await _requestParticipationProvider.get(filter: searchObject.toJson());
      
      setState(() {
        _requestParticipations = result.items ?? [];
        _requestParticipationsTotalCount = result.totalCount ?? 0;
        _requestParticipationsTotalPages = (_requestParticipationsTotalCount / _requestParticipationsPageSize).ceil();
        _requestParticipationsLoading = false;
        _selectedParticipations.clear();
      });
    } catch (e) {
      setState(() {
        _requestParticipationsLoading = false;
      });
      _showErrorSnackBar('Failed to load request participations: $e');
    }
  }

  Future<void> _loadDonations() async {
    setState(() {
      _donationsLoading = true;
    });

    try {
      final searchObject = DonationSearchObject(
        page: _donationsCurrentPage,
        pageSize: _donationsPageSize,
        sortBy: _donationsSortBy,
        desc: _donationsSortDesc,
      );

      final result = await _donationProvider.getDonations(searchObject: searchObject);
      
      setState(() {
        _donations = result.items ?? [];
        _donationsTotalCount = result.totalCount ?? 0;
        _donationsTotalPages = (_donationsTotalCount / _donationsPageSize).ceil();
        _donationsLoading = false;
      });
    } catch (e) {
      setState(() {
        _donationsLoading = false;
      });
      _showErrorSnackBar('Failed to load donations: $e');
    }
  }

  Future<void> _processSelectedFinance(String notes) async {
    if (_selectedParticipations.isEmpty) {
      _showErrorSnackBar('Please select at least one participation to process');
      return;
    }

    try {
      // Process finance for selected participations
      for (var id in _selectedParticipations) {
        // Get the current participation data to preserve existing values
        final currentParticipation = _requestParticipations.firstWhere((p) => p.id == id);
        
        final updateRequest = RequestParticipationUpdateRequest(
          id: id,
          // Preserve existing values
          status: currentParticipation.status,
          rewardPoints: currentParticipation.rewardPoints,
          rewardMoney: currentParticipation.rewardMoney,
          adminNotes: currentParticipation.adminNotes,
          cardHolderName: currentParticipation.cardHolderName,
          bankName: currentParticipation.bankName,
          transactionNumber: currentParticipation.transactionNumber,
          // Only update finance-related fields
          financeStatus: FinanceStatus.processed,
          financeNotes: notes.isNotEmpty ? notes : null,
          financeManagerId: widget.currentUserId,
          financeProcessedAt: DateTime.now(),
        );
        await _requestParticipationProvider.updateWithFormData(id, updateRequest);
      }

      // Reload data to reflect status changes
      _loadRequestParticipations();
      _financeNotesController.clear();
      
      _showSuccessSnackBar('${_selectedParticipations.length} participations processed successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to process finance: $e');
    }
  }

  Future<void> _generatePdfReport() async {
    if (_selectedParticipations.isEmpty) {
      _showErrorSnackBar('Please select at least one participation to generate PDF');
      return;
    }

    try {
      final pdf = pw.Document();
      final selectedData = _requestParticipations
          .where((p) => _selectedParticipations.contains(p.id))
          .toList();

      double totalAmount = selectedData.fold(0.0, (sum, p) => sum + p.rewardMoney);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          header: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(bottom: 20),
            child: pw.Text(
              'EcoChallenge Finance Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Generated on: ${DateTime.now().toLocal().toString().split('.')[0]}',
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
          build: (context) => [
            pw.Container(
              margin: pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BANK PAYMENT REQUEST',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
                  pw.Text('Total Participants: ${selectedData.length}'),
                  pw.Text('Total Amount: ${totalAmount.toStringAsFixed(2)} BAM'),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                ],
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(40),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(2),
                4: pw.FlexColumnWidth(1.5),
                5: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Card Holder Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Bank Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Account/Transaction', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Amount (BAM)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...selectedData.asMap().entries.map(
                  (entry) {
                    final index = entry.key;
                    final participation = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('${index + 1}'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(participation.cardHolderName ?? 'N/A'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(participation.bankName ?? 'N/A'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(participation.transactionNumber ?? 'N/A'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(participation.rewardMoney.toStringAsFixed(2)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(_formatDate(participation.submittedAt)),
                        ),
                      ],
                    );
                  },
                ),
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('')),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('')),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('')),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('${totalAmount.toStringAsFixed(2)} BAM', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('')),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Prepared by: _________________________', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text('Approved by: _________________________', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text('Finance Manager: _____________________', style: pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      );

      // Save PDF
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Finance Report',
        fileName: 'finance_report_${DateTime.now().toIso8601String().split('T')[0]}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(await pdf.save());
        _showSuccessSnackBar('PDF report generated successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to generate PDF: $e');
    }
  }

  void _showProcessFinanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Process Finance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Process ${_selectedParticipations.length} selected participations?'),
              SizedBox(height: 16),
              TextField(
                controller: _financeNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Finance Notes (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add any notes about the finance processing...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processSelectedFinance(_financeNotesController.text);
              },
              child: Text('Process'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onRequestParticipationsPageChanged(int page) {
    setState(() {
      _requestParticipationsCurrentPage = page;
    });
    _loadRequestParticipations();
  }

  void _onDonationsPageChanged(int page) {
    setState(() {
      _donationsCurrentPage = page;
    });
    _loadDonations();
  }

  void _onRequestParticipationsSortChanged(String sortBy) {
    setState(() {
      if (_requestParticipationsSortBy == sortBy) {
        _requestParticipationsSortDesc = !_requestParticipationsSortDesc;
      } else {
        _requestParticipationsSortBy = sortBy;
        _requestParticipationsSortDesc = true;
      }
      _requestParticipationsCurrentPage = 0;
    });
    _loadRequestParticipations();
  }

  void _onDonationsSortChanged(String sortBy) {
    setState(() {
      if (_donationsSortBy == sortBy) {
        _donationsSortDesc = !_donationsSortDesc;
      } else {
        _donationsSortBy = sortBy;
        _donationsSortDesc = true;
      }
      _donationsCurrentPage = 0;
    });
    _loadDonations();
  }

  void _onFinanceFilterChanged(FinanceFilter filter) {
    setState(() {
      _financeFilter = filter;
      _requestParticipationsCurrentPage = 0;
      _selectedParticipations.clear();
    });
    _loadRequestParticipations();
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedParticipations.contains(id)) {
        _selectedParticipations.remove(id);
      } else {
        _selectedParticipations.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedParticipations.length == _requestParticipations.length) {
        _selectedParticipations.clear();
      } else {
        _selectedParticipations = Set<int>.from(_requestParticipations.map((p) => p.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Participations Section (Left)
            Expanded(
              flex: 2,
              child: _buildRequestParticipationsSection(),
            ),
            SizedBox(width: 24),
            // Donations Section (Right)
            Expanded(
              child: _buildDonationsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestParticipationsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Finance Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 32,
                      child: DropdownButton<String>(
                        value: _requestParticipationsSortBy,
                        underline: SizedBox(),
                        items: [
                          DropdownMenuItem(value: 'submittedAt', child: Text('Date', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'rewardMoney', child: Text('Amount', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: 'cardHolderName', child: Text('Name', style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (value) {
                          if (value != null) _onRequestParticipationsSortChanged(value);
                        },
                        style: TextStyle(fontSize: 12, color: Colors.black),
                        dropdownColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    // Filter tabs
                    Row(
                      children: [
                        _buildFilterTab('New', FinanceFilter.pending),
                        SizedBox(width: 8),
                        _buildFilterTab('Processed', FinanceFilter.processed),
                        SizedBox(width: 8),
                        _buildFilterTab('All', FinanceFilter.all),
                      ],
                    ),
                    Spacer(),
                    // Action buttons
                    if (_selectedParticipations.isNotEmpty) ...[
                      ElevatedButton.icon(
                        onPressed: _generatePdfReport,
                        icon: Icon(Icons.picture_as_pdf, size: 16),
                        label: Text('Generate PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_financeFilter == FinanceFilter.pending)
                        ElevatedButton.icon(
                          onPressed: _showProcessFinanceDialog,
                          icon: Icon(Icons.check_circle, size: 16),
                          label: Text('Process Selected'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Table
          Expanded(
            child: _requestParticipationsLoading
                ? Center(child: CircularProgressIndicator())
                : _buildRequestParticipationsTable(),
          ),
          // Pagination
          _buildRequestParticipationsPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, FinanceFilter filter) {
    final isSelected = _financeFilter == filter;
    return GestureDetector(
      onTap: () => _onFinanceFilterChanged(filter),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDonationsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Text(
                  'Donations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  height: 32,
                  child: DropdownButton<String>(
                    value: _donationsSortBy,
                    underline: SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'Amount', child: Text('Sort by', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'CreatedAt', child: Text('Date', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'UserName', child: Text('Name', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (value) {
                      if (value != null) _onDonationsSortChanged(value);
                    },
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Table
          Expanded(
            child: _donationsLoading
                ? Center(child: CircularProgressIndicator())
                : _buildDonationsTable(),
          ),
          // Pagination
          _buildDonationsPagination(),
        ],
      ),
    );
  }

  Widget _buildRequestParticipationsTable() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Checkbox(
                  value: _selectedParticipations.length == _requestParticipations.length && _requestParticipations.isNotEmpty,
                  onChanged: (_) => _toggleSelectAll(),
                  tristate: true,
                ),
              ),
              Expanded(flex: 1, child: Text('No.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 3, child: Text('Card Holder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 2, child: Text('Bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 2, child: Text('Amount(BAM)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView.builder(
            itemCount: _requestParticipations.length,
            itemBuilder: (context, index) {
              final participation = _requestParticipations[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Checkbox(
                        value: _selectedParticipations.contains(participation.id),
                        onChanged: (_) => _toggleSelection(participation.id),
                      ),
                    ),
                    Expanded(flex: 1, child: Text('${(_requestParticipationsCurrentPage * _requestParticipationsPageSize) + index + 1}', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(participation.cardHolderName ?? 'N/A', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text(participation.bankName ?? 'N/A', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text('${participation.rewardMoney.toStringAsFixed(2)}', style: TextStyle(fontSize: 12))),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: participation.financeStatus == FinanceStatus.processed 
                              ? Colors.green[100] 
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          participation.financeStatus.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: participation.financeStatus == FinanceStatus.processed 
                                ? Colors.green[800] 
                                : Colors.orange[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(flex: 2, child: Text(_formatDate(participation.submittedAt), style: TextStyle(fontSize: 12))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDonationsTable() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text('No.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 3, child: Text('Donated to', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 2, child: Text('Amount(BAM)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView.builder(
            itemCount: _donations.length,
            itemBuilder: (context, index) {
              final donation = _donations[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text('${(_donationsCurrentPage * _donationsPageSize) + index + 1}', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(donation.userName ?? 'Anonymous', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(donation.organizationName ?? 'Unknown', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text('${donation.amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestParticipationsPagination() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Text(
            '${(_requestParticipationsCurrentPage * _requestParticipationsPageSize) + 1}-${((_requestParticipationsCurrentPage + 1) * _requestParticipationsPageSize).clamp(0, _requestParticipationsTotalCount)} of $_requestParticipationsTotalCount',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Spacer(),
          IconButton(
            onPressed: _requestParticipationsCurrentPage > 0 ? () => _onRequestParticipationsPageChanged(_requestParticipationsCurrentPage - 1) : null,
            icon: Icon(Icons.chevron_left, size: 20),
          ),
          IconButton(
            onPressed: _requestParticipationsCurrentPage < _requestParticipationsTotalPages - 1 ? () => _onRequestParticipationsPageChanged(_requestParticipationsCurrentPage + 1) : null,
            icon: Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsPagination() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Text(
            '${(_donationsCurrentPage * _donationsPageSize) + 1}-${((_donationsCurrentPage + 1) * _donationsPageSize).clamp(0, _donationsTotalCount)} of $_donationsTotalCount',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Spacer(),
          IconButton(
            onPressed: _donationsCurrentPage > 0 ? () => _onDonationsPageChanged(_donationsCurrentPage - 1) : null,
            icon: Icon(Icons.chevron_left, size: 20),
          ),
          IconButton(
            onPressed: _donationsCurrentPage < _donationsTotalPages - 1 ? () => _onDonationsPageChanged(_donationsCurrentPage + 1) : null,
            icon: Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _financeNotesController.dispose();
    super.dispose();
  }
}