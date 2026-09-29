import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_icon_button.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
import 'package:yalla_5roga/core/utils/app_launcher.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/avatar_stack.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/outing_chat_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/saved_outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_going_sheet.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key, required this.event});

  final HeroSlide event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final saved = context.watch<SavedOutingsProvider>().isSaved(event.id);

    return Scaffold(
      // AppPageBar — outing title + bookmark AppIconButton
      appBar: AppPageBar(
        title: event.title,
        trailing: AppIconButton(
          icon: saved ? Icons.bookmark : Icons.bookmark_border,
          background: saved ? AppColors.brand600 : null,
          foreground: saved ? Colors.white : null,
          onTap: () => _toggleSaved(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: Responsive.pagePadding(),
          children: [
            // AppNetworkImage — cover photo
            AppNetworkImage(url: event.image, width: double.infinity, height: 220.h, radius: 24.r),
            Responsive.spaceMd.gapH,
            Text(
              event.title,
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800),
            ),
            Responsive.spaceXs.gapH,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                // AppBadge — confirmed / birthday / wedding
                AppBadge(label: l10n.confirmed, color: AppColors.emerald500, textColor: Colors.white),
                if (event.occasion == OutingOccasion.birthday)
                  AppBadge(label: l10n.birthday, color: AppColors.brand50, textColor: AppColors.brand700),
                if (event.occasion == OutingOccasion.wedding)
                  AppBadge(label: l10n.wedding, color: const Color(0xFFEDE9FE), textColor: const Color(0xFF7C3AED)),
              ],
            ),
            Responsive.spaceSm.gapH,
            Text(event.meta, style: TextStyle(color: palette.textMuted, fontSize: Responsive.fontBody)),
            Responsive.spaceMd.gapH,
            Row(
              children: [
                Icon(Icons.event, size: Responsive.iconMd, color: AppColors.brand600),
                8.gapW,
                Text(event.date, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontBody)),
                const Spacer(),
                Icon(Icons.schedule, size: Responsive.iconMd, color: AppColors.brand600),
                8.gapW,
                Text(event.time, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontBody)),
              ],
            ),
            Responsive.spaceMd.gapH,
            // AvatarStack + AppBadge — who's going (opens OutingGoingSheet)
            GestureDetector(
              onTap: () => OutingGoingSheet.show(event),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    AvatarStack(urls: DemoData.avatars.take(3).toList(), extra: event.going - 3),
                    12.gapW,
                    Expanded(
                      child: Text(
                        l10n.goingCount(event.going),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontSm),
                      ),
                    ),
                    AppBadge(label: l10n.youreIn, color: AppColors.emerald50, textColor: const Color(0xFF059669)),
                  ],
                ),
              ),
            ),
            Responsive.spaceLg.gapH,
            // CustomButton — open maps
            _MapsButton(event: event),
            Responsive.spaceSm.gapH,
            // CustomButton — OutingChatPage
            CustomButton(
              label: l10n.outingChat,
              icon: Icons.chat_bubble_outline,
              variant: AppButtonVariant.outlined,
              onPressed: () => Get.to(() => OutingChatPage(event: event)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSaved(BuildContext context) async {
    final added = await context.read<SavedOutingsProvider>().toggle(event);
    if (!context.mounted) return;
    AppSnackBar.show(added ? context.l10n.outingSaved : context.l10n.outingRemoved);
  }
}

class _MapsButton extends StatefulWidget {
  const _MapsButton({required this.event});

  final HeroSlide event;

  @override
  State<_MapsButton> createState() => _MapsButtonState();
}

class _MapsButtonState extends State<_MapsButton> {
  var _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    final location = widget.event.location;
    final opened = await AppLauncher.openMaps(
      latitude: location?.latitude,
      longitude: location?.longitude,
      query: location?.label ?? widget.event.meta.split('·').first.trim(),
    );
    if (!mounted) return;
    setState(() => _opening = false);
    if (!opened) AppSnackBar.show(context.l10n.couldNotOpenLink);
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: context.l10n.viewLocation,
      icon: Icons.near_me_outlined,
      isLoading: _opening,
      onPressed: _open,
    );
  }
}
