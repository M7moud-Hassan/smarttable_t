import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';

import '../constants/app_colors.dart';

class PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String countryCode, String phone)? onChanged;

  const PhoneField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  PhoneNumber number = PhoneNumber(isoCode: "SA");

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber value) async {
          String code = value.dialCode ?? "+966";

          String parsed = value.parseNumber();
          widget.onChanged?.call(code, parsed);
        },
        searchBoxDecoration: const InputDecoration(
          hintText: '',
          prefixIcon: Icon(Icons.search, color: Colors.black),
          hintStyle: TextStyle(color: Colors.grey),
        ),
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DIALOG,
          leadingPadding: 8,
          useEmoji: false,
          showFlags: true,
        ),
        initialValue: number,
        textFieldController: widget.controller,
        inputDecoration: InputDecoration(
          fillColor: AppColors.grayColor,
          filled: true,
          contentPadding: const EdgeInsetsDirectional.only(
            top: 15,
            start: 10,
            bottom: 15,
          ),
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
          hintText: context.locale.phoneNumber,
        ),
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: false,
        ),
        formatInput: true,
        maxLength: 12,
      ),
    );
  }
}
