import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:yalla_5roga/core/error/exceptions.dart';

class FirebasePhoneVerification {
  const FirebasePhoneVerification({
    required this.verificationId,
    this.resendToken,
  });

  final String verificationId;
  final int? resendToken;
}

class FirebaseAuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth}) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  fb.User? get currentUser => _auth.currentUser;

  Future<FirebasePhoneVerification> sendOtp({
    required String phone,
    int? forceResendingToken,
  }) async {
    final completer = Completer<FirebasePhoneVerification>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Auto-retrieval on Android — complete later via verifyOtp if needed.
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(
            AuthException(error.message ?? 'Phone verification failed'),
          );
        }
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            FirebasePhoneVerification(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(
            FirebasePhoneVerification(verificationId: verificationId),
          );
        }
      },
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw const AuthException('Timed out waiting for verification code');
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  Future<fb.UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on fb.FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Invalid verification code');
    }
  }

  Future<String?> idToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  Future<void> signOut() => _auth.signOut();
}
