import 'dart:io';
import 'dart:typed_data';
import 'package:ecochallenge_desktop/models/request_participation.dart';
import 'package:ecochallenge_desktop/providers/request_participation_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';
import 'package:ecochallenge_desktop/providers/request_provider.dart';
import 'package:ecochallenge_desktop/providers/donation_provider.dart';
import 'package:ecochallenge_desktop/providers/location_provider.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/models/request.dart';
import 'package:ecochallenge_desktop/models/donation.dart';
import 'package:ecochallenge_desktop/models/location.dart';

class OverviewPage extends StatefulWidget {
  final VoidCallback? onNavigateToRewards;

  const OverviewPage({Key? key, this.onNavigateToRewards}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  Future<void> _downloadPDFReport() async {
    try {
      final pdf = pw.Document();

      // Add pages to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              _buildPDFHeader(),
              pw.SizedBox(height: 20),

              // Overview Statistics
              _buildPDFOverviewSection(),
              pw.SizedBox(height: 20),

              // Users Section
              _buildPDFUsersSection(),
              pw.SizedBox(height: 20),

              // Requests Section
              _buildPDFRequestsSection(),
              pw.SizedBox(height: 20),

              // Donations Section
              _buildPDFDonationsSection(),
              pw.SizedBox(height: 20),

              // Rewards Section
              _buildPDFRequestParticipationSection(),
              pw.SizedBox(height: 20),

              // Footer
              _buildPDFFooter(),
            ];
          },
        ),
      );

      // Save the PDF
      final Uint8List pdfBytes = await pdf.save();

      // For desktop platforms, use file picker
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Dashboard Report',
          fileName:
              'EcoChallenge_Report_${DateTime.now().toString().substring(0, 10)}.pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputFile != null) {
          File file = File(outputFile);
          await file.writeAsBytes(pdfBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF Report downloaded successfully!'),
              backgroundColor: Color(0xFF2D5016),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // For mobile platforms, save to documents directory
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          String fileName =
              'EcoChallenge_Report_${DateTime.now().toString().substring(0, 10)}.pdf';
          File file = File('${directory.path}/$fileName');
          await file.writeAsBytes(pdfBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF Report saved to: ${file.path}'),
              backgroundColor: Color(0xFF2D5016),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF report: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // PDF Helper Methods
  pw.Widget _buildPDFHeader() {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#2D5016'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EcoChallenge Dashboard Report',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on: ${DateTime.now().toString().substring(0, 19)}',
            style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFOverviewSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Dashboard Overview',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildPDFStatCard('Current Users', _currentUsers.toString()),
              _buildPDFStatCard('Most Cleaned City', _mostCleanedCity),
              _buildPDFStatCard(
                'Average Award',
                '${_averageAwardPrice.toStringAsFixed(1)}KM',
              ),
              _buildPDFStatCard(
                'Approval Rate',
                '${_requestApprovalRate.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPDFStatCard(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#2D5016'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildPDFUsersSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Users Summary',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Total Users: ${_users.length}'),
        pw.Text('Active Users: ${_users.where((u) => u.isActive).length}'),
        pw.Text('Inactive Users: ${_users.where((u) => !u.isActive).length}'),
      ],
    );
  }

  pw.Widget _buildPDFRequestsSection() {
    final pendingRequests = _requests.where((r) => r.statusId == 1).length;
    final approvedRequests = _requests.where((r) => r.statusId == 2).length;
    final rejectedRequests = _requests.where((r) => r.statusId == 3).length;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Requests Summary',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Total Requests: ${_requests.length}'),
        pw.Text('Pending: $pendingRequests'),
        pw.Text('Approved: $approvedRequests'),
        pw.Text('Rejected: $rejectedRequests'),

        if (_requests.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            'Recent Requests:',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Title',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Status',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Date',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ..._requests
                  .take(10)
                  .map(
                    (request) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            request.title ?? 'N/A',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            _getStatusText(request.statusId),
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            request.createdAt.toString().substring(0, 10),
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ],
          ),
        ],
      ],
    );
  }

  pw.Widget _buildPDFDonationsSection() {
    final totalDonations = _donations.fold(0.0, (sum, d) => sum + d.amount);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Donations Summary',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Total Donations: ${_donations.length}'),
        pw.Text('Total Amount: ${totalDonations.toStringAsFixed(2)}KM'),
        if (_donations.isNotEmpty)
          pw.Text(
            'Average Donation: ${(totalDonations / _donations.length).toStringAsFixed(2)}KM',
          ),
      ],
    );
  }

  pw.Widget _buildPDFRequestParticipationSection() {
  final totalAmount = _requestParticipations.fold(0.0, (sum, rp) => sum + rp.rewardMoney);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Processed Payments Summary',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      pw.Text('Total Processed Payments: ${_requestParticipations.length}'),
      pw.Text('Total Amount: ${totalAmount.toStringAsFixed(2)}KM'),
      if (_requestParticipations.isNotEmpty)
        pw.Text(
          'Average Payment: ${(totalAmount / _requestParticipations.length).toStringAsFixed(2)}KM',
        ),
    ],
  );
}

  pw.Widget _buildPDFFooter() {
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Center(
        child: pw.Text(
          'EcoChallenge Desktop Application - Dashboard Report',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ),
    );
  }

  bool _isLoading = true;
  String _error = '';

  // Dashboard data
  int _currentUsers = 0;
  String _mostCleanedCity = "Loading...";
  double _averageAwardPrice = 0.0;
  double _requestApprovalRate = 0.0;

  List<UserResponse> _users = [];
  List<RequestResponse> _requests = [];
  List<DonationResponse> _donations = [];
  List<LocationResponse> _locations = [];
  List<RequestParticipationResponse> _requestParticipations = [];

  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Check if providers are available
      final userProvider = context.read<UserProvider>();
      final requestProvider = context.read<RequestProvider>();
      final donationProvider = context.read<DonationProvider>();
      final locationProvider = context.read<LocationProvider>();

      // Load all data with error handling for each
      try {
        final userResult = await userProvider.get();
        _users = userResult.items ?? [];
      } catch (e) {
        print('Error loading users: $e');
        _users = [];
      }

      try {
        final requestResult = await requestProvider.get();
        _requests = requestResult.items ?? [];
      } catch (e) {
        print('Error loading requests: $e');
        _requests = [];
      }

      try {
        final donationResult = await donationProvider.get();
        _donations = donationResult.items ?? [];
      } catch (e) {
        print('Error loading donations: $e');
        _donations = [];
      }

      try {
        final requestParticipationProvider = context
            .read<RequestParticipationProvider>();
        final participationResult = await requestParticipationProvider.get(
  filter: RequestParticipationSearchObject(
    financeStatus: FinanceStatus.processed,
  ).toJson(),
);
        _requestParticipations = participationResult.items ?? [];
      } catch (e) {
        print('Error loading request participations: $e');
        _requestParticipations = [];
      }

      try {
        final locationResult = await locationProvider.get();
        _locations = locationResult.items ?? [];
      } catch (e) {
        print('Error loading locations: $e');
        _locations = [];
      }

      setState(() {
        _calculateStatistics();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateStatistics() {
    // Current Users (active users)
    _currentUsers = _users.where((user) => user.isActive).length;

    // Most Cleaned City
    if (_locations.isNotEmpty) {
      Map<String, int> cityCounts = {};
      for (var location in _locations) {
        if (location.city != null) {
          cityCounts[location.city!] = (cityCounts[location.city!] ?? 0) + 1;
        }
      }
      if (cityCounts.isNotEmpty) {
        _mostCleanedCity = cityCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
    } else {
      _mostCleanedCity = "Mostar";
    }

    // Average Award Price
    if (_requestParticipations.isNotEmpty) {
  double totalMoney = _requestParticipations.fold(
    0.0,
    (sum, participation) => sum + participation.rewardMoney,
  );
  _averageAwardPrice = totalMoney / _requestParticipations.length;
} else {
  _averageAwardPrice = 35.4; // Default value
}

    // Request Approval Rate
    if (_requests.isNotEmpty) {
      int approvedRequests = _requests.where((req) => req.statusId == 2).length;
      _requestApprovalRate = (approvedRequests / _requests.length) * 100;
    } else {
      _requestApprovalRate = 71.2; // Default value
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5016)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading dashboard data...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Error loading data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                _error,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5016),
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the download button here
            _buildDownloadButton(),

            // Top Stats Cards
            _buildStatsCardsRow(),
            SizedBox(height: 24),

            // Middle Section
            _buildMiddleSection(),
            SizedBox(height: 24),

            // Bottom Section
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: _downloadPDFReport,
          icon: Icon(Icons.picture_as_pdf, size: 20),
          label: Text('Download PDF Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2D5016),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCardsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For smaller screens, stack cards vertically
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      'Current Users',
                      _currentUsers.toString(),
                      Icons.people,
                      Color(0xFF2D5016),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      'Most Cleaned City',
                      _mostCleanedCity,
                      Icons.location_city,
                      Color(0xFF4A6572),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      'Average Award',
                      '${_averageAwardPrice.toStringAsFixed(1)}KM',
                      Icons.attach_money,
                      Color(0xFFD4A574),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      'Approval Rate',
                      '${_requestApprovalRate.toStringAsFixed(1)}%',
                      Icons.thumb_up,
                      Color(0xFFB8860B),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // For larger screens, show in one row
        return Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                'Current Users',
                _currentUsers.toString(),
                Icons.people,
                Color(0xFF2D5016),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                'Most Cleaned City',
                _mostCleanedCity,
                Icons.location_city,
                Color(0xFF4A6572),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                'Average Award',
                '${_averageAwardPrice.toStringAsFixed(1)}KM',
                Icons.attach_money,
                Color(0xFFD4A574),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatsCard(
                'Approval Rate',
                '${_requestApprovalRate.toStringAsFixed(1)}%',
                Icons.thumb_up,
                Color(0xFFB8860B),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiddleSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          // Stack vertically on smaller screens
          return Column(
            children: [
              _buildRequestTrendChart(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDonationsPieChart()),
                  SizedBox(width: 16),
                  Expanded(child: _buildTransactionsList()),
                ],
              ),
            ],
          );
        }

        // Show in row on larger screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildRequestTrendChart()),
            SizedBox(width: 16),
            Expanded(flex: 1, child: _buildDonationsPieChart()),
            SizedBox(width: 16),
            Expanded(flex: 1, child: _buildTransactionsList()),
          ],
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          // Stack vertically on smaller screens
          return Column(
            children: [
              _buildRequestsList(),
              SizedBox(height: 16),
              _buildUserActivityChart(),
            ],
          );
        }

        // Show in row on larger screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildRequestsList()),
            SizedBox(width: 16),
            Expanded(flex: 2, child: _buildUserActivityChart()),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRequestTrendChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        if (value.toInt() < months.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[100], strokeWidth: 1);
                  },
                ),
                barGroups: _getRequestTrendData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getRequestTrendData() {
    // Generate sample data based on actual requests or use default values
    Map<int, int> monthlyRequests = {};

    if (_requests.isNotEmpty) {
      for (var request in _requests) {
        int month = request.createdAt.month - 1;
        if (month >= 0 && month < 12) {
          monthlyRequests[month] = (monthlyRequests[month] ?? 0) + 1;
        }
      }
    } else {
      // Default sample data
      monthlyRequests = {
        0: 25,
        1: 30,
        2: 35,
        3: 20,
        4: 40,
        5: 28,
        6: 22,
        7: 18,
        8: 30,
        9: 25,
        10: 35,
        11: 40,
      };
    }

    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (monthlyRequests[index] ?? 0).toDouble(),
            color: Color(0xFF2D5016),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildDonationsPieChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: _getDonationsPieData(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getDonationsPieData() {
    if (_donations.isEmpty) {
      // Default sample data
      return [
        PieChartSectionData(
          color: Color(0xFF2D5016),
          value: 30,
          title: '30%',
          radius: 40,
          titleStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Color(0xFFD4A574),
          value: 25,
          title: '25%',
          radius: 40,
          titleStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Color(0xFFB8860B),
          value: 25,
          title: '25%',
          radius: 40,
          titleStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Color(0xFF8B4513),
          value: 20,
          title: '20%',
          radius: 40,
          titleStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    // Group donations by amount ranges
    Map<String, double> donationGroups = {
      'Small': 0,
      'Medium': 0,
      'Large': 0,
      'Huge': 0,
    };

    for (var donation in _donations) {
      if (donation.amount < 50) {
        donationGroups['Small'] = donationGroups['Small']! + donation.amount;
      } else if (donation.amount < 200) {
        donationGroups['Medium'] = donationGroups['Medium']! + donation.amount;
      } else if (donation.amount < 500) {
        donationGroups['Large'] = donationGroups['Large']! + donation.amount;
      } else {
        donationGroups['Huge'] = donationGroups['Huge']! + donation.amount;
      }
    }

    double total = donationGroups.values.fold(0, (sum, value) => sum + value);
    if (total == 0) total = 1; // Avoid division by zero

    List<Color> colors = [
      Color(0xFF2D5016),
      Color(0xFFD4A574),
      Color(0xFFB8860B),
      Color(0xFF8B4513),
    ];

    return donationGroups.entries.map((entry) {
      int index = donationGroups.keys.toList().indexOf(entry.key);
      double percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: colors[index],
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTransactionsList() {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to rewards page with transactions view
                if (widget.onNavigateToRewards != null) {
                  widget.onNavigateToRewards!();
                }
              },
              child: Text(
                'View all',
                style: TextStyle(fontSize: 12, color: Color(0xFF2D5016)),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 180,
          child: _requestParticipations.isEmpty
              ? _buildSampleTransactions()
              : ListView.separated(
                  itemCount: _requestParticipations.take(5).length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[100]),
                  itemBuilder: (context, index) {
                    final participation = _requestParticipations[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  participation.cardHolderName ?? 'User ${participation.userId}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  participation.bankName ?? 'Bank Transfer',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${participation.rewardMoney.toStringAsFixed(0)}KM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5016),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}

  Widget _buildSampleTransactions() {
    final sampleTransactions = [
      {'name': 'John Doe', 'type': 'Cleanup', 'amount': '150KM'},
      {'name': 'Jane Smith', 'type': 'Event', 'amount': '200KM'},
      {'name': 'Mike Johnson', 'type': 'Donation', 'amount': '75KM'},
      {'name': 'Sarah Wilson', 'type': 'Cleanup', 'amount': '120KM'},
      {'name': 'Tom Brown', 'type': 'Event', 'amount': '180KM'},
    ];

    return ListView.separated(
      itemCount: sampleTransactions.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[100]),
      itemBuilder: (context, index) {
        final transaction = sampleTransactions[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction['type']!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text(
                transaction['amount']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5016),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsList() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Requests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 180,
            child: _requests.isEmpty
                ? _buildSampleRequests()
                : ListView.separated(
                    itemCount: _requests.take(4).length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[100]),
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getStatusColor(request.statusId),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.title ?? 'Request ${request.id}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _getStatusText(request.statusId),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleRequests() {
    final sampleRequests = [
      {'title': 'River Cleaning', 'status': 'Pending', 'color': Colors.orange},
      {'title': 'Skate Park', 'status': 'Approved', 'color': Colors.green},
      {
        'title': 'University Place',
        'status': 'In Progress',
        'color': Colors.blue,
      },
      {'title': 'City Center', 'status': 'Completed', 'color': Colors.green},
    ];

    return ListView.separated(
      itemCount: sampleRequests.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[100]),
      itemBuilder: (context, index) {
        final request = sampleRequests[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: request['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      request['status'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserActivityChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Activity Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[100], strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        if (value.toInt() < days.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                lineBarsData: _getUserActivityData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<LineChartBarData> _getUserActivityData() {
    // Generate data based on actual user activity or use sample data
    List<FlSpot> activeUsersSpots = [];
    List<FlSpot> newUsersSpots = [];

    if (_users.isNotEmpty) {
      // Calculate actual user activity for the week
      for (int day = 0; day < 7; day++) {
        // Sample calculation - you can modify this based on your actual data
        int activeCount = _users.where((u) => u.isActive).length + (day * 2);
        int newCount = (_users.length / 7).round() + day;

        activeUsersSpots.add(FlSpot(day.toDouble(), activeCount.toDouble()));
        newUsersSpots.add(FlSpot(day.toDouble(), newCount.toDouble()));
      }
    } else {
      // Sample data
      activeUsersSpots = [
        FlSpot(0, 30),
        FlSpot(1, 35),
        FlSpot(2, 32),
        FlSpot(3, 38),
        FlSpot(4, 42),
        FlSpot(5, 45),
        FlSpot(6, 40),
      ];
      newUsersSpots = [
        FlSpot(0, 5),
        FlSpot(1, 8),
        FlSpot(2, 6),
        FlSpot(3, 12),
        FlSpot(4, 10),
        FlSpot(5, 15),
        FlSpot(6, 8),
      ];
    }

    return [
      LineChartBarData(
        spots: activeUsersSpots,
        isCurved: true,
        color: Color(0xFF2D5016),
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          color: Color(0xFF2D5016).withOpacity(0.1),
        ),
        dotData: FlDotData(show: false),
      ),
      LineChartBarData(
        spots: newUsersSpots,
        isCurved: true,
        color: Color(0xFFD4A574),
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          color: Color(0xFFD4A574).withOpacity(0.1),
        ),
        dotData: FlDotData(show: false),
      ),
    ];
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange; // Pending
      case 2:
        return Colors.green; // Approved
      case 3:
        return Colors.red; // Rejected
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int statusId) {
    switch (statusId) {
      case 1:
        return 'Pending';
      case 2:
        return 'Approved';
      case 3:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}
