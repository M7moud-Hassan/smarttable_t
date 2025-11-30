import 'package:flutter/widgets.dart' show BuildContext;
import 'package:smart_table_app/core/extensions/extensions.dart';

mixin ValidationMixin {
  String? emailValidation(String? val, BuildContext context) {
    if (val == null || val.isEmpty) {
      return context.locale.requiredFieldValidation;
    }
    const emailRegExpString = r'[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9]'
        r'[a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+';
    if (!RegExp(emailRegExpString, caseSensitive: false).hasMatch(val)) {
      return context.locale.emailValidation;
    }
    return null;
  }

  String? passwordValidation(String? val, BuildContext context) {
    if (val == null || val.isEmpty) {
      return context.locale.requiredFieldValidation;
    }
    if (val.length < 8) {
      return context.locale.passwordValidationMin;
    }
    return null;
  }

  String? passwordConfirmationValidation(
      String? val, String? password, BuildContext context) {
    if (val == null || val.isEmpty) {
      return context.locale.requiredFieldValidation;
    }
    if (val.length < 8) {
      return context.locale.passwordValidationMin;
    }
    if (val != password) {
      return context.locale.passwordConfirmationValidation;
    }
    return null;
  }

  String? emptyValidation(String? val, BuildContext context) {
    if (val == null || val.isEmpty) {
      return context.locale.requiredFieldValidation;
    }
    return null;
  }

  String? classTimeValidation(String? val, BuildContext context) {
    if (val == null || val.isEmpty) {
      return context.locale.requiredFieldValidation;
    }
    final intValue = int.tryParse(val);
    if (intValue == null) {
      return context.locale.invalidNumberValidation;
    }
    if (intValue < 0 || intValue > 720) {
      return context.locale.notificationTimeRangeValidation;
    }
    return null;
  }

  String? phoneValidation(String? val, BuildContext context) {
    if (val == null || val.isEmpty) {
      return context.locale.requiredFieldValidation;
    }
    // Check that it starts with + and then has digits only
    final phoneRegExp = RegExp(r'^\+\d+$');
    if (!phoneRegExp.hasMatch(val)) {
      return context.locale.phoneValidation; // Add this key in your locale
    }
    return null;
  }
}
