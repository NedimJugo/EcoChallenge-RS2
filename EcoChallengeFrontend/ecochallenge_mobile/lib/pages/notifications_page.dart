import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ecochallenge_mobile/models/notification.dart';
import 'package:ecochallenge_mobile/providers/notification_provider.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationResponse> _notifications = [];
  List<NotificationResponse> _filteredNotifications = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  late NotificationProvider _notificationProvider;
  late AuthProvider _authProvider;
  
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _notificationProvider = NotificationProvider();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _searchController.addListener(_onSearchChanged);
    _loadNotifications();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredNotifications = _notifications;
      } else {
        _filteredNotifications = _notifications.where((notification) {
          final title = (notification.title ?? notification.notificationType.displayName).toLowerCase();
          final message = (notification.message ?? '').toLowerCase();
          return title.contains(query) || message.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authProvider.currentUserId;
      if (userId != null) {
        final notifications = await _notificationProvider.getByUser(userId);
        if (mounted) {
          setState(() {
            _notifications = notifications;
            _filteredNotifications = notifications;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshNotifications() async {
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      final userId = _authProvider.currentUserId;
      if (userId != null) {
        final notifications = await _notificationProvider.getByUser(userId);
        if (mounted) {
          setState(() {
            _notifications = notifications;
            _filteredNotifications = notifications;
            _isRefreshing = false;
          });
          _onSearchChanged(); // Reapply search filter
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = _authProvider.currentUserId;
    if (userId == null) return;

    try {
      await _notificationProvider.markAllAsRead(userId);
      await _refreshNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(NotificationResponse notification) async {
    if (notification.isRead) return;

    try {
      await _notificationProvider.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationResponse(
            id: notification.id,
            userId: notification.userId,
            notificationType: notification.notificationType,
            title: notification.title,
            message: notification.message,
            isRead: true,
            isPushed: notification.isPushed,
            createdAt: notification.createdAt,
            readAt: DateTime.now(),
          );
        }
      });
      _onSearchChanged(); // Update filtered list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleNotificationTap(NotificationResponse notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }
    _showNotificationDialog(notification);
  }

  void _showNotificationDialog(NotificationResponse notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Image.asset(
                          notification.notificationType.iconAsset,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getDefaultIcon(notification.notificationType),
                              color: const Color(0xFF4CAF50),
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.notificationType.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: subtitleColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  notification.title ?? notification.notificationType.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
                
                // Message
                if (notification.message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    notification.message!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Got it',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToNotificationTarget(NotificationResponse notification) {
    // Mark as read when navigating
    if (!notification.isRead) {
      _markAsRead(notification);
    }
    
    // Navigate based on notification type (placeholder navigation)
    String message = 'Opened ${notification.notificationType.displayName}';
    switch (notification.notificationType) {
      case NotificationType.RequestApproved:
      case NotificationType.RequestRejected:
        message = 'Navigate to requests page';
        break;
      case NotificationType.EventReminder:
        message = 'Navigate to events page';
        break;
      case NotificationType.RewardReceived:
      case NotificationType.BadgeEarned:
        message = 'Navigate to rewards page';
        break;
      case NotificationType.ChatMessage:
        message = 'Navigate to chat';
        break;
      case NotificationType.AdminMessage:
        message = 'Admin message opened';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  List<NotificationResponse> get _unreadNotifications {
    return _filteredNotifications.where((n) => !n.isRead).toList();
  }

  List<NotificationResponse> get _readNotifications {
    return _filteredNotifications.where((n) => n.isRead).toList();
  }

  int get _unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all as read',
                style: TextStyle(
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_isSearching)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search notifications...',
                        hintStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(Icons.search, color: subtitleColor),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () => _searchController.clear(),
                                icon: Icon(Icons.clear, color: subtitleColor),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: subtitleColor!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                        filled: true,
                        fillColor: backgroundColor,
                      ),
                      style: TextStyle(color: textColor),
                    ),
                  ),
                
                // Notifications list
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? _buildEmptyState(isDarkMode, textColor, subtitleColor)
                      : RefreshIndicator(
                          onRefresh: _refreshNotifications,
                          color: const Color(0xFF4CAF50),
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Unread notifications section
                              if (_unreadNotifications.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Unread (${_unreadNotifications.length})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                ..._unreadNotifications.map((notification) =>
                                    _buildNotificationTile(
                                        notification, cardColor, textColor, subtitleColor, isDarkMode)),
                                const SizedBox(height: 24),
                              ],
                              
                              // Read notifications section
                              if (_readNotifications.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Read',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                ..._readNotifications.map((notification) =>
                                    _buildNotificationTile(
                                        notification, cardColor, textColor, subtitleColor, isDarkMode)),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, Color? textColor, Color? subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty ? Icons.search_off : Icons.notifications_none_outlined,
            size: 80,
            color: subtitleColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty ? 'No matching notifications' : 'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty 
                ? 'Try adjusting your search terms'
                : 'When you receive notifications, they\'ll appear here',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    NotificationResponse notification,
    Color? cardColor,
    Color? textColor,
    Color? subtitleColor,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Image.asset(
                      notification.notificationType.iconAsset,
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getDefaultIcon(notification.notificationType),
                          color: const Color(0xFF4CAF50),
                          size: 20,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title ?? notification.notificationType.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      if (notification.message != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.message!,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDefaultIcon(NotificationType type) {
    switch (type) {
      case NotificationType.RequestApproved:
        return Icons.check_circle_outline;
      case NotificationType.RequestRejected:
        return Icons.cancel_outlined;
      case NotificationType.EventReminder:
        return Icons.event_outlined;
      case NotificationType.RewardReceived:
        return Icons.card_giftcard_outlined;
      case NotificationType.BadgeEarned:
        return Icons.military_tech_outlined;
      case NotificationType.ChatMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.AdminMessage:
        return Icons.admin_panel_settings_outlined;
    }
  }
}
