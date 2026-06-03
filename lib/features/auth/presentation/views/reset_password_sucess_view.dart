import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:svg_flutter/svg.dart';

class ResetPasswordSucessView extends ConsumerWidget {
  const ResetPasswordSucessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: pgHorizontalPadding18,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              SvgAssets.icon,
              width: 150,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                context.locale.sentSuccessfully,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge!
                    .copyWith(color: AppColors.secondryColor),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  context.popToFirst();
                },
                child: Text(context.locale.login))
          ],
        ),
      ),
    );
  }
}
