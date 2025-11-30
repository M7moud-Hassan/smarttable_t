import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/helpers.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';
import 'package:smart_table_app/features/profile/presentation/views/aboutus_view.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../core/widgets/confirm_dialog_widget.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../class_timing/presentation/views/class_timing_view.dart';
import '../../../contact_us/presentation/views/contact_us_view.dart';
import '../../providers/profile_provider.dart';
import '../widgets/language_switch.dart';
import '../widgets/profile_item_widget.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return Padding(
      padding: pgHorizontalPadding18,
      child: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.pinkColor,
                child: Text(
                  profile.teacherName[0],
                  style: context.textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '${profile.teacherNameLabel} / ${profile.teacherName} ',
                  style: context.textTheme.titleLarge,
                ),
              ),
              Text(profile.schoolName),
              const SizedBox(
                height: 50,
              ),
              Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.locale.settings,
                    style: context.textTheme.titleMedium!.copyWith(
                        fontSize: 17,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 10,
              ),
              ProfileItemWidget(
                title: context.locale.classTiming,
                onTap: () {
                  context.push(const ClassTimingView());
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const LanguageSwitch(),
              const SizedBox(
                height: 50,
              ),
              Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.locale.infoData,
                    style: context.textTheme.titleMedium!.copyWith(
                        fontSize: 17,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 10,
              ),
              ProfileItemWidget(
                title: context.locale.privacyPolicy,
                onTap: () {
                  final currentLocale = context.locale.localeName;
                  openLink(
                    '${AppConstants.privacyPolicyLink}$currentLocale/',
                  );
                },
              ),
              // ProfileItemWidget(
              //   title: context.locale.termsConditions,
              //   onTap: () {
              //       openLink(
              //       '${AppConstants.}',
              //     );
              //   }
              // ),
              ProfileItemWidget(
                  title: context.locale.deleteAccount,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ConfirmDialogWidget(
                              title: context.locale.confirmDeleteAccount,
                              onConfirm: () {
                                ref.read(authProvider.notifier).deleteAccount();
                              });
                        });
                  }),
              ProfileItemWidget(
                title: context.locale.aboutUs,
                onTap: () {
                  context.push(const AboutUsView());
                },
              ),
              ProfileItemWidget(
                title: context.locale.contactUs,
                onTap: () {
                  context.push(const ContactUsView());
                },
              ),
              ProfileItemWidget(
                title: context.locale.logout,
                color: Colors.red,
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    shareText('''
                      **اكتشف تطبيق Smartble P – مساعدك الذكي في إدارة العملية التعليمية**  
                      
                      صُمم تطبيق **Smartble P** خصيصًا للمعلمين لمساعدتهم على إدارة مهامهم وتنظيم جداولهم بكل سهولة وفعالية. الآن يمكنك التركيز على التعليم بينما يقوم التطبيق بالباقي!  
                      
                      🌟 **روابط التحميل**:  
                      - 📱 **لأجهزة الآيفون (App Store)**: [Smartble P على App Store](https://apps.apple.com/us/app/smartble-p/id6478277343)  
                      - 🤖 **لأجهزة الأندرويد (Google Play)**: [Smartble P على Google Play](https://play.google.com/store/apps/details?id=com.smartable.tables&hl=ar&pli=1)  
                      
                      ابدأ باستخدام **Smartble P** اليوم، واجعل إدارة فصولك الدراسية أكثر سهولة وتنظيمًا! ✨  
                      ''');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(SvgAssets.share),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        context.locale.shareWithFrieds,
                        style: context.textTheme.titleMedium!.copyWith(
                            fontSize: 17,
                            color: const Color(0xFFA5910B),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                PngAssets.whiteBlackLogo,
                color: Colors.grey,
              )
            ],
          ),
        ),
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomErrorWidget(
                onTap: () => ref.invalidate(profileProvider),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: 180,
                height: 45,
                child: AppButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    context.locale.logout,
                    style: context.textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
