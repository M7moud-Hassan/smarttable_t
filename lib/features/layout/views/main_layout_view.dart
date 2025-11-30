import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/service/class_reminder_service.dart';
import 'package:smart_table_app/features/class_timing/providers/class_timing_notifer.dart';
import 'package:smart_table_app/features/home/presentation/views/home_view.dart';
import 'package:svg_flutter/svg.dart';
import '../../../core/service/firebase_messaging_service.dart';
import '../../auth/data/repositories/auth_repo.dart';
import '../../notifications/presentation/views/notifications_view.dart';
import '../../profile/presentation/views/profile_view.dart';
import '../data/models/layout_model.dart';

class MainLayoutView extends ConsumerStatefulWidget {
  const MainLayoutView({super.key, this.requestFcm = false});
  final bool requestFcm;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends ConsumerState<MainLayoutView> {
  List<LayoutModel> bottomTabs = [];
  // late TeacherScheduleManager _scheduleManager;
  final FirebaseMessagingService _notificationService =
      FirebaseMessagingService();

  @override
  void initState() {
    super.initState();
    // Initialize notification service and schedule manager
    // _scheduleManager = TeacherScheduleManager(_notificationService);

    // Start initialization sequence
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize notifications if requested
    if (widget.requestFcm) {
      await initNotifications();
    }
    ref.read(classTimingProvider);
    // Send a test notification to verify immediate notifications work
    // await _notificationService.sendTestNotification();

    // Clear any existing reminders and schedule new test reminder
    // await _addReminder();

    // Also schedule a test notification for 2 minutes from now
  }

  Future<void> initNotifications() async {
    await _notificationService.initNotifications(ref);

    // Update FCM token with server
    await ref.read(authRepoProvider).updateFcm();
  }

  // Future<void> _addReminder() async {
  //   log('Setting up test class reminder...');

  //   // Clear any existing reminders
  //   await _scheduleManager.clearAllReminders();

  //   // Get current time
  //   final now = DateTime.now();
  //   // Create a time 3 minutes from now
  //   final reminderTime = TimeOfDay(
  //       hour: now.hour,
  //       minute: (now.minute + 3) % 60 // Add 3 minutes, wrap around if needed
  //       );

  //   // If we crossed an hour boundary
  //   final adjustedHour =
  //       (now.minute + 3) >= 60 ? (now.hour + 1) % 24 : now.hour;
  //   final adjustedTime =
  //       TimeOfDay(hour: adjustedHour, minute: (now.minute + 3) % 60);

  //   // Schedule for today
  //   await _scheduleManager.addClassReminder(
  //     dayOfWeek: now.weekday,
  //     time: adjustedTime,
  //     className: "Test Class",
  //     location: "Room 101",
  //     reminderMinutesBefore: 1, // 1 minute before
  //   );

  //   log('Test class reminder added for today at ${adjustedTime.hour}:${adjustedTime.minute}');
  // }

  @override
  void didChangeDependencies() {
    bottomTabs = [
      LayoutModel(
          title: context.locale.home,
          activeIcon: SvgAssets.homeBold,
          inActiveIcon: SvgAssets.homeOutline,
          page: const HomeView(),
          pageTitle: context.locale.home),
      LayoutModel(
          title: context.locale.notifications,
          activeIcon: SvgAssets.notificationBold,
          inActiveIcon: SvgAssets.notificationOutline,
          page: const NotificationsView(),
          pageTitle: context.locale.notifications),
      LayoutModel(
          title: context.locale.myProfile,
          activeIcon: SvgAssets.userBold,
          inActiveIcon: SvgAssets.userOutline,
          page: const ProfileView(),
          pageTitle: context.locale.myProfile),
    ];
    super.didChangeDependencies();
  }

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black54,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Image.asset(
                PngAssets.appLogoSmall,
                width: 40,
              ),
            ),
            const SizedBox(width: 10),
            Text(bottomTabs[currentIndex].title),
          ],
        ),
      ),
      body: bottomTabs[currentIndex].page,
      bottomNavigationBar: SizedBox(
        height: 82,
        child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            items: [
              ...bottomTabs.map(
                (item) => BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: SvgPicture.asset(item.inActiveIcon),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: SvgPicture.asset(item.activeIcon),
                  ),
                  label: item.title,
                ),
              )
            ]),
      ),
    );
  }
}
