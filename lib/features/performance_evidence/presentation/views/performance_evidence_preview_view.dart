import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/views/pdf_viewer_view.dart';
import 'package:smart_table_app/features/performance_evidence/data/models/performance_evidence_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PerformanceEvidencePreviewView extends StatelessWidget {
  const PerformanceEvidencePreviewView({
    super.key,
    required this.evidence,
  });

  final PerformanceEvidenceModel evidence;

  @override
  Widget build(BuildContext context) {
    final url = evidence.file?.trim() ?? '';

    if (evidence.fileKind == PerformanceEvidenceFileKind.pdf &&
        url.isNotEmpty) {
      return PdfViwerView(
        title: evidence.title ?? 'معاينة الملف',
        url: url,
      );
    }

    return Scaffold(
      backgroundColor: url.isNotEmpty &&
              evidence.fileKind == PerformanceEvidenceFileKind.image
          ? Colors.black
          : null,
      appBar: AppBar(
        title: Text(
          evidence.title ?? 'معاينة الملف',
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: url.isEmpty
          ? const _PreviewMessage(
              icon: Icons.link_off_rounded,
              message: 'لا يوجد ملف للمعاينة',
            )
          : switch (evidence.fileKind) {
              PerformanceEvidenceFileKind.image => _ImagePreview(url: url),
              PerformanceEvidenceFileKind.document =>
                _DocumentPreview(url: url),
              PerformanceEvidenceFileKind.pdf => const SizedBox.shrink(),
            },
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 5,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (_, __) => const CircularProgressIndicator(
            color: Colors.white,
          ),
          errorWidget: (_, __, ___) => const _PreviewMessage(
            icon: Icons.broken_image_outlined,
            message: 'تعذر عرض الصورة',
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.url});

  final String url;

  Future<void> _openDocument(BuildContext context) async {
    var opened = false;
    try {
      final uri = Uri.tryParse(url);
      opened = uri != null &&
          await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!opened && context.mounted) {
      context.showSnackbarError('تعذر فتح الملف');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PreviewMessage(
      icon: Icons.description_outlined,
      message: 'تتم معاينة ملفات Word وExcel في تطبيق خارجي',
      action: ElevatedButton.icon(
        onPressed: () => _openDocument(context),
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('فتح الملف'),
      ),
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({
    required this.icon,
    required this.message,
    this.action,
    this.foregroundColor = AppColors.primaryColor,
  });

  final IconData icon;
  final String message;
  final Widget? action;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: foregroundColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
