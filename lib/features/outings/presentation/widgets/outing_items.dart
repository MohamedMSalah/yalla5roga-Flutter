import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_list_tile.dart';

class OutingItems extends StatelessWidget {
  const OutingItems({super.key, this.limit, this.filtered = false});

  final int? limit;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<OutingsProvider>();
    final outings = filtered ? provider.filtered : provider.outings;
    final items = limit == null ? outings : outings.take(limit!).toList();

    if (items.isEmpty) {
      return AppEmptyState(
        icon: Icons.explore_outlined,
        message: filtered ? l10n.noOutingsInFilter : l10n.noOutings,
        subtitle: filtered ? l10n.noOutingsInFilterHint : l10n.noOutingsHint,
        compact: true,
      );
    }

    return Column(
      children: [
        for (final outing in items) ...[
          OutingListTile(
            title: outing.title,
            subtitle: l10n.digits(
              [
                if (outing.date.isNotEmpty) outing.date,
                if (outing.time.isNotEmpty) outing.time,
                l10n.goingCount(outing.going),
              ].join(' · '),
            ),
            image: outing.image,
            onTap: () => Get.to(() => EventPage(event: outing)),
          ),
          8.gapH,
        ],
      ],
    );
  }
}
