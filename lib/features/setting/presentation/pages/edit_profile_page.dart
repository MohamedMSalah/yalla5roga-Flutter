import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/utils/input_formatters.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/custom_textfield.dart';
import 'package:yalla_5roga/core/widgets/image_source_sheet.dart';
import 'package:yalla_5roga/core/widgets/otp_input.dart';
import 'package:yalla_5roga/core/widgets/phone_text_field.dart';
import 'package:yalla_5roga/features/auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  String? _imagePath;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  late final String _initialEmail;
  late final String _initialPhone;
  late final String _initialName;
  late final String? _initialImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _initialName = user?.name ?? '';
    _initialEmail = user?.email?.trim() ?? '';
    _initialPhone = user?.phone ?? '';
    _initialImage = user?.imageUrl;
    _nameController.text = _initialName;
    _emailController.text = _initialEmail;
    _phoneController.text = _displayPhone(_initialPhone);
    _imagePath = _initialImage;
    _phoneController.addListener(_onPhoneChanged);
  }

  String _displayPhone(String phone) {
    final digits = Validators.normalizePhone(phone);
    if (digits.startsWith('+20') && digits.length > 3) {
      return digits.substring(3);
    }
    return phone.replaceFirst(RegExp(r'^\+?20'), '');
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final auth = context.read<AuthProvider>();
    if (!auth.otpSent) return;
    final pending = auth.pendingPhone;
    final current = Validators.normalizePhone(_phoneController.text);
    if (pending != null && pending == current) return;
    _otpController.clear();
    auth.resetOtp();
  }

  Future<void> _pickImage() async {
    final path = await ImageSourceSheet.pick(
      title: context.l10n.changeProfileImage,
    );
    if (path == null || !mounted) return;
    setState(() => _imagePath = path);
  }

  String _authError(AuthProvider auth) {
    return context.l10n.authError(
      auth.errorCode,
      fallback: auth.errorMessage ?? context.l10n.unexpectedError,
    );
  }

  bool get _phoneChanged {
    if (_phoneController.text.trim().isEmpty && _initialPhone.isEmpty) {
      return false;
    }
    if (_phoneController.text.trim().isEmpty) return false;
    return Validators.normalizePhone(_phoneController.text) !=
        Validators.normalizePhone(_initialPhone);
  }

  bool get _emailChanged =>
      _emailController.text.trim().toLowerCase() != _initialEmail.toLowerCase();

  bool get _nameChanged => _nameController.text.trim() != _initialName.trim();

  bool get _imageChanged => (_imagePath ?? '') != (_initialImage ?? '');

  bool get _wantsPasswordChange =>
      _newPasswordController.text.isNotEmpty ||
      _confirmPasswordController.text.isNotEmpty;

  Future<void> _sendPhoneOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final phone = Validators.normalizePhone(_phoneController.text);
    _otpController.clear();
    final ok = await auth.sendOtp(phone);
    if (!mounted) return;
    if (!ok) {
      AppSnackBar.show(_authError(auth));
      return;
    }
    AppSnackBar.show(context.l10n.otpSent(context.l10n.digits(phone)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final auth = context.read<AuthProvider>();
    final hasPassword = auth.hasPasswordProvider;

    if (_phoneChanged && !auth.otpSent) {
      AppSnackBar.show(l10n.verifyPhoneFirst);
      return;
    }

    if ((_emailChanged || _wantsPasswordChange) && hasPassword) {
      if (_currentPasswordController.text.isEmpty) {
        AppSnackBar.show(l10n.requiredField);
        return;
      }
    }

    if (_wantsPasswordChange && hasPassword) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        AppSnackBar.show(l10n.passwordsDoNotMatch);
        return;
      }
    }

    var changedSomething = false;

    if (_nameChanged || _imageChanged) {
      final ok = await auth.updateProfile(
        name: _nameController.text.trim(),
        imageUrl: _imagePath,
      );
      if (!mounted) return;
      if (!ok) {
        AppSnackBar.show(_authError(auth));
        return;
      }
      changedSomething = true;
    }

    if (_emailChanged && hasPassword) {
      final ok = await auth.requestEmailChange(
        newEmail: _emailController.text.trim(),
        currentPassword: _currentPasswordController.text,
      );
      if (!mounted) return;
      if (!ok) {
        AppSnackBar.show(_authError(auth));
        return;
      }
      AppSnackBar.show(l10n.emailChangeSent);
      changedSomething = true;
    }

    if (_wantsPasswordChange && hasPassword) {
      final ok = await auth.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      if (!ok) {
        AppSnackBar.show(_authError(auth));
        return;
      }
      AppSnackBar.show(l10n.passwordUpdated);
      changedSomething = true;
    }

    if (_phoneChanged && auth.otpSent) {
      final ok = await auth.changePhoneNumber(
        phone: _phoneController.text,
        smsCode: Validators.normalizeOtp(_otpController.text),
      );
      if (!mounted) return;
      if (!ok) {
        AppSnackBar.show(_authError(auth));
        return;
      }
      AppSnackBar.show(l10n.phoneUpdated);
      changedSomething = true;
    }

    if (!mounted) return;
    if (!changedSomething) {
      Get.back();
      return;
    }
    if (!_emailChanged && !_wantsPasswordChange && !_phoneChanged) {
      AppSnackBar.show(l10n.profileUpdated);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthProvider>();
    final hasPassword = auth.hasPasswordProvider;
    final avatar = 96.w;
    final otpSent = auth.otpSent;

    return Scaffold(
      appBar: AppPageBar(title: l10n.editProfile),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Responsive.pagePadding(),
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: avatar,
                    height: avatar,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: context.palette.border,
                        width: 2.w,
                      ),
                    ),
                    child: AppNetworkImage.avatar(
                      url: _imagePath ?? '',
                      width: avatar,
                      height: avatar,
                      radius: 26.r,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: auth.isLoading ? null : _pickImage,
                      child: CircleAvatar(
                        radius: 16.r,
                        backgroundColor: AppColors.brand600,
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Responsive.spaceLg.gapH,
            CustomTextField(
              controller: _nameController,
              label: l10n.name,
              hint: l10n.nameHint,
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.required(value, l10n),
            ),
            Responsive.spaceMd.gapH,
            CustomTextField(
              controller: _emailController,
              label: l10n.email,
              hint: l10n.emailHint,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                InputFormatters.noSpaces,
                InputFormatters.email,
              ],
              validator: (value) => Validators.email(value, l10n),
            ),
            if (!hasPassword) ...[
              Responsive.spaceSm.gapH,
              Text(
                l10n.socialAccountHint,
                style: TextStyle(
                  color: context.palette.textMuted,
                  fontSize: Responsive.fontSm,
                  height: 1.35,
                ),
              ),
            ],
            Responsive.spaceMd.gapH,
            PhoneTextField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _phoneChanged
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Responsive.spaceMd.gapH,
                        if (otpSent)
                          OtpInput(
                            controller: _otpController,
                            label: l10n.otp,
                            length: Validators.otpLength,
                            validator: (value) => Validators.otp(value, l10n),
                            action: TextButton(
                              onPressed: auth.isLoading ? null : _sendPhoneOtp,
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
                          )
                        else
                          CustomButton(
                            label: l10n.sendOtp,
                            icon: Icons.sms_outlined,
                            variant: AppButtonVariant.outlined,
                            isLoading: auth.isLoading,
                            onPressed: _sendPhoneOtp,
                          ),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
            if (hasPassword) ...[
              Responsive.spaceLg.gapH,
              Text(
                l10n.password,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: Responsive.fontBody,
                ),
              ),
              Responsive.spaceSm.gapH,
              Text(
                l10n.passwordHint,
                style: TextStyle(
                  color: context.palette.textMuted,
                  fontSize: Responsive.fontSm,
                ),
              ),
              Responsive.spaceMd.gapH,
              CustomTextField(
                controller: _currentPasswordController,
                label: l10n.currentPassword,
                obscureText: _obscureCurrent,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.next,
                onToggleObscure: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (value) {
                  if (!_emailChanged && !_wantsPasswordChange) return null;
                  return Validators.required(value, l10n);
                },
              ),
              Responsive.spaceMd.gapH,
              CustomTextField(
                controller: _newPasswordController,
                label: l10n.newPassword,
                hint: l10n.passwordHint,
                obscureText: _obscureNew,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.next,
                onToggleObscure: () =>
                    setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (!_wantsPasswordChange) return null;
                  return Validators.password(value, l10n);
                },
              ),
              Responsive.spaceMd.gapH,
              CustomTextField(
                controller: _confirmPasswordController,
                label: l10n.confirmNewPassword,
                obscureText: _obscureConfirm,
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.done,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (!_wantsPasswordChange) return null;
                  if (value != _newPasswordController.text) {
                    return l10n.passwordsDoNotMatch;
                  }
                  return Validators.password(value, l10n);
                },
              ),
            ],
            Responsive.spaceLg.gapH,
            CustomButton(
              label: l10n.saveChanges,
              icon: Icons.check,
              isLoading: auth.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
