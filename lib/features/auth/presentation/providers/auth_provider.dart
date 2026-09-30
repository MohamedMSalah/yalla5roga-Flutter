import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/error/app_error_feedback.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/monitoring/analytics_service.dart';
import 'package:yalla_5roga/core/monitoring/crashlytics_service.dart';
import 'package:yalla_5roga/core/monitoring/performance_service.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/features/auth/domain/entities/phone_verification.dart';
import 'package:yalla_5roga/features/auth/domain/entities/user.dart';
import 'package:yalla_5roga/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.repository});

  final AuthRepository repository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorCode;
  bool _isLogin = true;
  bool _otpSent = false;
  bool _agreeTerms = false;
  String? _verificationId;
  int? _resendToken;
  String? _pendingPhone;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
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

  void resetAuthForm({bool toLogin = true}) {
    if (toLogin) _isLogin = true;
    _otpSent = false;
    _verificationId = null;
    _resendToken = null;
    _pendingPhone = null;
    _agreeTerms = false;
    _errorMessage = null;
    _errorCode = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final hasFirebase = repository.hasFirebaseSession;
    final result = await repository.getCachedUser();
    result.fold(
      (_) {
        _user = null;
        if (hasFirebase) {
          unawaited(repository.signOutFirebase());
        }
      },
      (user) {
        if (!hasFirebase) {
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

    final e164 = Validators.normalizePhone(phone);
    if (!Validators.isValidEgyptianPhone(e164)) {
      _errorCode = PhoneAuthErrorCodes.invalidPhone;
      _errorMessage = 'Enter a valid Egyptian phone number';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
    unawaited(AnalyticsService.instance.loginStarted(isLogin: _isLogin));

    final samePhone = _pendingPhone == e164;
    final result = await repository.sendOtp(
      phone: e164,
      forceResendingToken: samePhone ? _resendToken : null,
    );

    return result.fold(
      (failure) {
        _isLoading = false;
        _errorCode = failure is AuthFailure
            ? (failure.code ?? PhoneAuthErrorCodes.verificationFailed)
            : PhoneAuthErrorCodes.verificationFailed;
        _errorMessage = failure.message;
        AppErrorFeedback.report(failure, kind: AppErrorKind.send, context: 'sendOtp');
        unawaited(AnalyticsService.instance.loginFailed(code: _errorCode));
        notifyListeners();
        return false;
      },
      (verification) {
        if (verification.verificationId.isEmpty) {
          _isLoading = false;
          _errorCode = PhoneAuthErrorCodes.verificationFailed;
          _errorMessage = 'Phone verification failed';
          AppErrorFeedback.report(
            const AuthFailure('Phone verification failed'),
            kind: AppErrorKind.send,
            context: 'sendOtp',
          );
          unawaited(AnalyticsService.instance.loginFailed(code: _errorCode));
          notifyListeners();
          return false;
        }
        _verificationId = verification.verificationId;
        _resendToken = verification.resendToken ?? (samePhone ? _resendToken : null);
        _pendingPhone = e164;
        _otpSent = true;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> resendOtp(String phone) => sendOtp(phone);

  Future<bool> verifyOtp({
    required String smsCode,
    String? name,
  }) async {
    final verificationId = _verificationId;
    final phone = _pendingPhone;
    if (verificationId == null || phone == null) {
      _errorCode = PhoneAuthErrorCodes.missingVerification;
      _errorMessage = 'Request a verification code first';
      notifyListeners();
      return false;
    }

    return PerformanceService.instance.trace(
      'login_verify_otp',
      () => _run(
        () => repository.verifyOtpAndCache(
          verificationId: verificationId,
          smsCode: smsCode,
          phone: phone,
          name: name,
        ),
      ),
    );
  }

  Future<void> updateProfile({String? phone, String? imageUrl, String? name}) async {
    if (_user == null) return;
    final updated = _user!.copyWith(phone: phone, imageUrl: imageUrl, name: name);
    final result = await repository.saveUser(updated);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(failure, kind: AppErrorKind.send, context: 'updateProfile');
      },
      (user) => _user = user,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    final result = await repository.logout();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(failure, kind: AppErrorKind.send, context: 'logout');
      },
      (_) {},
    );
    _user = null;
    await CrashlyticsService.instance.setUserId(null);
    await AnalyticsService.instance.setUserId(null);
    resetAuthForm();
  }

  Future<bool> _run(Future<Either<Failure, User>> Function() action) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    try {
      final result = await action();
      final success = result.fold(
        (failure) {
          _isLoading = false;
          _errorMessage = failure.message;
          _errorCode = failure is AuthFailure
              ? (failure.code ?? PhoneAuthErrorCodes.verificationFailed)
              : PhoneAuthErrorCodes.verificationFailed;
          AppErrorFeedback.report(failure, kind: AppErrorKind.send, context: 'verifyOtp');
          unawaited(AnalyticsService.instance.loginFailed(code: _errorCode));
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
      if (success && _user != null) {
        await CrashlyticsService.instance.setUserId(_user!.id);
        await AnalyticsService.instance.setUserId(_user!.id);
        unawaited(AnalyticsService.instance.loginSuccess());
      }
      return success;
    } catch (error, stack) {
      debugPrint('[AuthProvider] unexpected: $error');
      unawaited(
        CrashlyticsService.instance.recordError(
          error,
          stack,
          reason: 'auth_provider_verify',
        ),
      );
      _isLoading = false;
      _errorCode = PhoneAuthErrorCodes.verificationFailed;
      _errorMessage = 'Unexpected error';
      AppErrorFeedback.report(
        const AuthFailure('Unexpected error'),
        kind: AppErrorKind.send,
        context: 'verifyOtp',
      );
      unawaited(AnalyticsService.instance.loginFailed(code: _errorCode));
      notifyListeners();
      return false;
    }
  }
}
