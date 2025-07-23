import 'package:ecochallenge_desktop/pages/management_page.dart';
import 'package:ecochallenge_desktop/pages/overview_page.dart';
import 'package:ecochallenge_desktop/pages/requests_page.dart';
import 'package:ecochallenge_desktop/pages/reward_and_donations_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_desktop/pages/admin_login_page.dart';
import 'package:ecochallenge_desktop/providers/admin_auth_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;
  bool isNavCollapsed = false;
  
  final List<Widget> _pages = [
    OverviewPage(),
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AdminAuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // 🟩 LEFT SIDEBAR - Updated Design
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
                      
                      // Logo Section - Bigger size
                      Container(
                        width: 100, // Increased from 32
                        height: 100, // Increased from 32
                        child: Center(
                          child: Image.asset(
                            'assets/images/Eco-Light.png', // Your logo path
                            width: 100, // Increased from 24
                            height: 100, // Increased from 24
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Menu - Only the 4 main items
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
                
                // Balance Section - Centered with thicker progress bar
                if (!isNavCollapsed)
                  Container(
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
                          '100000KM/200000KM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 12),
                        // Thicker progress bar
                        Container(
                          height: 8, // Made thicker (was default ~4px)
                          child: LinearProgressIndicator(
                            value: 100000 / 200000,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFEFAE0),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                
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
                            color: Colors.red[400],
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
          
          // 🟦 MAIN CONTENT
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
                          color: Colors.grey[800],
                        ),
                      ),
                      Row(
                        children: [
                          // Search Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.grey[600],
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
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[600],
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
                    color: Colors.grey[50],
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