import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:signature/signature.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/loading_widget.dart';
import 'package:smart_table_app/features/profile/providers/profile_provider.dart';

class TeacherSignatureView extends ConsumerStatefulWidget {
  const TeacherSignatureView({super.key});

  @override
  ConsumerState<TeacherSignatureView> createState() => _TeacherSignatureViewState();
}

class _TeacherSignatureViewState extends ConsumerState<TeacherSignatureView> {
  bool _isDrawingTab = true;
  File? _pickedFile;

  late final SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 4,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    File? fileToUpload;

    if (_isDrawingTab) {
      if (_signatureController.isEmpty) {
        context.showSnackbarError(context.locale.pleaseDrawOrPickSignature);
        return;
      }

      final bytes = await _signatureController.toPngBytes();
      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/signature.png');
        await file.writeAsBytes(bytes);
        fileToUpload = file;
      }
    } else {
      if (_pickedFile == null) {
        context.showSnackbarError(context.locale.pleaseDrawOrPickSignature);
        return;
      }
      fileToUpload = _pickedFile;
    }

    if (fileToUpload != null) {
      final success = await ref
          .read(teacherSignatureNotifierProvider.notifier)
          .saveSignature(fileToUpload);
      if (success && mounted) {
        context.showSnackbarSuccess(context.locale.signatureSavedSuccessfully);
        _signatureController.clear();
        setState(() {
          _pickedFile = null;
        });
      }
    }
  }

  Future<void> _deleteSignature() async {
    final success = await ref
        .read(teacherSignatureNotifierProvider.notifier)
        .deleteSignature();
    if (success && mounted) {
      context.showSnackbarSuccess(context.locale.signatureClearedSuccessfully);
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (!mounted) return;
      final platformFile = result?.files.firstOrNull;
      if (platformFile != null && platformFile.path != null) {
        setState(() {
          _pickedFile = File(platformFile.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackbarError(context.locale.errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signatureAsync = ref.watch(signatureProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(context.locale.teacherSignature),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.locale.signaturePreview,
                  style: context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.appbarTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                signatureAsync.when(
                  data: (url) {
                    if (url != null && url.isNotEmpty) {
                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                height: 120,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const LoadingWidget(),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _deleteSignature,
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                label: Text(
                                  context.locale.clearSignature,
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return DottedBorder(
                        color: AppColors.textGrayColor,
                        strokeWidth: 1.5,
                        dashPattern: const [6, 4],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.gesture_rounded,
                                size: 40,
                                color: AppColors.textGrayColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.locale.noSignatureSaved,
                                style: const TextStyle(
                                  color: AppColors.textGrayColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  loading: () => Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: const LoadingWidget(),
                  ),
                  error: (_, __) => Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: Text(context.locale.errorMessage),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isDrawingTab = true),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _isDrawingTab ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isDrawingTab
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              context.locale.signInApp,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: _isDrawingTab ? FontWeight.bold : FontWeight.normal,
                                color: _isDrawingTab ? AppColors.primaryColor : AppColors.textGrayColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isDrawingTab = false),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !_isDrawingTab ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !_isDrawingTab
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              context.locale.pickSignatureImage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: !_isDrawingTab ? FontWeight.bold : FontWeight.normal,
                                color: !_isDrawingTab ? AppColors.primaryColor : AppColors.textGrayColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isDrawingTab) ...[
                  Text(
                    context.locale.drawSignatureHere,
                    style: const TextStyle(fontSize: 14, color: AppColors.textGrayColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Signature(
                      controller: _signatureController,
                      height: 220,
                      backgroundColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _signatureController.clear(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(context.locale.clearSignature),
                    ),
                  ),
                ] else ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          if (_pickedFile != null) ...[
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_pickedFile!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryColor,
                              side: const BorderSide(color: AppColors.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(_pickedFile == null
                                ? context.locale.chooseFile
                                : context.locale.pickSignatureImage),
                          ),
                          if (_pickedFile != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _pickedFile!.path.split('/').last,
                              style: const TextStyle(fontSize: 12, color: AppColors.textGrayColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveSignature,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.locale.saveSignature,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

