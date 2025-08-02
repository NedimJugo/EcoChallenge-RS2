import 'package:flutter/material.dart';
import '../models/request.dart';

class RequestDetailsModal extends StatelessWidget {
  final RequestResponse request;
  final VoidCallback? onDelete;

  const RequestDetailsModal({
    Key? key,
    required this.request,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Request Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              Divider(height: 1),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              request.title ?? 'Untitled Request',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 12),
                          _buildStatusBadge(),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Photos
                      if (request.photoUrls != null && request.photoUrls!.isNotEmpty) ...[
                        Text(
                          'Photos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: request.photoUrls!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    request.photoUrls![index],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                      
                      // Description
                      if (request.description != null) ...[
                        Text(
                          'Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          request.description!,
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                        SizedBox(height: 20),
                      ],
                      
                      // Details Grid
                      _buildDetailsGrid(),
                      
                      SizedBox(height: 20),
                      
                      // Admin Notes
                      if (request.adminNotes != null) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.admin_panel_settings, 
                                       color: Colors.blue[600], size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Admin Notes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                request.adminNotes!,
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                      
                      // Rejection Reason
                      if (request.rejectionReason != null) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cancel, color: Colors.red[600], size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Rejection Reason',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[800],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                request.rejectionReason!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                      
                      // Delete Button
                      if (onDelete != null && request.statusId == 1) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete!();
                            },
                            icon: Icon(Icons.delete),
                            label: Text('Delete Request'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;
    
    switch (request.statusId) {
      case 1:
        color = Colors.orange;
        text = 'To be reviewed';
        icon = Icons.schedule;
        break;
      case 2:
        color = Colors.blue;
        text = 'In review';
        icon = Icons.hourglass_empty;
        break;
      case 3:
        color = Colors.green;
        text = 'Accepted';
        icon = Icons.check_circle;
        break;
      case 4:
        color = Colors.red;
        text = 'Denied';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
        icon = Icons.help;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow('Difficulty', _getDifficultyText(request.urgencyLevel)),
          _buildDetailRow('Estimated Time', '${request.estimatedCleanupTime ?? 'N/A'} minutes'),
          _buildDetailRow('Waste Amount', request.estimatedAmount.displayName),
          _buildDetailRow('Suggested Points', '${request.suggestedRewardPoints}'),
          _buildDetailRow('Suggested Money', '\$${request.suggestedRewardMoney.toStringAsFixed(2)}'),
          if (request.proposedDate != null)
            _buildDetailRow('Proposed Date', _formatDate(request.proposedDate!)),
          if (request.proposedTime != null)
            _buildDetailRow('Proposed Time', request.proposedTime!),
          _buildDetailRow('Submitted', _formatDateTime(request.createdAt)),
          if (request.approvedAt != null)
            _buildDetailRow('Approved', _formatDateTime(request.approvedAt!)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low: return 'Easy';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.high:
      case UrgencyLevel.critical: return 'Hard';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}