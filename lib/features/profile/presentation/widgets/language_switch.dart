import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/helpers.dart';
import 'package:smart_table_app/features/profile/providers/locale_notifiers.dart';

class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = context.locale.localeName;
    final isArabic = currentLang.contains('ar');
    return Column(
      children: [
        const Divider(
          height: 0,
          color: Color(0XFFCBD4D9),
        ),
        ListTile(
          onTap: () {
            showModalBottomSheet(
                context: context,
                showDragHandle: true,
                backgroundColor: Colors.white,
                builder: (context) {
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    ListTile(
                      title: const Text('English'),
                      onTap: () {
                        ref
                            .read(currentLocaleProvider.notifier)
                            .changeLocale(const Locale('en'), sync: true);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('العربية (ذكور)'),
                      onTap: () {
                        ref.read(currentLocaleProvider.notifier).changeLocale(
                            const Locale('ar'),
                            female: false,
                            sync: true);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('العربية (إناث)'),
                      onTap: () {
                        ref.read(currentLocaleProvider.notifier).changeLocale(
                            const Locale('ar'),
                            female: true,
                            sync: true);
                        context.pop();
                      },
                    )
                  ]);
                });
          },
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(isArabic ? 'change language' : 'تغيير اللغة'),
              const SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(countryCodeToEmoji(
                  isArabic ? 'US' : 'SA',
                )),
              )
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
          ),
        ),
        const Divider(
          height: 0,
          color: Color(0XFFCBD4D9),
        ),
      ],
    );
  }
}
