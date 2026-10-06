import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/discover/presentation/providers/discover_provider.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';

/// True until the first shell data fetch finishes (home/groups/outings tabs).
bool shellIsLoading(BuildContext context) {
  return context.watch<NotificationsProvider>().isInitialLoading ||
      context.watch<GroupsProvider>().isInitialLoading ||
      !context.watch<OutingsProvider>().hasLoaded ||
      !context.watch<DiscoverProvider>().hasLoaded;
}
