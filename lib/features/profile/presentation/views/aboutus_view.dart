import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/layout_constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/widgets/custom_error_widget.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';

import '../../providers/about_us_provider.dart';

class AboutUsView extends ConsumerWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutsAsync = ref.watch(aboutUsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.aboutUs),
      ),
      body: Padding(
          padding: pgHorizontalPadding18,
          child: aboutsAsync.when(
            data: (abouts) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                abouts,
                style: context.textTheme.titleLarge!.copyWith(fontSize: 18),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: CustomErrorWidget(
                  onTap: () => ref.invalidate(aboutUsProvider)),
            ),
            loading: () => const Center(child: LoadingWidget()),
          )),
    );
  }
}
