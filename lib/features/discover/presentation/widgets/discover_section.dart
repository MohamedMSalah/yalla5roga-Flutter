import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_5roga/core/demo/discover_data.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/section_header.dart';
import 'package:yalla_5roga/features/discover/presentation/pages/discover_page.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/discover_featured_carousel.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/nearby_places_list.dart';

class DiscoverSection extends StatelessWidget {
  const DiscoverSection({
    super.key,
    this.compact = true,
    this.limit = 5,
    this.showPlaces = false,
  });

  final bool compact;
  final int limit;
  final bool showPlaces;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final featured = DiscoverData.featuredPlaces().take(limit).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.discover,
          subtitle: l10n.exploreNearby,
          actionLabel: l10n.seeAll,
          onAction: () => Get.to(() => const DiscoverPage()),
        ),
        12.gapH,
        DiscoverFeaturedCarousel(
          places: featured,
          compact: compact,
          showPriceLevel: false,
        ),
        if (showPlaces) ...[
          Responsive.spaceMd.gapH,
          NearbyPlacesList(
            places: DiscoverData.places.take(3).toList(),
            title: l10n.nearbyPlaces,
          ),
        ],
      ],
    );
  }
}
