import 'package:ecochallenge_desktop/pages/reward_and_donations_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecochallenge_desktop/providers/user_provider.dart';
import 'package:ecochallenge_desktop/providers/request_provider.dart';
import 'package:ecochallenge_desktop/providers/donation_provider.dart';
import 'package:ecochallenge_desktop/providers/reward_provider.dart';
import 'package:ecochallenge_desktop/providers/location_provider.dart';
import 'package:ecochallenge_desktop/models/user.dart';
import 'package:ecochallenge_desktop/models/request.dart';
import 'package:ecochallenge_desktop/models/donation.dart';
import 'package:ecochallenge_desktop/models/reward.dart';
import 'package:ecochallenge_desktop/models/location.dart';

class OverviewPage extends StatefulWidget {
  final VoidCallback? onNavigateToRewards;
  
  const OverviewPage({Key? key, this.onNavigateToRewards}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
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
  List<RewardResponse> _rewards = [];
  List<LocationResponse> _locations = [];

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
      final rewardProvider = context.read<RewardProvider>();
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
        final rewardResult = await rewardProvider.get();
        _rewards = rewardResult.items ?? [];
      } catch (e) {
        print('Error loading rewards: $e');
        _rewards = [];
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
    if (_rewards.isNotEmpty) {
      double totalMoney = _rewards.fold(0.0, (sum, reward) => sum + reward.moneyAmount);
      _averageAwardPrice = totalMoney / _rewards.length;
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
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading dashboard data...'),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text('Error loading data'),
              SizedBox(height: 8),
              Text(_error, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stats Cards (removed header section)
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

  // Removed _buildHeader() method since it's duplicate

  Widget _buildStatsCardsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For smaller screens, stack cards vertically
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatsCard(
                    'Current Users',
                    _currentUsers.toString(),
                    Color(0xFF2D5016),
                    Colors.white,
                  )),
                  SizedBox(width: 12),
                  Expanded(child: _buildStatsCard(
                    'Most Cleaned City',
                    _mostCleanedCity,
                    Color(0xFFF5F5F5),
                    Colors.black87,
                  )),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatsCard(
                    'Average Award Price',
                    '${_averageAwardPrice.toStringAsFixed(1)}KM',
                    Color(0xFFD4A574),
                    Colors.white,
                  )),
                  SizedBox(width: 12),
                  Expanded(child: _buildStatsCard(
                    'Request Approval Rate',
                    '${_requestApprovalRate.toStringAsFixed(1)}%',
                    Color(0xFFB8860B),
                    Colors.white,
                  )),
                ],
              ),
            ],
          );
        }
        
        // For larger screens, show in one row
        return Row(
          children: [
            Expanded(child: _buildStatsCard(
              'Current Users',
              _currentUsers.toString(),
              Color(0xFF2D5016),
              Colors.white,
            )),
            SizedBox(width: 12),
            Expanded(child: _buildStatsCard(
              'Most Cleaned City',
              _mostCleanedCity,
              Color(0xFFF5F5F5),
              Colors.black87,
            )),
            SizedBox(width: 12),
            Expanded(child: _buildStatsCard(
              'Average Award Price',
              '${_averageAwardPrice.toStringAsFixed(1)}KM',
              Color(0xFFD4A574),
              Colors.white,
            )),
            SizedBox(width: 12),
            Expanded(child: _buildStatsCard(
              'Request Approval Rate',
              '${_requestApprovalRate.toStringAsFixed(1)}%',
              Color(0xFFB8860B),
              Colors.white,
            )),
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
              _buildMostActivePlacesChart(),
            ],
          );
        }
        
        // Show in row on larger screens
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _buildRequestsList()),
            SizedBox(width: 16),
            Expanded(flex: 2, child: _buildMostActivePlacesChart()),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
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
            height: 180,
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
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: TextStyle(fontSize: 10),
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
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
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
        if (month >= 0 && month < 6) {
          monthlyRequests[month] = (monthlyRequests[month] ?? 0) + 1;
        }
      }
    } else {
      // Default sample data
      monthlyRequests = {0: 25, 1: 30, 2: 35, 3: 20, 4: 40, 5: 28};
    }

    return List.generate(6, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (monthlyRequests[index] ?? 0).toDouble(),
            color: index % 2 == 0 ? Color(0xFFD4A574) : Color(0xFF2D5016),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
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
                centerSpaceRadius: 30,
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
          title: 'Small\n30%',
          radius: 40,
          titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        PieChartSectionData(
          color: Color(0xFFD4A574),
          value: 25,
          title: 'Medium\n25%',
          radius: 40,
          titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        PieChartSectionData(
          color: Color(0xFFB8860B),
          value: 25,
          title: 'Large\n25%',
          radius: 40,
          titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        PieChartSectionData(
          color: Color(0xFF8B4513),
          value: 20,
          title: 'Huge\n20%',
          radius: 40,
          titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
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
        title: '${entry.key}\n${percentage.toStringAsFixed(0)}%',
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
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
                'Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Use the callback to navigate to Rewards & Donations page
                if (widget.onNavigateToRewards != null) {
                  widget.onNavigateToRewards!();
                }
                },
                child: Text(
                  'View all',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 180,
            child: _rewards.isEmpty 
              ? _buildSampleTransactions()
              : ListView.builder(
                  itemCount: _rewards.take(5).length,
                  itemBuilder: (context, index) {
                    final reward = _rewards[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reward.userName ?? 'User ${reward.userId}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  reward.reason ?? 'Reward',
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
                            '${reward.moneyAmount.toStringAsFixed(0)}KM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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

    return ListView.builder(
      itemCount: sampleTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sampleTransactions[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
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
                    Text(
                      transaction['type']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                transaction['amount']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requests',
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
              : ListView.builder(
                  itemCount: _requests.take(4).length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
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
      {'title': 'University Place', 'status': 'In Progress', 'color': Colors.blue},
      {'title': 'City Center', 'status': 'Completed', 'color': Colors.green},
    ];

    return ListView.builder(
      itemCount: sampleRequests.length,
      itemBuilder: (context, index) {
        final request = sampleRequests[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
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
                    Text(
                      request['status'] as String,
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
    );
  }

  Widget _buildMostActivePlacesChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Most Active Places',
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
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(fontSize: 10),
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
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: _getMostActivePlacesData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<LineChartBarData> _getMostActivePlacesData() {
    // Generate sample data for different locations
    List<Color> colors = [
      Color(0xFF2D5016),
      Color(0xFFD4A574),
      Color(0xFFB8860B),
    ];

    return List.generate(3, (index) {
      return LineChartBarData(
        spots: List.generate(7, (dayIndex) {
          return FlSpot(dayIndex.toDouble(), (20 + (index * 10) + (dayIndex * 5)).toDouble());
        }),
        isCurved: true,
        color: colors[index],
        barWidth: 3,
        dotData: FlDotData(show: false),
      );
    });
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1: return Colors.orange; // Pending
      case 2: return Colors.green;  // Approved
      case 3: return Colors.red;    // Rejected
      default: return Colors.grey;
    }
  }

  String _getStatusText(int statusId) {
    switch (statusId) {
      case 1: return 'Pending';
      case 2: return 'Approved';
      case 3: return 'Rejected';
      default: return 'Unknown';
    }
  }
}