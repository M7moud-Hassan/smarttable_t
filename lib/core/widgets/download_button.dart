import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';

import '../service/download_service.dart';

class DownloadButtonWidget extends ConsumerStatefulWidget {
  const DownloadButtonWidget({
    super.key,
    required this.link,
    this.fileName,
  });

  final String? link;
  final String? fileName;
  @override
  ConsumerState<DownloadButtonWidget> createState() =>
      _DownloadButtonWidgetState();
}

class _DownloadButtonWidgetState extends ConsumerState<DownloadButtonWidget> {
  String? fileName;
  String? url;
  bool downloadAndOpenInProgress = false;
  late DownloadService _downloadService;
  @override
  void initState() {
    super.initState();
    fileName = widget.fileName;
    url = widget.link;
    _downloadService = ref.read(downloadServiceProvider);
  }

  @override
  void dispose() {
    _downloadService.destroy();
    super.dispose();
  }

  Future<void> processDownloadAndOpen() async {
    try {
      if (!downloadAndOpenInProgress) {
        if (mounted) {
          setState(() {
            downloadAndOpenInProgress = true;
          });
        }

        await _downloadService.downloadAndOpen(
          widget.link!,
          widget.fileName ?? widget.link!.split('/').last,
        );

        if (mounted) {
          // Show success message or perform any other actions
          context.showSnackbarSuccess(context.locale.downloadSuccess);
        }
      }
    } catch (e) {
      if (mounted) {
        // Show error message or perform any other error handling
        context.showSnackbarError(context.locale.downloadFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          downloadAndOpenInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return downloadAndOpenInProgress
        ? const CircularProgressIndicator()
        : GestureDetector(
            onTap: () async {
              await processDownloadAndOpen();
            },
            child: Text(
              context.locale.downloading,
              style: context.textTheme.titleLarge!
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          );
  }
}
