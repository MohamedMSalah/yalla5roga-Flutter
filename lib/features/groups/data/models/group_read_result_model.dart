import 'package:yalla_5roga/core/network/api_payload.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_read_result.dart';

class GroupReadResultModel extends GroupReadResult {
  const GroupReadResultModel({
    required super.groupId,
    required super.unreadCount,
    required super.unreadGroupCount,
  });

  factory GroupReadResultModel.fromJson(
    Map<String, dynamic> json, {
    required String groupId,
  }) {
    return GroupReadResultModel(
      groupId: apiString(json['groupId']) ?? groupId,
      unreadCount: apiInt(json['unreadCount']),
      unreadGroupCount: apiInt(json['unreadGroupCount']),
    );
  }
}
