import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_icon_button.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/features/auth/domain/entities/user.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onEditImage,
  });

  final User? user;
  final VoidCallback onLogout;
  final VoidCallback onEditImage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final avatar = Responsive.avatarLg;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.yourSpace.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.brand100,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  Text(
                    l10n.settings,
                    style: TextStyle(color: Colors.white, fontSize: Responsive.fontLg, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            AppIconButton(
              icon: Icons.logout,
              background: Colors.white.withValues(alpha: 0.16),
              foreground: Colors.white,
              onTap: onLogout,
            ),
          ],
        ),
        Responsive.spaceMd.gapH,
        Stack(
          children: [
            Container(
              width: avatar,
              height: avatar,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(color: Colors.white, width: 4.w),
              ),
              child: AppNetworkImage(url: user?.imageUrl ?? DemoData.avatars.last, radius: 22.r),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onEditImage,
                child: CircleAvatar(
                  radius: 12.r,
                  backgroundColor: AppColors.brand600,
                  child: Icon(Icons.edit_outlined, size: Responsive.iconSm, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        12.gapH,
        Text(
          user?.name ?? l10n.demoUserName,
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        Text(
          user?.phone ?? l10n.demoPhone,
          style: TextStyle(color: AppColors.brand100, fontSize: Responsive.fontSm),
        ),
      ],
    );
  }
}
