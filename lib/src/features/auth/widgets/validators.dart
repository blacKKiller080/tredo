import 'package:flutter/material.dart';
import 'package:tredo/src/core/extension/extensions.dart';

String? emailValidator(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    //return context.localized.requiredField;
    return 'Required email';
  }
  if (!value.emailValidator()) {
    // return context.localized.incorrectEmailFormat;
    return 'Incorrect email fromat';
  }
  return null;
}

String? nameValidator(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    // return context.localized.requiredField;
    return 'Required name';
  }
  return null;
}

String? numberValidator(BuildContext context, String? value, int? length) {
  if (value == null || value.isEmpty) {
    // return context.localized.requiredField;
    return 'Required number';
  }
  if (value.length < 6) {
    // return context.localized.theMinimumPasswordLengthIs6;
    return 'The minimum password lingth is 6';
  }
  return null;
}

String? passwordValidator(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    // return context.localized.requiredField;
    return 'Required password';
  }
  if (value.length < 6) {
    // return context.localized.theMinimumPasswordLengthIs6;
    return 'The minimum password lingth is 6';
  }
  return null;
}

String? iinValidator(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    // return context.localized.requiredField;
    return 'Required iin';
  }
  if (value.length == 12) {
    // return context.localized.theMinimumPasswordLengthIs6;
    return 'Incorrect value';
  }
  return null;
}

bool isPasswordValid(String password) {
  final bool hasDigits = RegExp('[0-9]').hasMatch(password);
  final bool hasLowerCase = RegExp('[a-z]').hasMatch(password);
  final bool hasUpperCase = RegExp('[A-Z]').hasMatch(password);
  final bool hasSymbols =
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_]').hasMatch(password);
  final bool isLengthValid = password.length >= 8;
  return hasDigits &&
      hasLowerCase &&
      hasUpperCase &&
      isLengthValid &&
      hasSymbols;
}
