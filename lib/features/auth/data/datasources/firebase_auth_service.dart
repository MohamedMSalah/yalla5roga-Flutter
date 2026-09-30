import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/features/auth/domain/entities/phone_verification.dart';

/// Firebase Auth phone OTP adapter. Presentation must not import this type.
class FirebaseAuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth}) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  fb.User? get currentUser => _auth.currentUser;

  Future<PhoneVerification> sendOtp({
    required String phone,
    int? forceResendingToken,
  }) async {
    final e164 = Validators.normalizePhone(phone);
    if (!Validators.isValidEgyptianPhone(e164)) {
      throw const AuthException(
        'Enter a valid Egyptian phone number',
        PhoneAuthErrorCodes.invalidPhone,
      );
    }

    final completer = Completer<PhoneVerification>();

    if (kDebugMode) {
      debugPrint(
        '[FirebaseAuth] verifyPhoneNumber → $e164'
        '${forceResendingToken != null ? ' (resend)' : ''}',
      );
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: e164,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (credential) {
          if (!completer.isCompleted) {
            completer.complete(const PhoneVerification(verificationId: ''));
          }
          unawaited(_auth.signInWithCredential(credential));
        },
        verificationFailed: (error) {
          if (!completer.isCompleted) {
            completer.completeError(_mapFirebaseAuthException(error));
          }
        },
        codeSent: (verificationId, resendToken) {
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerification(
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!completer.isCompleted) {
            completer.complete(PhoneVerification(verificationId: verificationId));
          }
        },
        timeout: const Duration(seconds: 60),
      );
    } on fb.FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }

    try {
      return await completer.future.timeout(
        const Duration(seconds: 70),
        onTimeout: () => throw const AuthException(
          'Phone verification timed out',
          PhoneAuthErrorCodes.timedOut,
        ),
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      if (error is AuthException) rethrow;
      throw AuthException(
        error.toString(),
        PhoneAuthErrorCodes.verificationFailed,
      );
    }
  }

  Future<fb.UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (verificationId.isEmpty) {
      throw const AuthException(
        'Request a verification code first',
        PhoneAuthErrorCodes.missingVerification,
      );
    }
    if (smsCode.trim().length < 4) {
      throw const AuthException(
        'Enter a valid verification code',
        PhoneAuthErrorCodes.invalidVerificationCode,
      );
    }

    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      return await _auth.signInWithCredential(credential);
    } on fb.FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  Future<String?> idToken({bool forceRefresh = false}) async {
    try {
      return await _auth.currentUser?.getIdToken(forceRefresh);
    } on fb.FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  Future<void> signOut() => _auth.signOut();

  static AuthException _mapFirebaseAuthException(fb.FirebaseAuthException error) {
    final code = error.code;
    switch (code) {
      case 'invalid-phone-number':
        return const AuthException(
          'Enter a valid Egyptian phone number',
          PhoneAuthErrorCodes.invalidPhone,
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Try again later',
          PhoneAuthErrorCodes.tooManyRequests,
        );
      case 'quota-exceeded':
        return const AuthException(
          'SMS quota exceeded. Try again later',
          PhoneAuthErrorCodes.quotaExceeded,
        );
      case 'session-expired':
        return const AuthException(
          'Session expired. Request a new code',
          PhoneAuthErrorCodes.sessionExpired,
        );
      case 'invalid-verification-code':
        return const AuthException(
          'Invalid verification code',
          PhoneAuthErrorCodes.invalidVerificationCode,
        );
      case 'invalid-verification-id':
        return const AuthException(
          'Verification expired. Request a new code',
          PhoneAuthErrorCodes.invalidVerificationId,
        );
      case 'network-request-failed':
        return const AuthException(
          'Network error. Check your connection',
          PhoneAuthErrorCodes.network,
        );
      case 'app-not-authorized':
        return const AuthException(
          'App is not authorized for phone auth',
          PhoneAuthErrorCodes.appNotAuthorized,
        );
      case 'captcha-check-failed':
        return const AuthException(
          'Captcha check failed. Try again',
          PhoneAuthErrorCodes.captchaFailed,
        );
      case 'invalid-app-credential':
        return const AuthException(
          'App credential invalid. Check Firebase config',
          PhoneAuthErrorCodes.invalidAppCredential,
        );
      default:
        if (kDebugMode) {
          debugPrint('[FirebaseAuth] ${error.code}: ${error.message}');
        }
        return AuthException(
          error.message ?? 'Phone verification failed',
          code.isNotEmpty ? code : PhoneAuthErrorCodes.verificationFailed,
        );
    }
  }
}
