import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/helpers.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';
import 'package:smart_table_app/features/profile/presentation/views/aboutus_view.dart';

import '../../../../core/widgets/confirm_dialog_widget.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../class_timing/presentation/views/class_timing_view.dart';
import '../../../contact_us/presentation/views/contact_us_view.dart';
import '../../providers/profile_provider.dart';
import '../widgets/language_switch.dart';
import '../widgets/profile_item_widget.dart';
import 'teacher_signature_view.dart';

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
                // In a real app we would load profile.imageUrl, but using the initials for now
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
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: Text(
                  '${profile.teacherNameLabel} / ${profile.teacherName} ',
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('@${profile.schoolName}',
                  style:
                      const TextStyle(color: Color(0xFF8D8D8D), fontSize: 13)),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(130, 36),
                  backgroundColor:
                      const Color(0xFF4AC2C5), // Teal primary color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  context.locale.editPicture,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const LanguageSwitch(),
              ProfileItemWidget(
                title: context.locale.classTiming,
                icon: SvgAssets.timing,
                onTap: () {
                  context.push(const ClassTimingView());
                },
              ),
              ProfileItemWidget(
                title: context.locale.changePassword,
                icon: SvgAssets.lock3,
                onTap: () {},
              ),
              ProfileItemWidget(
                title: context.locale.teacherSignature,
                icon: SvgAssets.signature,
                onTap: () {
                  context.push(const TeacherSignatureView());
                },
              ),
              ProfileItemWidget(
                title: context.locale.aboutUs,
                icon: SvgAssets.mdiAbout,
                onTap: () {
                  context.push(const AboutUsView());
                },
              ),
              ProfileItemWidget(
                title: context.locale.faq,
                icon: SvgAssets.faQuestion,
                onTap: () {},
              ),
              ProfileItemWidget(
                title: context.locale.contactUs,
                icon: SvgAssets.riCustomerServiceFill,
                onTap: () {
                  context.push(const ContactUsView());
                },
              ),
              ProfileItemWidget(
                title: context.locale.privacyPolicy,
                icon: SvgAssets.iconamoonShieldYesFill,
                onTap: () {
                  final currentLocale = context.locale.localeName;
                  openLink(
                    '${AppConstants.privacyPolicyLink}$currentLocale/',
                  );
                },
              ),
              ProfileItemWidget(
                title: context.locale.termsConditions,
                icon: SvgAssets.epList,
                onTap: () {},
              ),
              ProfileItemWidget(
                title: context.locale.shareWithFrieds,
                icon: SvgAssets.solarShareBold,
                onTap: () {
                  shareText('''
                      **اكتشف تطبيق Smartble P – مساعدك الذكي في إدارة العملية التعليمية**  
                      
                      صُمم تطبيق **Smartble P** خصيصًا للمعلمين لمساعدتهم على إدارة مهامهم وتنظيم جداولهم بكل سهولة وفعالية. الآن يمكنك التركيز على التعليم بينما يقوم التطبيق بالباقي!  
                      
                      🌟 **روابط التحميل**:  
                      - 📱 **لأجهزة الآيفون (App Store)**: [Smartble P على App Store](https://apps.apple.com/us/app/smartble-p/id6478277343)  
                      - 🤖 **لأجهزة الأندرويد (Google Play)**: [Smartble P على Google Play](https://play.google.com/store/apps/details?id=com.smartable.tables&hl=ar&pli=1)  
                      
                      ابدأ باستخدام **Smartble P** اليوم، واجعل إدارة فصولك الدراسية أكثر سهولة وتنظيمًا! ✨  
                      ''');
                },
              ),
              ProfileItemWidget(
                title: context.locale.deleteAccount,
                icon: SvgAssets.icomoonFreeBin,
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
                },
              ),
              ProfileItemWidget(
                title: context.locale.logout,
                icon: SvgAssets.materialSymbolsLogoutSharp,
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
              const SizedBox(
                height: 30,
              ),
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
