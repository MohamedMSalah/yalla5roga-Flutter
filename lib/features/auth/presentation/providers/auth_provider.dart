import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/error/exceptions.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/auth/data/datasources/firebase_auth_service.dart';
import 'package:yalla_5roga/features/auth/domain/entities/user.dart';
import 'package:yalla_5roga/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this.repository,
    required this.firebaseAuth,
  });

  final AuthRepository repository;
  final FirebaseAuthService firebaseAuth;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLogin = true;
  bool _otpSent = false;
  bool _agreeTerms = false;
  String? _verificationId;
  int? _resendToken;
  String? _pendingPhone;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isLogin => _isLogin;
  bool get otpSent => _otpSent;
  bool get agreeTerms => _agreeTerms;

  void setLogin(bool value) {
    if (_isLogin == value && !_otpSent) return;
    _isLogin = value;
    resetOtp();
  }

  void setAgreeTerms(bool value) {
    if (_agreeTerms == value) return;
    _agreeTerms = value;
    notifyListeners();
  }

  void resetOtp() {
    _otpSent = false;
    _verificationId = null;
    _pendingPhone = null;
    _resendToken = null;
    notifyListeners();
  }

  /// Full auth UI reset (phone/OTP flow). Call on logout and when opening AuthPage.
  void resetAuthForm({bool toLogin = true}) {
    if (toLogin) _isLogin = true;
    _otpSent = false;
    _verificationId = null;
    _resendToken = null;
    _pendingPhone = null;
    _agreeTerms = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final firebaseUser = firebaseAuth.currentUser;
    final result = await repository.getCachedUser();
    result.fold(
      (_) {
        _user = null;
        if (firebaseUser != null) {
          unawaited(firebaseAuth.signOut());
        }
      },
      (user) {
        if (firebaseUser == null) {
          _user = null;
          unawaited(repository.logout().then((_) {}));
          return;
        }
        _user = user;
      },
    );
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await firebaseAuth.sendOtp(
        phone: phone,
        forceResendingToken: _pendingPhone == phone ? _resendToken : null,
      );
      _verificationId = result.verificationId;
      _resendToken = result.resendToken;
      _pendingPhone = phone;
      _otpSent = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _isLoading = false;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Unexpected error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp(String phone) => sendOtp(phone);

  Future<bool> verifyOtp({
    required String smsCode,
    String? name,
  }) async {
    final verificationId = _verificationId;
    final phone = _pendingPhone;
    if (verificationId == null || phone == null) {
      _errorMessage = 'Request a verification code first';
      notifyListeners();
      return false;
    }

    return _run(() async {
      final credential = await firebaseAuth.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure('Verification failed'));
      }

      final token = await firebaseAuth.idToken() ?? '';
      final resolvedName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : (firebaseUser.displayName?.trim().isNotEmpty == true
              ? firebaseUser.displayName!.trim()
              : phone);

      if (name != null && name.trim().isNotEmpty) {
        await firebaseUser.updateDisplayName(name.trim());
      }

      final user = User(
        id: firebaseUser.uid,
        name: resolvedName,
        phone: firebaseUser.phoneNumber ?? phone,
        email: firebaseUser.email,
        token: token,
        imageUrl: firebaseUser.photoURL,
      );
      return repository.saveUser(user);
    });
  }

  Future<void> updateProfile({String? phone, String? imageUrl, String? name}) async {
    if (_user == null) return;
    final updated = _user!.copyWith(phone: phone, imageUrl: imageUrl, name: name);
    final result = await repository.saveUser(updated);
    result.fold((failure) => _errorMessage = failure.message, (user) => _user = user);
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (_) {}
    final result = await repository.logout();
    result.fold((failure) => _errorMessage = failure.message, (_) {});
    _user = null;
    resetAuthForm();
  }

  Future<bool> _run(Future<Either<Failure, User>> Function() action) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await action();
      final ok = result.fold(
        (failure) {
          _isLoading = false;
          _errorMessage = failure.message;
          notifyListeners();
          return false;
        },
        (user) {
          _user = user;
          _otpSent = false;
          _verificationId = null;
          _resendToken = null;
          _pendingPhone = null;
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
      return ok;
    } on AuthException catch (error) {
      _isLoading = false;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Unexpected error';
      notifyListeners();
      return false;
    }
  }
}
