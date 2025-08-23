import 'package:ecochallenge_desktop/layouts/constants.dart';
import 'package:ecochallenge_desktop/pages/management/badge_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/badge_type_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/balance_settings_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/event_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/event_type_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/gallery_showcase_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/location_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/organization_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/user_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/user_type_management_page.dart';
import 'package:ecochallenge_desktop/pages/management/waste_type_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({Key? key}) : super(key: key);

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final ScrollController _tabScrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<TabInfo> _tabs = [
    TabInfo(
      icon: Icons.people_rounded,
      label: 'Users',
      page: UserManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.category_rounded,
      label: 'User Types',
      page: UserTypeManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.location_on_rounded,
      label: 'Locations',
      page: LocationManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.recycling_rounded,
      label: 'Waste Types',
      page: WasteTypeManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.military_tech_rounded,
      label: 'Badge Types',
      page: BadgeTypeManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.business_rounded,
      label: 'Organizations',
      page: OrganizationManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.event_rounded,
      label: 'Event Types',
      page: EventTypeManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.stars_rounded,
      label: 'Badges',
      page: BadgeManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Balance Settings',
      page: BalanceSettingManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.event_available_rounded,
      label: 'Events',
      page: EventManagementPage(),
      color: goldenBrown,
    ),
    TabInfo(
      icon: Icons.photo_library_rounded,
      label: 'Gallery Showcases',
      page: GalleryShowcaseManagementPage(),
      color: goldenBrown,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = _tabs[_selectedTabIndex];
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Enhanced tab bar with modern design
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedTab.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: selectedTab.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Management Sections',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                    scrollbars: false,
                  ),
                  child: Scrollbar(
                    controller: _tabScrollController,
                    thumbVisibility: true,
                    thickness: 6,
                    radius: const Radius.circular(3),
                    child: SingleChildScrollView(
                      controller: _tabScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tabs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tab = entry.value;
                          final isSelected = _selectedTabIndex == index;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTabIndex = index;
                                });
                                _fadeController.reset();
                                _fadeController.forward();
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              tab.color,
                                              tab.color.withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    color: isSelected 
                                      ? null 
                                      : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isSelected 
                                        ? tab.color
                                        : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: tab.color.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        tab.icon,
                                        size: 20,
                                        color: isSelected 
                                          ? Colors.white 
                                          : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        tab.label,
                                        style: TextStyle(
                                          color: isSelected 
                                            ? Colors.white 
                                            : Colors.grey[700],
                                          fontWeight: isSelected 
                                            ? FontWeight.w600 
                                            : FontWeight.w500,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content area with fade animation and modern card design
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _tabs[_selectedTabIndex].page,
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
    _tabScrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

class TabInfo {
  final IconData icon;
  final String label;
  final Widget page;
  final Color color;

  TabInfo({
    required this.icon,
    required this.label,
    required this.page,
    required this.color,
  });
}