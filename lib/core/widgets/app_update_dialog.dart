import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/constants.dart';
import '../extensions/extensions.dart';
import '../models/app_update_info.dart';
import 'app_button.dart';

Future<void> showAppUpdateDialog(
  BuildContext context,
  AppUpdateInfo update,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !update.isRequired,
    builder: (dialogContext) => PopScope(
      canPop: !update.isRequired,
      child: AlertDialog(
        backgroundColor: dialogContext.theme.scaffoldBackgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.system_update_alt_rounded,
                color: AppColors.primaryColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              dialogContext.locale.updateAvailableTitle,
              style: dialogContext.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              update.message ?? dialogContext.locale.updateAvailableMessage,
              style: dialogContext.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!update.isRequired) ...[
              OutlinedButton(
                onPressed: () => dialogContext.pop(),
                child: Text(dialogContext.locale.later),
              ),
              const SizedBox(height: 10),
            ],
            AppButton(
              onPressed: () => _openStore(dialogContext, update),
              child: Text(dialogContext.locale.updateNow),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _openStore(
  BuildContext context,
  AppUpdateInfo update,
) async {
  final uri = Uri.tryParse(update.storeUrl ?? '');
  final opened =
      uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!context.mounted) return;
  if (!opened) {
    context.showSnackbarError(context.locale.unableToOpenStore);
    return;
  }
  if (!update.isRequired) context.pop();
}
