import 'package:flutter/material.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';

import 'app_button.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({
    super.key,
    required this.onTap,
    this.error,
  });
  final void Function()? onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error != null ? error! : context.locale.errorMessage,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 180,
            height: 45,
            child: AppButton(
              onPressed: onTap!,
              child: Text(
                context.locale.tryAgain,
                style: context.textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
