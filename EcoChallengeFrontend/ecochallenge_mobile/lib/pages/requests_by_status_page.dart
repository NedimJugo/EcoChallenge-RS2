import 'package:ecochallenge_mobile/widgets/request_details_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../providers/request_provider.dart';

class RequestsByStatusPage extends StatefulWidget {
  final int statusId;
  final String statusName;
  final Color statusColor;
  final List<RequestResponse> requests;
  final Function(RequestResponse) onRequestDeleted;

  const RequestsByStatusPage({
    Key? key,
    required this.statusId,
    required this.statusName,
    required this.statusColor,
    required this.requests,
    required this.onRequestDeleted,
  }) : super(key: key);

  @override
  _RequestsByStatusPageState createState() => _RequestsByStatusPageState();
}

class _RequestsByStatusPageState extends State<RequestsByStatusPage> {
  late List<RequestResponse> _requests;

  @override
  void initState() {
    super.initState();
    _requests = List.from(widget.requests);
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (request.description != null) ...[
                      SizedBox(height: 4),
                      Text(
                        request.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
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
            
            // Notify parent page
            widget.onRequestDeleted(request);
            
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
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getDifficultyText(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low: return 'Easy';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.high:
      case UrgencyLevel.critical: return 'Hard';
    }
  }

  Color _getDifficultyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low: return Colors.green;
      case UrgencyLevel.medium: return Colors.orange;
      case UrgencyLevel.high:
      case UrgencyLevel.critical: return Colors.red;
    }
  }

  String _getStatusName(int statusId) {
    switch (statusId) {
      case 1: return 'To be reviewed';
      case 2: return 'In review';
      case 3: return 'Accepted';
      case 4: return 'Denied';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.statusName} (${_requests.length})',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.statusColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.statusId == 1 ? Icons.schedule :
                    widget.statusId == 2 ? Icons.hourglass_empty :
                    widget.statusId == 3 ? Icons.check_circle :
                    Icons.cancel,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No ${widget.statusName.toLowerCase()} requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return _buildRequestCard(request);
              },
            ),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        request.description ?? 'No description',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                              color: widget.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: widget.statusColor, width: 1),
                            ),
                            child: Text(
                              _getStatusName(request.statusId),
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Submitted: ${_formatDate(request.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                      child: Icon(Icons.delete, color: Colors.white, size: 18),
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