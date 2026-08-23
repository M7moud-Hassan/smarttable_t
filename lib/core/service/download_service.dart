import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';

import '../providers/providers.dart';

class DownloadService {
  late FileDownloader _fileDownloader;

  DownloadService(BuildContext context) {
    _initFileDownloader(context);
  }

  void _initFileDownloader(BuildContext context) {
    final downloadingLabel = context.locale.downloading;
    final downloadSuccessLabel = context.locale.downloadSuccess;
    final downloadFailedLabel = context.locale.downloadFailed;
    Future.delayed(Duration.zero, () {
      _fileDownloader = FileDownloader().configureNotification(
        running: TaskNotification(
          '$downloadingLabel {filename}',
          'File: {filename} - {progress}',
        ),
        complete: TaskNotification(
          '$downloadingLabel {filename}',
          downloadSuccessLabel,
        ),
        error: TaskNotification(
          '$downloadingLabel {filename}',
          downloadFailedLabel,
        ),
        paused: TaskNotification(
          '$downloadingLabel {filename}',
          'Paused with metadata {metadata}',
        ),
        progressBar: true,
        tapOpensFile: true,
      );
    });
  }

  Future<void> downloadAndOpen(String url, String fileName) async {
    try {
      final DownloadTask task = DownloadTask(
        url: url,
        filename: fileName.replaceAll('.pdf', ''),
      );

      await _fileDownloader.download(task);

      final newFilepath = await _fileDownloader.moveToSharedStorage(
        task,
        SharedStorage.downloads,
      );

      if (newFilepath != null) {
        await _fileDownloader.openFile(filePath: newFilepath);
      }
    } catch (e) {
      // Handle errors here
      debugPrint('Download failed: $e');
      throw Exception('Download failed');
    }
  }

  Future<void> saveFileOnDevice(
    String fileName,
    File inFile, {
    Rect? sharePositionOrigin,
  }) async {
    try {
      final safeFileName = fileName
          .replaceAll('/', '_')
          .replaceAll('\\', '_')
          .replaceAll('\u0000', '');
      if (Platform.isAndroid) {
        // Check if the platform is Android
        final directory = await getExternalStorageDirectory();

        if (directory == null) {
          // Handle the case where external storage directory is not available
          return;
        }

        final path = '${directory.path}/Download/$safeFileName';
        final bytes = await inFile.readAsBytes();
        final outFile = File(path);

        if (!outFile.existsSync()) {
          // Create the directory if it doesn't exist
          await outFile.parent.create(recursive: true);
        }

        await outFile.writeAsBytes(bytes, flush: true);
        // await openFile(path);
      } else {
        // iOS/macOS share extensions require a real file at the supplied path.
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$safeFileName';
        final bytes = await inFile.readAsBytes();
        final outFile = File(path);
        await outFile.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles(
          [XFile(outFile.path)],
          sharePositionOrigin:
              sharePositionOrigin ?? const Rect.fromLTWH(1, 1, 1, 1),
        );
      }
    } catch (e) {
      debugPrint('Saving downloaded file failed: $e');
      throw Exception(e);
    }
  }

  // Future<void> openFile(String path) async {
  //   await _fileDownloader.openFile(filePath: path);
  // }

  void destroy() {
    _fileDownloader.destroy();
  }
}

final downloadServiceProvider = Provider.autoDispose<DownloadService>((ref) {
  final context = ref.read(navigatorKeyProvider).navigatorKey.currentContext!;
  return DownloadService(context);
});
