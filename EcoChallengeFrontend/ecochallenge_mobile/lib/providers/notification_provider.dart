import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ecochallenge_mobile/models/notification.dart';
import 'package:ecochallenge_mobile/providers/base_provider.dart';

class NotificationProvider extends BaseProvider<NotificationResponse> {
  NotificationProvider() : super("Notification");

  @override
  NotificationResponse fromJson(data) {
    return NotificationResponse.fromJson(data);
  }

  // Create bulk notifications
  Future<List<NotificationResponse>> createBulk(List<NotificationInsertRequest> requests) async {
    try {
      var baseUrl = this.baseUrl;
      var endpoint = this.endpoint;
      var url = "$baseUrl/$endpoint/bulk";
      
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var body = requests.map((r) => r.toJson()).toList();
      
      var response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var jsonData = jsonDecode(response.body);
        return (jsonData as List).map((item) => fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Check your credentials");
      } else {
        throw Exception("Server error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      var baseUrl = this.baseUrl;
      var endpoint = this.endpoint;
      var url = "$baseUrl/$endpoint/$notificationId/mark-as-read";
      
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var response = await http.patch(uri, headers: headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Check your credentials");
      } else {
        throw Exception("Server error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // Mark all notifications as read for a user
  Future<int> markAllAsRead(int userId) async {
    try {
      var baseUrl = this.baseUrl;
      var endpoint = this.endpoint;
      var url = "$baseUrl/$endpoint/user/$userId/mark-all-as-read";
      
      var uri = Uri.parse(url);
      var headers = createHeaders();
      
      var response = await http.patch(uri, headers: headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return int.parse(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Check your credentials");
      } else {
        throw Exception("Server error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // Get notifications by user
  Future<List<NotificationResponse>> getByUser(int userId, {bool? isRead}) async {
    final searchObject = NotificationSearchObject(
      userId: userId,
      isRead: isRead,
      retrieveAll: true,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.items ?? [];
  }

  // Get unread notifications count
  Future<int> getUnreadCount(int userId) async {
    final searchObject = NotificationSearchObject(
      userId: userId,
      isRead: false,
    );
    
    final result = await super.get(filter: searchObject.toJson());
    return result.totalCount ?? 0;
  }
}