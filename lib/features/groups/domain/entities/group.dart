import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_role.dart';

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.members,
    required this.outings,
    required this.preview,
    required this.avatars,
    required this.image,
    required this.people,
    this.lastMessage,
    this.unread = 0,
    this.featured = false,
    this.decision,
    this.myRole = GroupRole.member,
  });

  final String id;
  final String name;
  final int members;
  final int outings;
  final String preview;
  final List<String> avatars;
  final String image;
  final List<GroupMember> people;
  final String? lastMessage;
  final int unread;
  final bool featured;
  final String? decision;
  final GroupRole myRole;

  String get coverUrl => image;

  int get memberCount => members;

  int get outingCount => outings;

  Group copyWith({
    String? image,
    List<GroupMember>? people,
    int? members,
    int? unread,
    String? name,
    String? preview,
    String? lastMessage,
    bool? featured,
    String? decision,
    GroupRole? myRole,
    int? outings,
    List<String>? avatars,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      members: members ?? people?.length ?? this.members,
      outings: outings ?? this.outings,
      preview: preview ?? this.preview,
      avatars: avatars ?? this.avatars,
      image: image ?? this.image,
      people: people ?? this.people,
      lastMessage: lastMessage ?? this.lastMessage,
      unread: unread ?? this.unread,
      featured: featured ?? this.featured,
      decision: decision ?? this.decision,
      myRole: myRole ?? this.myRole,
    );
  }
}
