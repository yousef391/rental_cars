import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _rentalReminders = true;
  bool _maintenanceAlerts = true;
  bool _licenseExpiryAlerts = true;
  bool _insuranceRenewalAlerts = true;
  bool _overdueAlerts = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  int _rentalReminderHours = 1;
  int _maintenanceReminderDays = 7;
  int _licenseExpiryDays = 30;
  int _insuranceExpiryDays = 14;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rentalReminders =
          prefs.getBool('notifications_rental_reminders') ?? true;
      _maintenanceAlerts =
          prefs.getBool('notifications_maintenance_alerts') ?? true;
      _licenseExpiryAlerts =
          prefs.getBool('notifications_license_alerts') ?? true;
      _insuranceRenewalAlerts =
          prefs.getBool('notifications_insurance_alerts') ?? true;
      _overdueAlerts = prefs.getBool('notifications_overdue_alerts') ?? true;
      _soundEnabled = prefs.getBool('notifications_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notifications_vibration') ?? true;

      _rentalReminderHours = prefs.getInt('rental_reminder_hours') ?? 1;
      _maintenanceReminderDays = prefs.getInt('maintenance_reminder_days') ?? 7;
      _licenseExpiryDays = prefs.getInt('license_expiry_days') ?? 30;
      _insuranceExpiryDays = prefs.getInt('insurance_expiry_days') ?? 14;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_rental_reminders', _rentalReminders);
    await prefs.setBool('notifications_maintenance_alerts', _maintenanceAlerts);
    await prefs.setBool('notifications_license_alerts', _licenseExpiryAlerts);
    await prefs.setBool(
        'notifications_insurance_alerts', _insuranceRenewalAlerts);
    await prefs.setBool('notifications_overdue_alerts', _overdueAlerts);
    await prefs.setBool('notifications_sound', _soundEnabled);
    await prefs.setBool('notifications_vibration', _vibrationEnabled);

    await prefs.setInt('rental_reminder_hours', _rentalReminderHours);
    await prefs.setInt('maintenance_reminder_days', _maintenanceReminderDays);
    await prefs.setInt('license_expiry_days', _licenseExpiryDays);
    await prefs.setInt('insurance_expiry_days', _insuranceExpiryDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey.shade800),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings
            _buildSectionCard(
              'General Settings',
              Icons.settings,
              [
                _buildSwitchTile(
                  'Enable Sound',
                  'Play sound for notifications',
                  Icons.volume_up,
                  _soundEnabled,
                  (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  'Enable Vibration',
                  'Vibrate for notifications',
                  Icons.vibration,
                  _vibrationEnabled,
                  (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Rental Reminders
            _buildSectionCard(
              'Rental Reminders',
              Icons.local_shipping,
              [
                _buildSwitchTile(
                  'Pickup & Return Reminders',
                  'Get notified before rental pickup and return',
                  Icons.schedule,
                  _rentalReminders,
                  (value) {
                    setState(() {
                      _rentalReminders = value;
                    });
                    _saveSettings();
                  },
                ),
                if (_rentalReminders) ...[
                  SizedBox(height: 16.h),
                  _buildSliderTile(
                    'Reminder Time',
                    '$_rentalReminderHours hour${_rentalReminderHours == 1 ? '' : 's'} before',
                    Icons.access_time,
                    1.0,
                    24.0,
                    _rentalReminderHours.toDouble(),
                    (value) {
                      setState(() {
                        _rentalReminderHours = value.round();
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),

            // Maintenance Alerts
            _buildSectionCard(
              'Maintenance Alerts',
              Icons.build,
              [
                _buildSwitchTile(
                  'Maintenance Reminders',
                  'Get notified about upcoming vehicle maintenance',
                  Icons.warning,
                  _maintenanceAlerts,
                  (value) {
                    setState(() {
                      _maintenanceAlerts = value;
                    });
                    _saveSettings();
                  },
                ),
                if (_maintenanceAlerts) ...[
                  SizedBox(height: 16.h),
                  _buildSliderTile(
                    'Reminder Time',
                    '$_maintenanceReminderDays day${_maintenanceReminderDays == 1 ? '' : 's'} before',
                    Icons.access_time,
                    1,
                    30,
                    _maintenanceReminderDays.toDouble(),
                    (value) {
                      setState(() {
                        _maintenanceReminderDays = value.round();
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),

            // License Expiry Alerts
            _buildSectionCard(
              'License Expiry Alerts',
              Icons.credit_card,
              [
                _buildSwitchTile(
                  'License Expiry Reminders',
                  'Get notified about expiring driver licenses',
                  Icons.warning,
                  _licenseExpiryAlerts,
                  (value) {
                    setState(() {
                      _licenseExpiryAlerts = value;
                    });
                    _saveSettings();
                  },
                ),
                if (_licenseExpiryAlerts) ...[
                  SizedBox(height: 16.h),
                  _buildSliderTile(
                    'Reminder Time',
                    '$_licenseExpiryDays day${_licenseExpiryDays == 1 ? '' : 's'} before',
                    Icons.access_time,
                    7,
                    90,
                    _licenseExpiryDays.toDouble(),
                    (value) {
                      setState(() {
                        _licenseExpiryDays = value.round();
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),

            // Insurance Renewal Alerts
            _buildSectionCard(
              'Insurance Renewal Alerts',
              Icons.security,
              [
                _buildSwitchTile(
                  'Insurance Renewal Reminders',
                  'Get notified about expiring vehicle insurance',
                  Icons.warning,
                  _insuranceRenewalAlerts,
                  (value) {
                    setState(() {
                      _insuranceRenewalAlerts = value;
                    });
                    _saveSettings();
                  },
                ),
                if (_insuranceRenewalAlerts) ...[
                  SizedBox(height: 16.h),
                  _buildSliderTile(
                    'Reminder Time',
                    '$_insuranceExpiryDays day${_insuranceExpiryDays == 1 ? '' : 's'} before',
                    Icons.access_time,
                    1,
                    60,
                    _insuranceExpiryDays.toDouble(),
                    (value) {
                      setState(() {
                        _insuranceExpiryDays = value.round();
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),

            // Overdue Alerts
            _buildSectionCard(
              'Overdue Alerts',
              Icons.error,
              [
                _buildSwitchTile(
                  'Overdue Rental Alerts',
                  'Get notified about overdue rentals',
                  Icons.warning,
                  _overdueAlerts,
                  (value) {
                    setState(() {
                      _overdueAlerts = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            SizedBox(height: 100.h), // Space for bottom
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
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
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade600,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double min,
    double max,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
            activeColor: Colors.blue.shade600,
            inactiveColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
