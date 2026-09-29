import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_5roga/core/demo/discover_data.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/features/discover/presentation/pages/discover_place_details_page.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/discover_place_card.dart';

/// Horizontal carousel of featured discover place cards.
class DiscoverFeaturedCarousel extends StatelessWidget {
  const DiscoverFeaturedCarousel({
    super.key,
    required this.places,
    this.compact = false,
    this.showPriceLevel = true,
    this.title,
  });

  final List<SuggestedPlace> places;
  final bool compact;
  final bool showPriceLevel;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!.toUpperCase(),
            style: TextStyle(
              color: context.palette.textMuted,
              fontSize: Responsive.fontCaption,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          Responsive.spaceSm.gapH,
        ],
        SizedBox(
          height: compact ? 168.h : 168.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            separatorBuilder: (_, _) => Responsive.spaceSm.gapW,
            itemBuilder: (context, index) {
              final place = places[index];
              return DiscoverPlaceCard(
                place: place,
                compact: compact,
                showPriceLevel: showPriceLevel,
                onTap: () => Get.to(() => DiscoverPlaceDetailsPage(placeId: place.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}
