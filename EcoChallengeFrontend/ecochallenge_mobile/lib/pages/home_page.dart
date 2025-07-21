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
  List<Request> paidRequests = [];
  List<Event> events = [];
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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

      final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      // Load organizations for donations
      final orgResult = await orgProvider.get();
      
      // Load last 3 paid cleanup requests
      final requestResult = await requestProvider.get(filter: {
        'isPaidRequest': true,
        'take': 3,
        'orderBy': 'createdAt desc'
      });
      
      // Load events
      final eventResult = await eventProvider.get();

      setState(() {
        organizations = orgResult.items as List<Organization>;
        paidRequests = requestResult.items as List<Request>;
        events = eventResult.items as List<Event>;
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
      backgroundColor: const Color(0xFFF5E6D3),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 24),
                                _buildAddRequestButton(),
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
  final user = AuthProvider.userData;
  final displayName = user?.firstName ?? AuthProvider.username ?? 'User';
  
  return Row(
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Be active take the challenge',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
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
                      return const Icon(Icons.person, color: Colors.grey, size: 24);
                    },
                  ),
                )
              : const Icon(Icons.person, color: Colors.grey, size: 24),
        ),
      ),
    ],
  );
}

  Widget _buildAddRequestButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add request/event feature coming soon!')),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDonateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donate',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
                      margin: EdgeInsets.only(right: index < organizations.length - 1 ? 12 : 0),
                      child: Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Donate to ${org.name}')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paid cleanup requests',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        paidRequests.isEmpty
            ? const Center(
                child: Text(
                  'No paid cleanup requests available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : Column(
                children: paidRequests.map((request) => _buildRequestCard(request)).toList(),
              ),
      ],
    );
  }

  Widget _buildRequestCard(Request request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: request.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          request.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.delete_outline, color: Colors.grey[400], size: 32);
                          },
                        ),
                      )
                    : Icon(Icons.delete_outline, color: Colors.grey[400], size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title ?? 'Trash at Park',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.description ?? 'Environmental cleanup needed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request details for: ${request.title}')),
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
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Events/Community',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        events.isEmpty
            ? const Center(
                child: Text(
                  'No events available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : Column(
                children: events.map((event) => _buildEventCard(event)).toList(),
              ),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: event.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          event.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.event, color: Colors.grey[400], size: 32);
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${event.currentParticipants}/${event.maxParticipants} participants',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joined event: ${event.title}')),
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
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2D5016),
        unselectedItemColor: Colors.grey[400],
        currentIndex: 2,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.language, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 26),
            label: '',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Global section coming soon!')),
              );
              break;
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gallery coming soon!')),
              );
              break;
            case 2:
              // Already on home
              break;
            case 3:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon!')),
              );
              break;
            case 4:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat coming soon!')),
              );
              break;
          }
        },
      ),
    );
  }
}