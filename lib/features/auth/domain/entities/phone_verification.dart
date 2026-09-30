/// Result of phone OTP dispatch (SMS or test-number path).
class PhoneVerification {
  const PhoneVerification({
    required this.verificationId,
    this.resendToken,
  });

  final String verificationId;
  final int? resendToken;
}

/// Stable error codes surfaced to [AuthProvider] / UI (match Firebase where possible).
abstract final class PhoneAuthErrorCodes {
  static const invalidPhone = 'invalid-phone-number';
  static const tooManyRequests = 'too-many-requests';
  static const quotaExceeded = 'quota-exceeded';
  static const sessionExpired = 'session-expired';
  static const invalidVerificationCode = 'invalid-verification-code';
  static const invalidVerificationId = 'invalid-verification-id';
  static const network = 'network-request-failed';
  static const verificationFailed = 'verification-failed';
  static const timedOut = 'verification-timeout';
  static const missingVerification = 'missing-verification';
  static const appNotAuthorized = 'app-not-authorized';
  static const captchaFailed = 'captcha-check-failed';
  static const missingClientId = 'missing-client-identifier';
  static const invalidAppCredential = 'invalid-app-credential';
}

/// Backward-compatible aliases used by the Firebase datasource.
typedef FirebasePhoneVerification = PhoneVerification;
typedef FirebasePhoneAuthCodes = PhoneAuthErrorCodes;
