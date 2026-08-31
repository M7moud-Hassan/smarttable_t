import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';

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

  @override
  void didChangeDependencies() {
    bottomTabs = [
      LayoutModel(
          title: context.locale.notifications,
          activeIcon: SvgAssets.bell,
          inActiveIcon: SvgAssets.bell,
          page: const NotificationsView(),
          pageTitle: context.locale.notifications),
      LayoutModel(
          title: context.locale.home,
          activeIcon: SvgAssets.home,
          inActiveIcon: SvgAssets.home,
          page: const HomeView(),
          pageTitle: context.locale.home),
      LayoutModel(
          title: context.locale.myProfile,
          activeIcon: SvgAssets.profile,
          inActiveIcon: SvgAssets.profile,
          page: const ProfileView(),
          pageTitle: context.locale.myProfile),
    ];
    super.didChangeDependencies();
  }

  int currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 1
          ? null
          : AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              title: Text(bottomTabs[currentIndex].title),
            ),
      body: bottomTabs[currentIndex].page,
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 85,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.textGrayColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: [
              ...bottomTabs.map(
                (item) => BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SvgPicture.asset(item.inActiveIcon,
                        colorFilter: const ColorFilter.mode(
                            AppColors.textGrayColor, BlendMode.srcIn)),
                  ),
                  activeIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 5,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SvgPicture.asset(item.activeIcon,
                          colorFilter: const ColorFilter.mode(
                              AppColors.primaryColor, BlendMode.srcIn)),
                    ],
                  ),
                  label: item.title,
                ),
              )
              ]),
        ),
      ),
    );
  }
}
