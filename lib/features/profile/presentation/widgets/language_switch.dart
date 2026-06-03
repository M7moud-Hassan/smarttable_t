import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/helpers.dart';
import 'package:smart_table_app/features/profile/providers/locale_notifiers.dart';

import 'package:smart_table_app/features/profile/presentation/widgets/profile_item_widget.dart';
import 'package:smart_table_app/core/constants/constants.dart';

class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileItemWidget(
      title: context.locale.language,
      icon: SvgAssets.materialSymbolsLanguage,
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
    );
  }
}
