import '../constants/app_strings.dart';

/// Common form field validators used across the app.
class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  static String? latitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < -90 || parsed > 90) {
      return AppStrings.invalidLatitude;
    }
    return null;
  }

  static String? longitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < -180 || parsed > 180) {
      return AppStrings.invalidLongitude;
    }
    return null;
  }
}

