import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:offline_rent_car/data/services/notification_service.dart';
import 'package:offline_rent_car/data/services/localization_service.dart';
import 'package:offline_rent_car/presentation/widgets/notification_settings.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final LocalizationService _localizationService = LocalizationService();
  List<PendingNotificationRequest> _pendingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  Future<void> _loadPendingNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications =
          await _notificationService.getPendingNotifications();
      setState(() {
        _pendingNotifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                SizedBox(height: 24.h),

                // Notifications List
                Expanded(
                  child: _buildNotificationsList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Manage scheduled alerts and reminders',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _loadPendingNotifications,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade700],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettings(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade600, Colors.red.shade700],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showClearAllDialog,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_pendingNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _pendingNotifications.length,
        itemBuilder: (context, index) {
          final notification = _pendingNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading notifications...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Scheduled Notifications',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'All notifications will appear here when scheduled',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(PendingNotificationRequest notification) {
    final notificationType = _getNotificationType(notification.id);
    final scheduledDate = _getScheduledDate(notification);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNotificationDetails(notification),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notificationType)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _getNotificationIcon(notificationType),
                    color: _getNotificationColor(notificationType),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? 'Notification',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.body ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Scheduled: ${DateFormat('MMM dd, yyyy HH:mm').format(scheduledDate)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  onSelected: (value) {
                    if (value == 'cancel') {
                      _cancelNotification(notification.id);
                    } else if (value == 'details') {
                      _showNotificationDetails(notification);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue, size: 16.sp),
                          SizedBox(width: 8.w),
                          const Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red, size: 16.sp),
                          SizedBox(width: 8.w),
                          const Text('Cancel'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNotificationType(int id) {
    if (id >= 1000 && id < 2000) return 'rental';
    if (id >= 2000 && id < 3000) return 'maintenance';
    if (id >= 3000 && id < 4000) return 'license';
    if (id >= 4000 && id < 5000) return 'insurance';
    return 'general';
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'rental':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'license':
        return Colors.purple;
      case 'insurance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'rental':
        return Icons.local_shipping;
      case 'maintenance':
        return Icons.build;
      case 'license':
        return Icons.credit_card;
      case 'insurance':
        return Icons.security;
      default:
        return Icons.notifications;
    }
  }

  DateTime _getScheduledDate(PendingNotificationRequest notification) {
    // This is a simplified version - in a real app you'd store the scheduled date
    // For now, we'll use the current time plus some offset based on the ID
    return DateTime.now().add(Duration(hours: notification.id % 24));
  }

  Future<void> _cancelNotification(int id) async {
    try {
      await _notificationService.cancelNotification(id);
      await _loadPendingNotifications();
      _showSuccessSnackBar('Notification cancelled successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to cancel notification');
    }
  }

  void _showNotificationDetails(PendingNotificationRequest notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title ?? 'Notification Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body ?? '',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'ID: ${notification.id}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
            if (notification.payload != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Payload: ${notification.payload}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
            'Are you sure you want to cancel all scheduled notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllNotifications();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      await _loadPendingNotifications();
      _showSuccessSnackBar('All notifications cleared successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to clear notifications');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
