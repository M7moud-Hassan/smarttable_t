import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io' show Platform;
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/auth/data/repositories/auth_repo.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  _printMessageData(message);
}

class FirebaseMessagingService {
  FirebaseMessagingService();
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.high,
  );

  // Channel specifically for class reminders
  final _classRemindersChannel = const AndroidNotificationChannel(
    'class_reminders_channel',
    'Class Reminders',
    description: 'This channel is used for teacher class reminders',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();
  static String? fcmToken;

  Future<void> initNotifications(WidgetRef ref) async {
    await Firebase.initializeApp();

    // Initialize timezone properly (required for scheduled notifications)
    tz.initializeTimeZones();
    // Set timezone for Pontianak, Indonesia - MOVED HERE
    // tz.setLocalLocation(tz.getLocation('Asia/Pontianak'));
    // log('Local timezone set to: ${tz.local.name}');

    // Request permission for notifications
    await _requestNotificationPermissions();

    // Initialize local notifications first (changed order)
    await _initLocalNotifications();

    // Initialize push notifications
    await _initPushNotifications();

    // Listen for token changes
    _listenForTokenChanges(ref);
  }

  Future<void> _requestNotificationPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, // Added for clarity
      criticalAlert: true, // Added for important notifications
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
    await fetchFCMToken();
  }

  Future<String?> fetchFCMToken() async {
    try {
      if (Platform.isIOS) {
        // Wait until APNs token is set
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNs token is null, waiting...');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _firebaseMessaging.getAPNSToken();
        }
        debugPrint('APNs Token: $apnsToken');
      }

      fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) log('FCM Token: $fcmToken');
      return fcmToken ?? '';
    } catch (e) {
      debugPrint('Error fetching FCM Token: $e');
      return null;
    }
  }

  void _listenForTokenChanges(WidgetRef ref) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token has been refreshed: $newToken');
      fcmToken = newToken; // Update the token variable with the new token
      ref.read(authRepoProvider).updateFcm();
    });
  }

  Future<void> _initPushNotifications() async {
    // iOS: Necessary for foreground notifications
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle notification when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);

    // Handle notification when the app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Listen to foreground push notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listen to background push notifications
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onForegroundMessageSelected,
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
    await platform?.createNotificationChannel(_classRemindersChannel);

    // Check pending notifications (useful for debugging)
    final pendingNotifications =
        await _localNotifications.pendingNotificationRequests();
    for (var notification in pendingNotifications) {
      if (kDebugMode)
        log('Pending notification: ${notification.id}, ${notification.title}, ${notification.body}');
    }
  }

  void _onForegroundMessageSelected(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    // Check if this is a class reminder notification (which won't have JSON payload)
    if (payload.startsWith('classReminder:')) {
      // Handle class reminder notification tap
      final classInfo = payload.substring('classReminder:'.length);
      ;
      return;
    }

    try {
      // Handle Firebase notification
      final message = RemoteMessage.fromMap(jsonDecode(payload));
      _handleMessage(message);
    } catch (e) {
      log('Error parsing notification payload: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    if (Platform.isAndroid) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    }
    _printMessageData(message);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message != null) {
      debugPrint('PushType ===> _onMessageOpenedApp');
      _printMessageData(message);
    }
  }

  // TEACHER CLASS REMINDER FUNCTIONS

  // Schedule a weekly class reminder for a specific day and time
  Future<void> scheduleClassReminder({
    required int id,
    required int dayOfWeek,
    required TimeOfDay time,
    required String className,
    required String desc,
    int reminderMinutesBefore = 15,
  }) async {
    // Get the current date and time
    final DateTime now = DateTime.now();

    // Calculate the next occurrence with proper day handling
    int daysUntilNextOccurrence = (dayOfWeek - now.weekday) % 7;

    // If today is the target day, check if the time has already passed
    if (daysUntilNextOccurrence == 0) {
      // Check if target time is in the past for today
      final todayTarget =
          DateTime(now.year, now.month, now.day, time.hour, time.minute);

      if (todayTarget
          .subtract(Duration(minutes: reminderMinutesBefore))
          .isBefore(now)) {
        daysUntilNextOccurrence = 7; // Schedule for next week
      }
    }

    // Calculate the exact class date/time
    final targetDate = now.add(Duration(days: daysUntilNextOccurrence));
    final classTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      time.hour,
      time.minute,
    );

    // Calculate reminder time
    final reminderTime =
        classTime.subtract(Duration(minutes: reminderMinutesBefore));

    // Create a proper TZDateTime object
    final tz.TZDateTime scheduledTZ =
        tz.TZDateTime.from(reminderTime, tz.local);

    // Debug logging for verification
    if (kDebugMode) {
      log('Current time: ${now.toString()}');
      log('Target day of week: $dayOfWeek');
      log('Days until occurrence: $daysUntilNextOccurrence');
      log('Class time: ${classTime.toString()}');
      log('Reminder time: ${reminderTime.toString()}');
      log('TZ Scheduled time: ${scheduledTZ.toString()}');
    }

    // Configure notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _classRemindersChannel.id,
      _classRemindersChannel.name,
      channelDescription: _classRemindersChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'mipmap/ic_launcher',
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Day names for better notification content
    final List<String> dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final String dayName = dayNames[dayOfWeek - 1]; // day is 1-7, array is 0-6

    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    try {
      // Schedule the notification
      await _localNotifications.zonedSchedule(
        id, // Unique ID for this class reminder
        className,
        desc,
        scheduledTZ,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: {
          'className': className,
          'desc': desc,
          'dayOfWeek': dayOfWeek.toString(),
          'time': formattedTime,
        }.toString(), // Pass the payload as a string
      );

      if (kDebugMode)
        log('Successfully scheduled class reminder for $className on $dayName at $formattedTime');
    } catch (e) {
      if (kDebugMode) log('Error scheduling notification: $e');
    }
  }

  // Cancel a specific class reminder
  Future<void> cancelClassReminder(int id) async {
    await _localNotifications.cancel(id);
    if (kDebugMode) log('Cancelled reminder with ID: $id');
  }

  // Cancel all class reminders (but not FCM notifications)
  Future<void> cancelAllClassReminders() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _localNotifications.pendingNotificationRequests();

    if (kDebugMode)
      log('Cancelling all class reminders. Found ${pendingNotifications.length} pending notifications');

    // Filter for class reminder IDs (assuming you use a specific ID range for class reminders)
    for (var notification in pendingNotifications) {
      if (notification.id >= 1000 && notification.id < 2000) {
        await _localNotifications.cancel(notification.id);
        if (kDebugMode)
          log('Cancelled class reminder: ${notification.id}, ${notification.title}');
      }
    }
  }
}

void _printMessageData(RemoteMessage message) {
  debugPrint(message.toMap().toString());
  debugPrint('''
  Notification Title ===> ${message.notification?.title}
  Notification Body ===> ${message.notification?.body}
  Notification Payload ===> ${message.data}
  ''');
}

// Riverpod provider for FirebaseMessagingService
final firebaseMessagingServiceProvider =
    Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});
