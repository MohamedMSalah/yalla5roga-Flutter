import 'package:yalla_5roga/core/constants/app_constants.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';

class Validators {
  const Validators._();

  static String? required(String? value, L10n l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.requiredField;
    }
    return null;
  }

  static String? phone(String? value, L10n l10n) {
    final requiredError = required(value, l10n);
    if (requiredError != null) return requiredError;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    var local = digits.startsWith('20') ? digits.substring(2) : digits;
    if (local.startsWith('0')) local = local.substring(1);
    if (!RegExp(r'^1[0125]\d{8}$').hasMatch(local)) {
      return l10n.invalidPhone;
    }
    return null;
  }

  static String normalizePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    var local = digits.startsWith('20') ? digits.substring(2) : digits;
    if (local.startsWith('0')) local = local.substring(1);
    return '+20$local';
  }

  static bool isValidEgyptianPhone(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    var local = digits.startsWith('20') ? digits.substring(2) : digits;
    if (local.startsWith('0')) local = local.substring(1);
    return RegExp(r'^1[0125]\d{8}$').hasMatch(local);
  }

  static String? password(String? value, L10n l10n) {
    final requiredError = required(value, l10n);
    if (requiredError != null) return requiredError;
    if (value!.length < AppConstants.minPasswordLength) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  static const otpLength = 6;

  static String? otp(String? value, L10n l10n) {
    final requiredError = required(value, l10n);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^\d{6}$').hasMatch(value!.trim())) {
      return l10n.invalidOtp;
    }
    return null;
  }
}
