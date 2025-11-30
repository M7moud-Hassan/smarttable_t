import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/widgets/app_button.dart';

class ConfirmDialogWidget extends StatelessWidget {
  const ConfirmDialogWidget(
      {super.key, required this.title, required this.onConfirm});
  final String title;
  final Function() onConfirm;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: AppColors.grayBordredColor,
                      shape: BoxShape.circle),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: context.textTheme.titleLarge!.copyWith(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: Text(
              context.locale.no,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppButton(
            onPressed: () {
              context.pop();
              onConfirm();
            },
            child: Text(context.locale.yes),
          ),
        ],
      ),
    );
  }
}
