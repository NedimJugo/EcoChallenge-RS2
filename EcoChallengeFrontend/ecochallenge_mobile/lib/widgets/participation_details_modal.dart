import 'package:flutter/material.dart';
import '../models/request_participation.dart';
import '../models/request.dart';

class ParticipationDetailsModal extends StatelessWidget {
  final RequestParticipationResponse participation;
  final RequestResponse? request;

  const ParticipationDetailsModal({
    Key? key,
    required this.participation,
    this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Participation Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(height: 1, color: Colors.grey[200]),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Image
                          Hero(
                            tag: 'participation_${participation.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green[100]!, Colors.green[200]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: request?.photoUrls != null && request!.photoUrls!.isNotEmpty
                                    ? Image.network(
                                        request!.photoUrls!.first,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.image_not_supported, 
                                                     color: Colors.green[400], size: 40);
                                        },
                                      )
                                    : Icon(Icons.eco, color: Colors.green[600], size: 50),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Event Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request?.title ?? 'Unknown Event',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                if (request?.description != null) ...[
                                  Text(
                                    request!.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 12),
                                ],
                                _buildStatusBadge(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Event Details Section
                      if (request != null) ...[
                        _buildSectionHeader('Event Information', Icons.event),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Column(
                            children: [
                              if (request!.proposedDate != null)
                                _buildDetailRow('Event Date', _formatDate(request!.proposedDate!)),
                              if (request!.proposedTime != null) ...[
                                SizedBox(height: 8),
                                _buildDetailRow('Event Time', request!.proposedTime!),
                              ],
                              if (request!.estimatedCleanupTime != null) ...[
                                SizedBox(height: 8),
                                _buildDetailRow('Duration', '${request!.estimatedCleanupTime} minutes'),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                      
                      // Participation Details Section
                      _buildSectionHeader('Your Participation', Icons.person),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Submitted', _formatDateTime(participation.submittedAt)),
                            if (participation.approvedAt != null) ...[
                              SizedBox(height: 8),
                              _buildDetailRow('Approved', _formatDateTime(participation.approvedAt!)),
                            ],
                            if (participation.adminNotes != null) ...[
                              SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.admin_panel_settings, 
                                             color: Colors.blue[600], size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Admin Notes',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[800],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      participation.adminNotes!,
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Rewards Section
                      if (participation.rewardPoints > 0 || participation.rewardMoney > 0) ...[
                        _buildSectionHeader('Rewards Earned', Icons.card_giftcard),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber[50]!, Colors.orange[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Column(
                            children: [
                              if (participation.rewardPoints > 0)
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.stars, color: Colors.amber[700], size: 20),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Points Earned',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${participation.rewardPoints}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                  ],
                                ),
                              if (participation.rewardMoney > 0) ...[
                                if (participation.rewardPoints > 0) SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.attach_money, color: Colors.green[700], size: 20),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Money Earned',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${participation.rewardMoney.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                      
                      // Proof Photos Section
                      if (participation.photoUrls != null && participation.photoUrls!.isNotEmpty) ...[
                        _buildSectionHeader('Proof Photos', Icons.photo_library),
                        SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: participation.photoUrls!.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
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
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green[700], size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color = _getParticipationStatusColor(participation.status);
    String text = _getParticipationStatusText(participation.status);
    IconData icon = _getParticipationStatusIcon(participation.status);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  String _getParticipationStatusText(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.pending:
        return 'Proof Submitted';
      case ParticipationStatus.approved:
        return 'Verified';
      case ParticipationStatus.rejected:
        return 'Under Review';
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}