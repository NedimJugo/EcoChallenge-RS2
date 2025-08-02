import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:ecochallenge_mobile/pages/donation_page.dart';
import 'package:ecochallenge_mobile/pages/selection_page.dart';
import 'package:ecochallenge_mobile/pages/event_detail_page.dart';
import 'package:ecochallenge_mobile/pages/request_detail_page.dart';
import 'package:ecochallenge_mobile/pages/events_list_page.dart';
import 'package:ecochallenge_mobile/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_mobile/models/organization.dart';
import 'package:ecochallenge_mobile/models/request.dart';
import 'package:ecochallenge_mobile/models/event.dart';
import 'package:ecochallenge_mobile/providers/organization_provider.dart';
import 'package:ecochallenge_mobile/providers/request_provider.dart';
import 'package:ecochallenge_mobile/providers/event_provider.dart';
import 'package:ecochallenge_mobile/widgets/profile_panel.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Organization> organizations = [];
  List<RequestResponse> paidRequests = [];
  List<EventResponse> events = [];
  bool isLoading = true;
  String? errorMessage;

  // Animation controller for the profile panel
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isProfilePanelVisible = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleProfilePanel() {
    setState(() {
      _isProfilePanelVisible = !_isProfilePanelVisible;
    });
    if (_isProfilePanelVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeProfilePanel() {
    setState(() {
      _isProfilePanelVisible = false;
    });
    _animationController.reverse();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final orgProvider = Provider.of<OrganizationProvider>(
        context,
        listen: false,
      );
      final requestProvider = Provider.of<RequestProvider>(
        context,
        listen: false,
      );
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Load organizations for donations
      final orgResult = await orgProvider.get();
      // Load last 3 paid cleanup requests
      final requestResult = await requestProvider.get(
        filter: {'isPaidRequest': true, 'take': 3, 'orderBy': 'createdAt desc'},
      );
      // Load last 3 events
      final eventResult = await eventProvider.get(
        filter: {'take': 3, 'orderBy': 'eventDate desc'},
      );

      setState(() {
        organizations = orgResult.items as List<Organization>;
        paidRequests = requestResult.items as List<RequestResponse>;
        events = eventResult.items as List<EventResponse>;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Updated background color to match images better
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? _buildErrorWidget()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildHeader(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 120),
                                    _buildAddRequestButton(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ), // More space to adjust for the button's overlap
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 32),
                                _buildDonateSection(),
                                const SizedBox(height: 32),
                                _buildPaidCleanupSection(),
                                const SizedBox(height: 32),
                                _buildEventsSection(),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          // Overlay when profile panel is visible
          if (_isProfilePanelVisible)
            GestureDetector(
              onTap: _closeProfilePanel,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          // Profile Panel
          if (_isProfilePanelVisible)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: ProfilePanel(onClose: _closeProfilePanel),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = AuthProvider.userData;
    final displayName = user?.firstName ?? AuthProvider.username ?? 'User';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: darkBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 35, 20, 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $displayName,',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Be active take the challenge',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          GestureDetector(
            onTap: _toggleProfilePanel,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: user?.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        user!.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.grey, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRequestButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectionPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D5016),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Add request or event',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Helper method to build section title with decorative line and dots
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Decorative line
            Container(width: 60, height: 2, color: Colors.black87),
            const SizedBox(width: 8),
            // Three dots
            Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDonateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Donate'),
        const SizedBox(height: 16),
        organizations.isEmpty
            ? const Center(
                child: Text(
                  'No organizations available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final org = organizations[index];
                    return Container(
                      width: 130,
                      margin: EdgeInsets.only(
                        right: index < organizations.length - 1 ? 12 : 0,
                      ),
                      child: Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                org.name ?? 'GreenEarth',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                org.category ?? 'Environmental NGO',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DonationPage(organization: org),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD2691E),
                                    foregroundColor: Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text(
                                    'Donate',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildPaidCleanupSection() {
    // Show only first 3 requests
    final displayRequests = paidRequests.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Paid cleanup requests'),
            if (paidRequests.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventsListPage(initialFilter: 'Requests'),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2D5016),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        displayRequests.isEmpty
            ? const Center(
                child: Text(
                  'No paid cleanup requests available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : Column(
                children: displayRequests
                    .map((request) => _buildRequestCard(request))
                    .toList(),
              ),
        if (displayRequests.isNotEmpty && paidRequests.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventsListPage(initialFilter: 'Requests'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D5016),
                  side: const BorderSide(color: Color(0xFF2D5016)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'View All Requests (${paidRequests.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRequestCard(RequestResponse request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestDetailPage(request: request),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      (request.photoUrls != null &&
                          request.photoUrls!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            request.photoUrls!.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.delete_outline,
                                color: Colors.grey[400],
                                size: 32,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.delete_outline,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title ?? 'Small junk',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.description ?? 'Environmental cleanup needed',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${request.suggestedRewardMoney.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RequestDetailPage(request: request),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5016),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    // Show only first 3 events
    final displayEvents = events.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Events/Community'),
            if (events.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventsListPage(initialFilter: 'Events'),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2D5016),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        displayEvents.isEmpty
            ? const Center(
                child: Text(
                  'No events available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : Column(
                children: displayEvents
                    .map((event) => _buildEventCard(event))
                    .toList(),
              ),
        if (displayEvents.isNotEmpty && events.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventsListPage(initialFilter: 'Events'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D5016),
                  side: const BorderSide(color: Color(0xFF2D5016)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'View All Events (${events.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventCard(EventResponse event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(event: event),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      (event.photoUrls != null && event.photoUrls!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event.photoUrls!.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.event,
                                color: Colors.grey[400],
                                size: 32,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.event, color: Colors.grey[400], size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title ?? 'Community Event',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description ?? 'Join our community event',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants} participants',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(event: event),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5016),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Join',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SharedBottomNavigation(
      currentIndex: 2, // Home is at index 2
    );
  }
}
