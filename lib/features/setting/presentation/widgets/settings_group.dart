import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/icon_circle.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.action,
  });

  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontBody)),
              ),
              ?action,
            ],
          ),
          12.gapH,
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 20.h, color: context.palette.border),
            children[i],
          ],
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.background,
    this.foreground,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? background;
  final Color? foreground;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          IconCircle(
            icon: icon,
            size: 32,
            radius: 8,
            iconSize: 16,
            background: background,
            foreground: foreground,
          ),
          12.gapW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
