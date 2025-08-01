import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rentra/domain/models/vehicle.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:rentra/domain/models/rental.dart';
import 'package:rentra/domain/models/vehicle.dart';
import 'package:rentra/domain/models/customer.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs for different types
  static const int _rentalReminderId = 1000;
  static const int _maintenanceAlertId = 2000;
  static const int _licenseExpiryId = 3000;
  static const int _insuranceRenewalId = 4000;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to specific screens here
    print('Notification tapped: ${response.payload}');
  }

  // Rental Reminders
  Future<void> scheduleRentalReminder(
      Rental rental, DateTime reminderTime, String type) async {
    final id = _rentalReminderId + rental.id.hashCode;

    await _notifications.zonedSchedule(
      id,
      'Rental Reminder',
      type == 'pickup'
          ? 'Pickup reminder: Vehicle ${rental.vehicleId} is ready for pickup'
          : 'Return reminder: Vehicle ${rental.vehicleId} is due for return',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rental_reminders',
          'Rental Reminders',
          channelDescription:
              'Notifications for rental pickup and return reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'rental_${rental.id}_$type',
    );
  }

  // Maintenance Alerts
  Future<void> scheduleMaintenanceAlert(
      Vehicle vehicle, DateTime maintenanceDate) async {
    final id = _maintenanceAlertId + vehicle.id.hashCode;

    await _notifications.zonedSchedule(
      id,
      'Maintenance Alert',
      'Vehicle ${vehicle.make} ${vehicle.model} (${vehicle.licensePlate}) needs maintenance',
      tz.TZDateTime.from(maintenanceDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'maintenance_alerts',
          'Maintenance Alerts',
          channelDescription: 'Notifications for vehicle maintenance reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'maintenance_${vehicle.id}',
    );
  }

  // License Expiry Alerts
  Future<void> scheduleLicenseExpiryAlert(
      Customer customer, DateTime expiryDate) async {
    final id = _licenseExpiryId + customer.id.hashCode;

    await _notifications.zonedSchedule(
      id,
      'License Expiry Alert',
      'Customer ${customer.fullName} license expires on ${_formatDate(expiryDate)}',
      tz.TZDateTime.from(expiryDate.subtract(const Duration(days: 30)),
          tz.local), // 30 days before
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'license_alerts',
          'License Expiry Alerts',
          channelDescription:
              'Notifications for driver license expiry reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'license_${customer.id}',
    );
  }

  // Insurance Renewal Alerts
  Future<void> scheduleInsuranceRenewalAlert(
      Vehicle vehicle, DateTime renewalDate) async {
    final id = _insuranceRenewalId + vehicle.id.hashCode;

    await _notifications.zonedSchedule(
      id,
      'Insurance Renewal Alert',
      'Vehicle ${vehicle.make} ${vehicle.model} insurance expires on ${_formatDate(renewalDate)}',
      tz.TZDateTime.from(renewalDate.subtract(const Duration(days: 14)),
          tz.local), // 14 days before
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'insurance_alerts',
          'Insurance Renewal Alerts',
          channelDescription:
              'Notifications for vehicle insurance renewal reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'insurance_${vehicle.id}',
    );
  }

  // Schedule all rental reminders for a rental
  Future<void> scheduleRentalReminders(Rental rental) async {
    // Pickup reminder - 1 hour before pickup
    final pickupReminder = rental.startDate.subtract(const Duration(hours: 1));
    if (pickupReminder.isAfter(DateTime.now())) {
      await scheduleRentalReminder(rental, pickupReminder, 'pickup');
    }

    // Return reminder - 2 hours before return
    final returnReminder = rental.endDate.subtract(const Duration(hours: 2));
    if (returnReminder.isAfter(DateTime.now())) {
      await scheduleRentalReminder(rental, returnReminder, 'return');
    }
  }

  // Schedule maintenance alerts for all maintenance records
  Future<void> scheduleMaintenanceAlerts(Vehicle vehicle) async {
    for (final record in vehicle.maintenanceRecords) {
      if (record.nextDueDate != null &&
          record.nextDueDate!.isAfter(DateTime.now())) {
        await scheduleMaintenanceAlert(vehicle, record.nextDueDate!);
      }
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel all rental reminders for a specific rental
  Future<void> cancelRentalReminders(String rentalId) async {
    final pickupId = _rentalReminderId + rentalId.hashCode;
    final returnId = _rentalReminderId + rentalId.hashCode + 1;

    await _notifications.cancel(pickupId);
    await _notifications.cancel(returnId);
  }

  // Cancel maintenance alerts for a specific vehicle
  Future<void> cancelMaintenanceAlerts(String vehicleId) async {
    final id = _maintenanceAlertId + vehicleId.hashCode;
    await _notifications.cancel(id);
  }

  // Cancel license alerts for a specific customer
  Future<void> cancelLicenseAlerts(String customerId) async {
    final id = _licenseExpiryId + customerId.hashCode;
    await _notifications.cancel(id);
  }

  // Cancel insurance alerts for a specific vehicle
  Future<void> cancelInsuranceAlerts(String vehicleId) async {
    final id = _insuranceRenewalId + vehicleId.hashCode;
    await _notifications.cancel(id);
  }

  // Show immediate notification (for testing or urgent alerts)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate_alerts',
          'Immediate Alerts',
          channelDescription: 'Immediate notifications for urgent alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Check and schedule overdue alerts
  Future<void> checkAndScheduleOverdueAlerts({
    required List<Rental> rentals,
    required List<Vehicle> vehicles,
    required List<Customer> customers,
  }) async {
    final now = DateTime.now();

    // Check for overdue rentals
    for (final rental in rentals) {
      if (rental.status == RentalStatus.active &&
          rental.endDate.isBefore(now)) {
        await showImmediateNotification(
          title: 'Overdue Rental Alert',
          body: 'Rental ${rental.id} is overdue for return',
          payload: 'overdue_rental_${rental.id}',
        );
      }
    }

    // Check for expired licenses
    for (final customer in customers) {
      // This would need to be implemented based on your customer model
      // You might need to add license expiry date to the customer model
    }

    // Check for expired insurance
    for (final vehicle in vehicles) {
      // This would need to be implemented based on your vehicle model
      // You might need to add insurance expiry date to the vehicle model
    }
  }
}
