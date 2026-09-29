import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/outing_chat_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outing_chat_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/saved_outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_going_sheet.dart';

class OutingCard extends StatelessWidget {
  const OutingCard({super.key, required this.slide});

  final HeroSlide slide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final saved = context.watch<SavedOutingsProvider>().isSaved(slide.id);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        color: context.palette.surface,
        child: Column(
          children: [
            SizedBox(
              height: 144.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(url: slide.image),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xC70F172A)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12.w,
                    top: 12.h,
                    child: AppBadge(
                      label: l10n.confirmed,
                      color: AppColors.emerald500,
                      textColor: Colors.white,
                      icon: Icons.check_circle,
                    ),
                  ),
                  Positioned(
                    right: 12.w,
                    top: 12.h,
                    child: InkWell(
                      onTap: () async {
                        final added = await context.read<SavedOutingsProvider>().toggle(slide);
                        if (!context.mounted) return;
                        AppSnackBar.show(added ? l10n.outingSaved : l10n.outingRemoved);
                      },
                      child: CircleAvatar(
                        radius: 16.r,
                        backgroundColor: saved ? AppColors.brand600 : Colors.white,
                        child: Icon(
                          saved ? Icons.bookmark : Icons.bookmark_border,
                          size: 16.w,
                          color: saved ? Colors.white : AppColors.slate800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(slide.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18.sp)),
                              Text(slide.meta, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                            ],
                          ),
                        ),
                        Container(
                          padding: Responsive.padding(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: context.palette.surface, borderRadius: BorderRadius.circular(12.r)),
                          child: Column(
                            children: [
                              Text(slide.calendarMonth, style: TextStyle(color: AppColors.rose500, fontSize: Responsive.fontXs, fontWeight: FontWeight.w800)),
                              Text(slide.calendarDay, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: Responsive.iconSm, color: AppColors.brand600),
                      Responsive.spaceXs.gapW,
                      Text(slide.time, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontSm)),
                      Responsive.spaceSm.gapW,
                      Icon(Icons.groups_2_outlined, size: Responsive.iconSm, color: AppColors.brand600),
                      Responsive.spaceXs.gapW,
                      GestureDetector(
                        onTap: () => OutingGoingSheet.show(slide),
                        child: Text(l10n.goingCount(slide.going), style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontSm)),
                      ),
                      const Spacer(),
                      AppBadge(label: l10n.youreIn, color: AppColors.emerald50, textColor: const Color(0xFF059669)),
                    ],
                  ),
                  12.gapH,
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: l10n.viewPlan,
                          icon: Icons.near_me_outlined,
                          onPressed: () {
                            // TODO: open GET /outings/{id} when outing CRUD exists.
                            Get.to(() => EventPage(event: slide));
                          },
                        ),
                      ),
                      Responsive.spaceSm.gapW,
                      Consumer<OutingChatProvider>(
                        builder: (context, chat, _) {
                          final unread = chat.unreadFor(slide.id);
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton.filled(
                                onPressed: () {
                                  // TODO: open GET /outings/{id}/chat when chat history is API-backed.
                                  Get.to(() => OutingChatPage(event: slide));
                                },
                                style: IconButton.styleFrom(backgroundColor: AppColors.brand50, foregroundColor: AppColors.brand600),
                                icon: const Icon(Icons.chat_bubble_outline),
                              ),
                              if (unread > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 8.r,
                                    backgroundColor: AppColors.rose500,
                                    child: Text(
                                      '$unread',
                                      style: TextStyle(color: Colors.white, fontSize: Responsive.fontXs, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
