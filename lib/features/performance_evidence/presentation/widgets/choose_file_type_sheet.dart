import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ChooseFileTypeSheet extends StatelessWidget {
  final Function(String) onTypeSelected;
  const ChooseFileTypeSheet({super.key, required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1D2951)),
                  ),
                  child: const Icon(Icons.close,
                      color: Color(0xFF1D2951), size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'اختيار مستند',
                      style: TextStyle(
                        color: Color(0xFF1D2951),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'يمكنك إرسال ملفات بحجم\nيصل إلي 2 جيجابايت',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _buildOption(
                  title: 'ملف ورد',
                  icon: Icons.article_outlined,
                  color: const Color(0xFF44C4C5),
                  onTap: () => onTypeSelected('w'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: Color(0xFF44C4C5)),
                ),
                _buildOption(
                  title: 'ملف Pdf',
                  icon: Icons.picture_as_pdf_outlined,
                  color: const Color(0xFF44C4C5),
                  onTap: () => onTypeSelected('p'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: Color(0xFF44C4C5)),
                ),
                _buildOption(
                  title: 'ملف أكسيل',
                  icon: Icons.grid_on_outlined,
                  color: const Color(0xFF44C4C5),
                  onTap: () => onTypeSelected('w'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1, color: Color(0xFF44C4C5)),
                ),
                _buildOption(
                  title: 'صورة',
                  icon: Icons.image_outlined,
                  color: const Color(0xFF44C4C5),
                  isLast: true,
                  onTap: () => onTypeSelected('i'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D2951)),
      ),
      trailing: Icon(icon, color: color, size: 30),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    );
  }
}
