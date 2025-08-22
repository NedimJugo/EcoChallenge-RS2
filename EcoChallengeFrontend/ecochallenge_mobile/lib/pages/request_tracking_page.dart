import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../providers/request_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/request_details_modal.dart';
import 'my_request_participation_page.dart';
import 'requests_by_status_page.dart';

class RequestsTrackingPage extends StatefulWidget {
  @override
  _RequestsTrackingPageState createState() => _RequestsTrackingPageState();
}

class _RequestsTrackingPageState extends State<RequestsTrackingPage> {
  List<RequestResponse> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserRequests();
  }

  Future<void> _loadUserRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      
      if (authProvider.currentUserId == null) {
        throw Exception('User not logged in');
      }

      final requests = await requestProvider.getUserRequests(authProvider.currentUserId!);
      
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRequest(RequestResponse request) async {
    try {
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      
      // Check if request can be deleted
      if (!requestProvider.canDeleteRequest(request)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Only requests that are "To be reviewed" can be deleted'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Request'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this request?'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title ?? 'Untitled Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (request.description != null) ...[
                      SizedBox(height: 4),
                      Text(
                        request.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deleting request...'),
              ],
            ),
          ),
        );

        try {
          // Call the delete API
          final success = await requestProvider.deleteRequest(request.id);
          
          // Close loading dialog
          Navigator.of(context).pop();
          
          if (success) {
            // Remove from local list
            setState(() {
              _requests.removeWhere((r) => r.id == request.id);
            });
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Request deleted successfully'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          // Close loading dialog
          Navigator.of(context).pop();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Failed to delete request: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _deleteRequest(request),
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRequestDetails(RequestResponse request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RequestDetailsModal(
        request: request,
        onDelete: () => _deleteRequest(request),
      ),
    );
  }

  List<RequestResponse> _getRequestsByStatus(int statusId) {
    return _requests.where((request) => request.statusId == statusId).toList();
  }

  String _getStatusName(int statusId) {
    switch (statusId) {
      case 1:
        return 'To be reviewed';
      case 2:
        return 'In review';
      case 3:
        return 'Accepted';
      case 4:
        return 'Denied';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low:
        return 'Easy';
      case UrgencyLevel.medium:
        return 'Medium';
      case UrgencyLevel.high:
      case UrgencyLevel.critical:
        return 'Hard';
    }
  }

  Color _getDifficultyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low:
        return Colors.green;
      case UrgencyLevel.medium:
        return Colors.orange;
      case UrgencyLevel.high:
      case UrgencyLevel.critical:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          // Button to navigate to My Request Participation page
          IconButton(
            icon: Icon(Icons.eco, color: Colors.white),
            tooltip: 'My Participations',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyRequestParticipationPage(),
                ),
              );
            },
          ),
        ],
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
                        onPressed: _loadUserRequests,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserRequests,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Quick access button to My Participations
                        Container(
                          margin: EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MyRequestParticipationPage(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.eco),
                              label: Text('View My Participations'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Summary stats
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Total', _requests.length, Colors.grey),
                              _buildStatItem('Pending', _getRequestsByStatus(1).length, Colors.orange),
                              _buildStatItem('Approved', _getRequestsByStatus(3).length, Colors.green),
                              _buildStatItem('Denied', _getRequestsByStatus(4).length, Colors.red),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        // Requests list
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusSection(1), // To be reviewed
                              SizedBox(height: 24),
                              _buildStatusSection(3), // Accepted
                              SizedBox(height: 24),
                              _buildStatusSection(4), // Denied
                              SizedBox(height: 32), // Extra padding at bottom
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(int statusId) {
    final allRequests = _getRequestsByStatus(statusId);
    final statusName = _getStatusName(statusId);
    final statusColor = _getStatusColor(statusId);
    
    // Show max 3 items, rest in "View All"
    final displayRequests = allRequests.take(3).toList();
    final hasMore = allRequests.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              statusName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              statusId == 1 ? Icons.schedule :
              statusId == 2 ? Icons.hourglass_empty :
              statusId == 3 ? Icons.check_circle :
              Icons.cancel,
              color: statusColor,
              size: 20,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${allRequests.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (allRequests.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              statusId == 4 ? 'No denies yet' : 'No requests in this status',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          // Show up to 3 requests
          ...displayRequests.map((request) => _buildRequestCard(request)).toList(),
          
          // Show "View All" button if there are more than 3 requests
          if (hasMore)
            Container(
              margin: EdgeInsets.only(top: 8),
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RequestsByStatusPage(
                        statusId: statusId,
                        statusName: statusName,
                        statusColor: statusColor,
                        requests: allRequests,
                        onRequestDeleted: (deletedRequest) {
                          setState(() {
                            _requests.removeWhere((r) => r.id == deletedRequest.id);
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.visibility, size: 18),
                label: Text('View All ${allRequests.length} ${statusName}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: statusColor,
                  side: BorderSide(color: statusColor.withOpacity(0.5)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRequestCard(RequestResponse request) {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final canDelete = requestProvider.canDeleteRequest(request);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showRequestDetails(request),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Request Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: request.photoUrls != null && request.photoUrls!.isNotEmpty
                        ? Image.network(
                            request.photoUrls!.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image_not_supported, color: Colors.grey);
                            },
                          )
                        : Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                SizedBox(width: 16),
                // Request Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title ?? 'Untitled Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        request.description ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          // Difficulty Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(request.urgencyLevel).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getDifficultyColor(request.urgencyLevel),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getDifficultyText(request.urgencyLevel),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDifficultyColor(request.urgencyLevel),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(request.statusId).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(request.statusId),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getStatusName(request.statusId),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(request.statusId),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Submitted: ${_formatDate(request.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete Button (only for "To be reviewed")
                if (canDelete)
                  GestureDetector(
                    onTap: () => _deleteRequest(request),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 18,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}