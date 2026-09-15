import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';
import 'package:smart_table_app/features/performance_evidence/data/models/performance_evidence_model.dart';
import 'package:smart_table_app/features/performance_evidence/presentation/widgets/choose_file_type_sheet.dart';
import 'package:smart_table_app/features/performance_evidence/presentation/views/upload_success_view.dart';
import 'package:smart_table_app/features/performance_evidence/providers/performance_evidence_provider.dart';

class AddPerformanceEvidenceView extends ConsumerStatefulWidget {
  const AddPerformanceEvidenceView({super.key});

  @override
  ConsumerState<AddPerformanceEvidenceView> createState() =>
      _AddPerformanceEvidenceViewState();
}

class _AddPerformanceEvidenceViewState
    extends ConsumerState<AddPerformanceEvidenceView> {
  int? selectedMainCategoryId;
  int? selectedSubcategoryId;
  File? selectedFile;
  String? typeFile;
  bool isUploading = false;

  Future<void> _pickFile(String type) async {
    FilePickerResult? result;
    if (type == 'i') {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
    } else if (type == 'p') {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    } else {
      result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['doc', 'docx', 'xls', 'xlsx']);
    }

    if (result != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();
      const maxFileSize = (1024 * 1024) * 5; // 1MB

      if (fileSize > maxFileSize) {
        if (mounted) {
          context.showSnackbarError(
              'حجم الملف كبير جداً، الحد الأقصى هو 5 ميجابايت');
        }
        return;
      }

      setState(() {
        selectedFile = file;
        typeFile = type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(evidenceCategoriesProvider);
    final categories =
        categoriesAsync.valueOrNull ?? const <EvidenceCategoryModel>[];
    final selectedCategoryId = _resolvedCategoryId(categories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة ملف جديد',
            style: TextStyle(
                color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            categoriesAsync.when(
              data: _buildCategoryDropdowns,
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
            const SizedBox(height: 25),
            _buildUploadArea(),
            if (selectedFile != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.file_present, color: AppColors.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedFile!.path.split('/').last,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        selectedFile = null;
                        typeFile = null;
                      });
                    },
                  ),
                ],
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            onPressed: (selectedCategoryId == null ||
                    selectedFile == null ||
                    isUploading)
                ? null
                : () async {
                    setState(() => isUploading = true);
                    final success = await ref
                        .read(performanceEvidenceProvider.notifier)
                        .addEvidence(
                          categoryId: selectedCategoryId,
                          typeFile: typeFile!,
                          file: selectedFile!,
                        );
                    if (!mounted) return;
                    setState(() => isUploading = false);
                    if (success) {
                      this.context.pushReplacement(const UploadSuccessView());
                    } else {
                      this.context.showSnackbarError('فشل رفع الملف');
                    }
                  },
            child: isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'تأكيد',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  EvidenceCategoryModel? _selectedMainCategory(
    List<EvidenceCategoryModel> categories,
  ) {
    for (final category in categories) {
      if (category.id == selectedMainCategoryId) return category;
    }
    return null;
  }

  int? _resolvedCategoryId(List<EvidenceCategoryModel> categories) {
    final mainCategory = _selectedMainCategory(categories);
    if (mainCategory == null) return null;
    if (mainCategory.subcategories.isEmpty) return mainCategory.id;

    final isValidSubcategory = mainCategory.subcategories.any(
      (subcategory) => subcategory.id == selectedSubcategoryId,
    );
    return isValidSubcategory ? selectedSubcategoryId : null;
  }

  Widget _buildCategoryDropdowns(List<EvidenceCategoryModel> categories) {
    final mainCategories = categories
        .where((category) => category.isMain || category.parentId == null)
        .toList();
    final selectedMainCategory = _selectedMainCategory(mainCategories);
    final subcategories =
        selectedMainCategory?.subcategories ?? const <EvidenceCategoryModel>[];

    return Column(
      children: [
        _buildDropdown(
          value: selectedMainCategoryId,
          hint: 'اختر الفئة الرئيسية',
          categories: mainCategories,
          onChanged: (value) {
            setState(() {
              selectedMainCategoryId = value;
              selectedSubcategoryId = null;
            });
          },
        ),
        if (selectedMainCategory != null && subcategories.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDropdown(
            value: selectedSubcategoryId,
            hint: 'اختر الفئة الفرعية',
            categories: subcategories,
            onChanged: (value) {
              setState(() {
                selectedSubcategoryId = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required int? value,
    required String hint,
    required List<EvidenceCategoryModel> categories,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.primaryColor.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Align(
            alignment: Alignment.centerRight,
            child: Text(hint, style: const TextStyle(color: Colors.grey)),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.primaryColor),
          items: categories.where((category) => category.id != null).map((cat) {
            return DropdownMenuItem<int>(
              value: cat.id!,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(cat.name),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ChooseFileTypeSheet(
            onTypeSelected: (type) {
              Navigator.pop(context);
              _pickFile(type);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload, size: 50, color: Color(0xFF333333)),
            SizedBox(height: 10),
            Text(
              'تحميل الملف',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
