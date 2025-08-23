import 'package:ecochallenge_mobile/layouts/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request_participation.dart';
import '../models/request.dart';
import '../providers/request_participation_provider.dart';
import '../providers/request_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/participation_details_modal.dart';

class MyRequestParticipationPage extends StatefulWidget {
  @override
  _MyRequestParticipationPageState createState() => _MyRequestParticipationPageState();
}

class _MyRequestParticipationPageState extends State<MyRequestParticipationPage> {
  List<RequestParticipationResponse> _participations = [];
  Map<int, RequestResponse> _requestsMap = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserParticipations();
  }

  Future<void> _loadUserParticipations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final participationProvider = Provider.of<RequestParticipationProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      
      if (authProvider.currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Load user's participations
      final searchObject = RequestParticipationSearchObject(
        userId: authProvider.currentUserId,
        retrieveAll: true,
        sortBy: 'SubmittedAt',
        desc: true,
      );

      final participationResult = await participationProvider.get(filter: searchObject.toJson());
      final participations = participationResult.items ?? [];

      // Load corresponding requests
      Map<int, RequestResponse> requestsMap = {};
      for (var participation in participations) {
        try {
          final requestSearchObject = RequestSearchObject(
            retrieveAll: true,
          );
          final requestResult = await requestProvider.get(filter: requestSearchObject.toJson());
          final request = requestResult.items?.firstWhere(
            (r) => r.id == participation.requestId,
            orElse: () => throw Exception('Request not found'),
          );
          if (request != null) {
            requestsMap[participation.requestId] = request;
          }
        } catch (e) {
          print('Error loading request ${participation.requestId}: $e');
        }
      }
      
      setState(() {
        _participations = participations;
        _requestsMap = requestsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showParticipationDetails(RequestParticipationResponse participation, RequestResponse? request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ParticipationDetailsModal(
        participation: participation,
        request: request,
      ),
    );
  }

  List<RequestParticipationResponse> _getParticipationsByStatus(ParticipationStatus status) {
    return _participations.where((p) => p.status == status).toList();
  }

  String _getParticipationStatusText(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.pending:
        return 'Proof Submitted';
      case ParticipationStatus.approved:
        return 'Verified';
      case ParticipationStatus.rejected:
        return 'Rejected';
    }
  }

  Color _getParticipationStatusColor(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.pending:
        return Colors.orange;
      case ParticipationStatus.approved:
        return Colors.green;
      case ParticipationStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getParticipationStatusIcon(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.pending:
        return Icons.hourglass_empty;
      case ParticipationStatus.approved:
        return Icons.verified;
      case ParticipationStatus.rejected:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My Participations', style: TextStyle(color: Colors.white)),
        backgroundColor: goldenBrown,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserParticipations,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserParticipations,
                  child: _participations.isEmpty
                      ? SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height - 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.eco,
                                      size: 64,
                                      color: Colors.green.withOpacity(0.6),
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'No participations yet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 48),
                                    child: Text(
                                      'Join cleanup events to track your contributions and make a difference!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              // Summary Stats
                              Container(
                                margin: EdgeInsets.all(16),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [forestGreen[500]!, forestGreen[600]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: forestGreen.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      'Total',
                                      _participations.length,
                                      Icons.eco,
                                      Colors.white,
                                    ),
                                    _buildStatItem(
                                      'Verified',
                                      _getParticipationsByStatus(ParticipationStatus.approved).length,
                                      Icons.verified,
                                      Colors.white,
                                    ),
                                    _buildStatItem(
                                      'Pending',
                                      _getParticipationsByStatus(ParticipationStatus.pending).length,
                                      Icons.hourglass_empty,
                                      Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Participations List
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Contributions',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _participations.length,
                                      itemBuilder: (context, index) {
                                        final participation = _participations[index];
                                        final request = _requestsMap[participation.requestId];
                                        return _buildParticipationCard(participation, request);
                                      },
                                    ),
                                    SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipationCard(RequestParticipationResponse participation, RequestResponse? request) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showParticipationDetails(participation, request),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Image with Hero Animation
                    Hero(
                      tag: 'participation_${participation.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green[100]!, Colors.green[200]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: request?.photoUrls != null && request!.photoUrls!.isNotEmpty
                              ? Image.network(
                                  request.photoUrls!.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported, 
                                               color: Colors.green[400], size: 32);
                                  },
                                )
                              : Icon(Icons.eco, color: Colors.green[600], size: 40),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Event Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request?.title ?? 'Unknown Event',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          if (request?.proposedDate != null)
                            Row(
                              children: [
                                Icon(Icons.calendar_today, 
                                     size: 16, color: Colors.grey[500]),
                                SizedBox(width: 6),
                                Text(
                                  _formatDate(request!.proposedDate!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 12),
                          // Enhanced Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getParticipationStatusColor(participation.status).withOpacity(0.1),
                                  _getParticipationStatusColor(participation.status).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getParticipationStatusColor(participation.status),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getParticipationStatusIcon(participation.status),
                                  size: 18,
                                  color: _getParticipationStatusColor(participation.status),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _getParticipationStatusText(participation.status),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _getParticipationStatusColor(participation.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow indicator
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Enhanced Information Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Submitted',
                        _formatDateTime(participation.submittedAt),
                        Icons.schedule,
                        Colors.blue[600]!,
                      ),
                      if (participation.rewardPoints > 0) ...[
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Reward Points',
                          '${participation.rewardPoints}',
                          Icons.stars,
                          Colors.amber[600]!,
                        ),
                      ],
                      if (participation.rewardMoney > 0) ...[
                        SizedBox(height: 12),
                        _buildInfoRow(
                          'Reward Money',
                          '\$${participation.rewardMoney.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green[600]!,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Proof Photos Preview
                if (participation.photoUrls != null && participation.photoUrls!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.photo_library, size: 18, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Proof Photos (${participation.photoUrls!.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: participation.photoUrls!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                participation.photoUrls![index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image_not_supported, 
                                               color: Colors.grey[400], size: 24),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}