import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/features/shell/presentation/pages/main_shell.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/custom_textfield.dart';
import 'package:yalla_5roga/core/widgets/otp_input.dart';
import 'package:yalla_5roga/core/widgets/phone_text_field.dart';
import 'package:yalla_5roga/features/auth/presentation/providers/auth_provider.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final auth = context.read<AuthProvider>();
    if (!auth.otpSent) return;
    if (Validators.isValidEgyptianPhone(_phoneController.text)) return;
    _otpController.clear();
    auth.resetOtp();
  }

  String _authError(AuthProvider auth) {
    final l10n = context.l10n;
    return l10n.phoneAuthError(
      auth.errorCode,
      fallback: auth.errorMessage ?? l10n.otpSendFailed,
    );
  }

  Future<void> _resendOtp() async {
    final auth = context.read<AuthProvider>();
    final phone = Validators.normalizePhone(_phoneController.text);
    final ok = await auth.resendOtp(phone);
    if (!mounted) return;
    if (!ok) {
      AppSnackBar.show(_authError(auth));
      return;
    }
    AppSnackBar.show(context.l10n.otpSent(phone));
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLogin && !auth.agreeTerms) {
      AppSnackBar.show(context.l10n.termsRequired);
      return;
    }
    final phone = Validators.normalizePhone(_phoneController.text);
    _otpController.clear();
    final ok = await auth.sendOtp(phone);
    if (!mounted) return;
    if (!ok) {
      AppSnackBar.show(_authError(auth));
      return;
    }
    AppSnackBar.show(context.l10n.otpSent(phone));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final auth = context.read<AuthProvider>();
    if (!auth.isLogin && !auth.agreeTerms) {
      AppSnackBar.show(l10n.termsRequired);
      return;
    }

    final otp = _otpController.text.trim();
    final ok = await auth.verifyOtp(
      smsCode: otp,
      name: auth.isLogin ? null : _nameController.text.trim(),
    );

    if (!mounted) return;
    if (!ok) {
      AppSnackBar.show(
        l10n.phoneAuthError(
          auth.errorCode,
          fallback: auth.errorMessage ?? (auth.isLogin ? l10n.loginFailed : l10n.registerFailed),
        ),
      );
      return;
    }
    Get.offAll(() => const MainShell());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthProvider>();
    final isLogin = auth.isLogin;
    final otpSent = auth.otpSent;

    if (!otpSent && _otpController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _otpController.clear();
      });
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLogin) ...[
            CustomTextField(
              controller: _nameController,
              label: l10n.name,
              hint: l10n.nameHint,
              prefixIcon: Icons.person_outline,
              validator: (value) => Validators.required(value, l10n),
            ),
            Responsive.spaceMd.gapH,
          ],
          PhoneTextField(controller: _phoneController),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: otpSent
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Responsive.spaceMd.gapH,
                      OtpInput(
                        controller: _otpController,
                        label: l10n.otp,
                        length: Validators.otpLength,
                        validator: (value) => Validators.otp(value, l10n),
                        action: TextButton(
                          onPressed: auth.isLoading ? null : _resendOtp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.resendOtp,
                            style: TextStyle(
                              color: AppColors.brand600,
                              fontSize: Responsive.fontSm,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
          if (!isLogin) ...[
            Responsive.spaceSm.gapH,
            Row(
              children: [
                Checkbox(
                  value: auth.agreeTerms,
                  activeColor: AppColors.brand600,
                  onChanged: (value) => auth.setAgreeTerms(value ?? false),
                ),
                Expanded(
                  child: Text(
                    l10n.agreeTerms,
                    style: TextStyle(color: context.palette.textMuted, fontSize: Responsive.fontSm),
                  ),
                ),
              ],
            ),
          ],
          Responsive.spaceMd.gapH,
          CustomButton(
            label: otpSent ? (isLogin ? l10n.login : l10n.register) : l10n.sendOtp,
            icon: otpSent ? Icons.arrow_forward : Icons.sms_outlined,
            isLoading: auth.isLoading,
            onPressed: otpSent ? _submit : _sendOtp,
          ),
        ],
      ),
    );
  }
}
