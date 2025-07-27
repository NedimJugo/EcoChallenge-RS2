import 'package:flutter/material.dart';
import 'package:ecochallenge_desktop/models/reward.dart';
import 'package:ecochallenge_desktop/models/donation.dart';
import 'package:ecochallenge_desktop/providers/reward_provider.dart';
import 'package:ecochallenge_desktop/providers/donation_provider.dart';
import 'package:ecochallenge_desktop/models/search_result.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final RewardProvider _rewardProvider = RewardProvider();
  final DonationProvider _donationProvider = DonationProvider();

  // Rewards data
  List<RewardResponse> _rewards = [];
  int _rewardsCurrentPage = 0;
  int _rewardsPageSize = 5;
  int _rewardsTotalCount = 0;
  int _rewardsTotalPages = 0;
  bool _rewardsLoading = false;
  String _rewardsSortBy = 'Amount';
  bool _rewardsSortDesc = true;

  // Donations data
  List<DonationResponse> _donations = [];
  int _donationsCurrentPage = 0;
  int _donationsPageSize = 5;
  int _donationsTotalCount = 0;
  int _donationsTotalPages = 0;
  bool _donationsLoading = false;
  String _donationsSortBy = 'Amount';
  bool _donationsSortDesc = true;

  // Filter controllers
  final TextEditingController _rewardsFilterController = TextEditingController();
  final TextEditingController _donationsFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRewards();
    _loadDonations();
  }

  @override
  void dispose() {
    _rewardsFilterController.dispose();
    _donationsFilterController.dispose();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    setState(() {
      _rewardsLoading = true;
    });

    try {
      final searchObject = RewardSearchObject(
        page: _rewardsCurrentPage,
        pageSize: _rewardsPageSize,
        sortBy: _rewardsSortBy,
        desc: _rewardsSortDesc,
      );

      final result = await _rewardProvider.getRewards(searchObject: searchObject);
      
      setState(() {
        _rewards = result.items ?? [];
        _rewardsTotalCount = result.totalCount ?? 0;
        _rewardsTotalPages = (_rewardsTotalCount / _rewardsPageSize).ceil();
        _rewardsLoading = false;
      });
    } catch (e) {
      setState(() {
        _rewardsLoading = false;
      });
      _showErrorSnackBar('Failed to load rewards: $e');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onRewardsPageChanged(int page) {
    setState(() {
      _rewardsCurrentPage = page;
    });
    _loadRewards();
  }

  void _onDonationsPageChanged(int page) {
    setState(() {
      _donationsCurrentPage = page;
    });
    _loadDonations();
  }

  void _onRewardsSortChanged(String sortBy) {
    setState(() {
      if (_rewardsSortBy == sortBy) {
        _rewardsSortDesc = !_rewardsSortDesc;
      } else {
        _rewardsSortBy = sortBy;
        _rewardsSortDesc = true;
      }
      _rewardsCurrentPage = 0;
    });
    _loadRewards();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rewards Section (Left)
            Expanded(
              child: _buildRewardsSection(),
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

  Widget _buildRewardsSection() {
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
                  'Rewards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Amount',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  height: 32,
                  child: DropdownButton<String>(
                    value: _rewardsSortBy,
                    underline: SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'Amount', child: Text('Sort by', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'CreatedAt', child: Text('Date', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'UserName', child: Text('Name', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (value) {
                      if (value != null) _onRewardsSortChanged(value);
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
            child: _rewardsLoading
                ? Center(child: CircularProgressIndicator())
                : _buildRewardsTable(),
          ),
          // Pagination
          _buildRewardsPagination(),
        ],
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

  Widget _buildRewardsTable() {
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
              Expanded(flex: 3, child: Text('Approved By', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Expanded(flex: 2, child: Text('Amount(BAM)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView.builder(
            itemCount: _rewards.length,
            itemBuilder: (context, index) {
              final reward = _rewards[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text('${(_rewardsCurrentPage * _rewardsPageSize) + index + 1}', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(reward.userName ?? 'Unknown', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(reward.approvedByAdminName ?? 'Pending', style: TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text('${reward.moneyAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12))),
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

  Widget _buildRewardsPagination() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Text(
            '${(_rewardsCurrentPage * _rewardsPageSize) + 1}-${((_rewardsCurrentPage + 1) * _rewardsPageSize).clamp(0, _rewardsTotalCount)} of $_rewardsTotalCount',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Spacer(),
          IconButton(
            onPressed: _rewardsCurrentPage > 0 ? () => _onRewardsPageChanged(_rewardsCurrentPage - 1) : null,
            icon: Icon(Icons.chevron_left, size: 20),
          ),
          IconButton(
            onPressed: _rewardsCurrentPage < _rewardsTotalPages - 1 ? () => _onRewardsPageChanged(_rewardsCurrentPage + 1) : null,
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
}
