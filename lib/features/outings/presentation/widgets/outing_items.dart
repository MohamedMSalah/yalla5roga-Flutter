import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
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

    return Column(
      children: [
        for (final outing in items) ...[
          OutingListTile(
            title: outing.title,
            subtitle: '${outing.date} · ${outing.time} · ${l10n.goingCount(outing.going)}',
            image: outing.image,
            onTap: () => Get.to(() => EventPage(event: outing)),
          ),
          8.gapH,
        ],
      ],
    );
  }
}
