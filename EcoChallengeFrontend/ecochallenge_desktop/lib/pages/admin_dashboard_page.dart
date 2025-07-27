import 'package:ecochallenge_desktop/pages/management_page.dart';
import 'package:ecochallenge_desktop/pages/overview_page.dart';
import 'package:ecochallenge_desktop/pages/requests_page.dart';
import 'package:ecochallenge_desktop/pages/reward_and_donations_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_desktop/pages/admin_login_page.dart';
import 'package:ecochallenge_desktop/providers/admin_auth_provider.dart';
import 'package:ecochallenge_desktop/providers/balance_setting_provider.dart';
import 'package:ecochallenge_desktop/models/balance_setting.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;
  bool isNavCollapsed = false;
  
  // Balance data
  BalanceSettingResponse? _currentBalance;
  bool _balanceLoading = true;
  String _balanceError = '';
  bool _useStaticBalance = false; // Flag to use static balance when API fails
  
  final BalanceSettingProvider _balanceProvider = BalanceSettingProvider();
  
  @override
  void initState() {
    super.initState();
    _loadBalanceData();
  }
  
  Future<void> _loadBalanceData() async {
    try {
      setState(() {
        _balanceLoading = true;
        _balanceError = '';
        _useStaticBalance = false;
      });
      
      final balance = await _balanceProvider.getCurrentBalance();
      
      setState(() {
        _currentBalance = balance;
        _balanceLoading = false;
      });
    } catch (e) {
      print('Error loading balance: $e');
      
      // Check if it's a 404 error (API endpoint not found)
      if (e.toString().contains('404') || e.toString().contains('Failed to get balance settings')) {
        // Use static/demo balance data as fallback
        setState(() {
          _useStaticBalance = true;
          _currentBalance = _createStaticBalance();
          _balanceLoading = false;
          _balanceError = 'Using demo data - API endpoint not available';
        });
      } else {
        setState(() {
          _balanceError = e.toString();
          _balanceLoading = false;
        });
      }
    }
  }
  
  // Create a static balance for demo purposes
  BalanceSettingResponse _createStaticBalance() {
    return BalanceSettingResponse(
      id: 1,
      wholeBalance: 200000.0,
      balanceLeft: 100000.0,
      updatedAt: DateTime.now(),
      updatedByName: 'Demo Admin',
    );
  }
  
  void _navigateToPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    OverviewPage(onNavigateToRewards: () => _navigateToPage(2)),
    ManagementPage(),
    RewardsPage(),
    RequestsPage(),
  ];
  
  final List<String> _titles = [
    'Overview',
    'Management',
    'Rewards & Donations',
    'Requests',
  ];

  final List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.settings_outlined,
    Icons.card_giftcard_outlined,
    Icons.assignment_outlined,
  ];

  Widget _buildBalanceSection() {
    if (_balanceLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Balance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_currentBalance == null && !_useStaticBalance) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Balance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'API Error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade200,
                fontSize: 10,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Endpoint not found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade200,
                fontSize: 9,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _loadBalanceData,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white70,
                    size: 16,
                  ),
                  tooltip: 'Retry API',
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _useStaticBalance = true;
                      _currentBalance = _createStaticBalance();
                      _balanceError = 'Using demo data';
                    });
                  },
                  icon: Icon(
                    Icons.preview,
                    color: Colors.white70,
                    size: 16,
                  ),
                  tooltip: 'Use Demo Data',
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    // Calculate progress value (0.0 to 1.0)
    double progressValue = _currentBalance!.wholeBalance > 0 
        ? _currentBalance!.balanceLeft / _currentBalance!.wholeBalance 
        : 0.0;
    
    // Format balance text
    String balanceText = '${_currentBalance!.balanceLeft.toStringAsFixed(0)}KM/${_currentBalance!.wholeBalance.toStringAsFixed(0)}KM';
    
    // Determine color based on balance level
    Color progressColor;
    if (_currentBalance!.isCriticalBalance) {
      progressColor = const Color(0xFFEF4444); // Red 500
    } else if (_currentBalance!.isLowBalance) {
      progressColor = const Color(0xFFF97316); // Orange 500
    } else {
      progressColor = Color(0xFFFEFAE0);
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: _useStaticBalance ? Border.all(color: const Color(0xFFF97316), width: 1) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_useStaticBalance)
                    Text(
                      'DEMO',
                      style: TextStyle(
                        color: const Color(0xFFFED7AA), // Orange 200
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  if (_useStaticBalance)
                    Icon(
                      Icons.warning_amber,
                      color: const Color(0xFFFED7AA), // Orange 200
                      size: 14,
                    ),
                  SizedBox(width: 4),
                  IconButton(
                    onPressed: _loadBalanceData,
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white70,
                      size: 16,
                    ),
                    tooltip: _useStaticBalance ? 'Try API Again' : 'Refresh Balance',
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            balanceText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          if (_currentBalance!.isCriticalBalance || _currentBalance!.isLowBalance)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _currentBalance!.isCriticalBalance ? 'Critical!' : 'Low Balance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _currentBalance!.isCriticalBalance 
                      ? const Color(0xFFFECACA) // Red 200
                      : const Color(0xFFFED7AA), // Orange 200
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(height: 12),
          Container(
            height: 8,
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          if (_currentBalance!.updatedByName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Updated by: ${_currentBalance!.updatedByName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 9,
                ),
              ),
            ),
          if (_useStaticBalance)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Demo data - API unavailable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFED7AA), // Orange 200
                  fontSize: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AdminAuthProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Grey 50
      body: Row(
        children: [
          // LEFT SIDEBAR
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: isNavCollapsed ? 80 : 280,
            decoration: BoxDecoration(
              color: const Color(0xFF606C38),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Toggle Button and Logo Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Toggle Button
                      Align(
                        alignment: isNavCollapsed ? Alignment.center : Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isNavCollapsed = !isNavCollapsed;
                            });
                          },
                          icon: Icon(
                            isNavCollapsed ? Icons.menu : Icons.menu_open,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: isNavCollapsed ? 'Expand Menu' : 'Collapse Menu',
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Logo Section
                      Container(
                        width: 100,
                        height: 100,
                        child: Center(
                          child: Image.asset(
                            'assets/images/Eco-Light.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Menu
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isNavCollapsed ? 8 : 16,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _titles.length; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    selectedIndex = i;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isNavCollapsed ? 8 : 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedIndex == i
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: isNavCollapsed
                                      ? Center(
                                          child: Icon(
                                            _icons[i],
                                            color: selectedIndex == i
                                                ? Colors.white
                                                : Colors.white70,
                                            size: 20,
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            Icon(
                                              _icons[i],
                                              color: selectedIndex == i
                                                  ? Colors.white
                                                  : Colors.white70,
                                              size: 20,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              _titles[i],
                                              style: TextStyle(
                                                color: selectedIndex == i
                                                    ? Colors.white
                                                    : Colors.white70,
                                                fontWeight: selectedIndex == i
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Dynamic Balance Section
                if (!isNavCollapsed) _buildBalanceSection(),
                
                // Logout Button
                Container(
                  margin: EdgeInsets.all(isNavCollapsed ? 8 : 16),
                  width: double.infinity,
                  child: isNavCollapsed
                      ? IconButton(
                          onPressed: () async {
                            await auth.logout();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => AdminLoginPage()),
                            );
                          },
                          icon: Icon(
                            Icons.logout,
                            color: const Color(0xFFEF4444), // Red 500
                            size: 20,
                          ),
                          tooltip: 'Log out',
                        )
                      : ElevatedButton.icon(
                          onPressed: () async {
                            await auth.logout();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => AdminLoginPage()),
                            );
                          },
                          icon: Icon(Icons.logout, size: 18),
                          label: Text('Log out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFEFAE0),
                            foregroundColor: Color(0xFF606C38),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                ),
              ],
            ),
          ),
          
          // MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937), // Grey 800
                        ),
                      ),
                      Row(
                        children: [
                          // Search Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6), // Grey 100
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.search,
                              size: 20,
                              color: const Color(0xFF4B5563), // Grey 600
                            ),
                          ),
                          SizedBox(width: 16),
                          
                          // User Avatar with Dropdown
                          PopupMenuButton<String>(
                            offset: Offset(0, 50),
                            onSelected: (value) async {
                              if (value == 'logout') {
                                await auth.logout();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminLoginPage(),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, size: 18),
                                    SizedBox(width: 8),
                                    Text('Log out'),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6), // Grey 100
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFFD1D5DB), // Grey 300
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF4B5563), // Grey 600
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Page Content
                Expanded(
                  child: Container(
                    color: const Color(0xFFFAFAFA), // Grey 50
                    padding: const EdgeInsets.all(24),
                    child: _pages[selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}