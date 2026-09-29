import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_5roga/core/demo/discover_data.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/features/discover/presentation/pages/discover_place_details_page.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/suggested_place_tile.dart';

/// Vertical list of nearby / filtered places with an optional section title.
class NearbyPlacesList extends StatelessWidget {
  const NearbyPlacesList({
    super.key,
    required this.places,
    this.title,
  });

  final List<SuggestedPlace> places;
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
        for (final place in places) ...[
          SuggestedPlaceTile(
            place: place,
            onTap: () => Get.to(() => DiscoverPlaceDetailsPage(placeId: place.id)),
          ),
          Responsive.spaceSm.gapH,
        ],
      ],
    );
  }
}
