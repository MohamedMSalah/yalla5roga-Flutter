import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, this.onTap});

  final Group group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outingCount = context.watch<OutingsProvider>().forGroup(group.id).length;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            children: [
              AppNetworkImage(
                url: group.avatars.first,
                width: 56.w,
                height: 56.w,
                radius: 16.r,
              ),
              if (group.unread > 0)
                Positioned(
                  right: 4.w,
                  top: 4.h,
                  child: CircleAvatar(radius: 4.r, backgroundColor: AppColors.emerald500),
                ),
            ],
          ),
          12.gapW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    if (group.unread > 0)
                      CircleAvatar(
                        radius: 10.r,
                        backgroundColor: AppColors.rose500,
                        child: Text(
                          l10n.n(group.unread),
                          style: TextStyle(color: Colors.white, fontSize: Responsive.fontXs, fontWeight: FontWeight.w800),
                        ),
                      )
                    else
                      Icon(context.chevronForward, color: context.palette.border, size: 20.w),
                  ],
                ),
                Text(
                  l10n.membersOutings(group.members, outingCount),
                  style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp),
                ),
                if (group.preview.isNotEmpty) ...[
                  6.gapH,
                  Text.rich(
                    TextSpan(
                      children: [
                        if (group.lastMessage != null)
                          TextSpan(
                            text: '${l10n.digits(group.lastMessage!)}: ',
                            style: TextStyle(
                              color: AppColors.brand600,
                              fontWeight: FontWeight.w800,
                              fontSize: Responsive.fontSm,
                            ),
                          ),
                        TextSpan(
                          text: l10n.digits(group.preview),
                          style: TextStyle(color: context.palette.textMuted, fontSize: Responsive.fontSm),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
