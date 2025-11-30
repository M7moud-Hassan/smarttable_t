import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_table_app/core/constants/app_colors.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:svg_flutter/svg.dart';

class AppTextField extends StatefulWidget {
  const AppTextField(
      {super.key,
      required this.hintText,
      this.label,
      required this.controller,
      this.validator,
      this.obscureText = false,
      this.readOnly = false,
      this.optional = false,
      this.maxLines = 1,
      this.suffix,
      this.suffixIcon,
      this.icon,
      this.onTap,
      this.shadowEnabled = true,
      this.textInputType,
      this.textInputFormatters = const [],
      this.onChanged});
  final String hintText;
  final String? label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final String? icon;
  final bool readOnly;
  final bool optional;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextInputType? textInputType;
  final VoidCallback? onTap;
  final bool shadowEnabled;
  final List<TextInputFormatter> textInputFormatters;
  final void Function(String)? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool isObsucerdEnabled;
  @override
  void initState() {
    isObsucerdEnabled = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                // if (widget.optional)
                //   Text(
                //     context.locale.optional,
                //     style: const TextStyle(
                //         fontWeight: FontWeight.w500,
                //         fontSize: 12,
                //         color: Colors.grey),
                //   ),
              ],
            ),
          ),
        TextFormField(
          style: context.textTheme.bodyMedium!.copyWith(fontSize: 15),
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          validator: widget.validator,
          maxLines: widget.maxLines,
          controller: widget.controller,
          obscureText: isObsucerdEnabled,
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            suffix: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: widget.suffix,
            ),
            fillColor: AppColors.grayColor,
            filled: true,
            hintText: widget.hintText,
            hintStyle:
                const TextStyle(fontSize: 15, color: AppColors.textGrayColor),
            contentPadding: const EdgeInsetsDirectional.only(
                top: 15, start: 10, bottom: 15),
            prefixIcon: widget.icon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15),
                    child: SvgPicture.asset(
                      widget.icon!,
                      color: AppColors.grayBordredColor,
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(maxWidth: 60),
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        isObsucerdEnabled = !isObsucerdEnabled;
                      });
                    },
                    child: Icon(
                      isObsucerdEnabled
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: context.theme.colorScheme.primary,
                    ),
                  )
                : widget.suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grayBordredColor),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.grayBordredColor),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: context.theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          inputFormatters: widget.textInputFormatters,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
