import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';

class VoteOption {
  const VoteOption(this.placeId, this.label, this.votes, this.percent);

  final String placeId;
  final String label;
  final int votes;
  final int percent;

  VoteOption copyWith({String? placeId, String? label, int? votes, int? percent}) {
    return VoteOption(
      placeId ?? this.placeId,
      label ?? this.label,
      votes ?? this.votes,
      percent ?? this.percent,
    );
  }

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'label': label,
        'votes': votes,
        'percent': percent,
      };

  factory VoteOption.fromJson(Map<String, dynamic> json) {
    return VoteOption(
      json['placeId'] as String? ?? '',
      json['label'] as String? ?? '',
      json['votes'] as int? ?? 0,
      json['percent'] as int? ?? 0,
    );
  }
}

class PlaceVote {
  const PlaceVote({
    required this.outingId,
    required this.options,
    this.endsAt,
    this.myOptionId,
    this.suggestedById,
  });

  final String outingId;
  final List<VoteOption> options;
  final DateTime? endsAt;
  final String? myOptionId;
  final String? suggestedById;

  int? get myOptionIndex {
    final id = myOptionId;
    if (id == null) return null;
    final index = options.indexWhere((option) => option.placeId == id);
    return index < 0 ? null : index;
  }

  PlaceVote copyWith({
    List<VoteOption>? options,
    DateTime? endsAt,
    String? myOptionId,
    bool clearMyOption = false,
  }) {
    return PlaceVote(
      outingId: outingId,
      options: options ?? this.options,
      endsAt: endsAt ?? this.endsAt,
      myOptionId: clearMyOption ? null : (myOptionId ?? this.myOptionId),
      suggestedById: suggestedById,
    );
  }
}

class Attendance {
  const Attendance({
    required this.outingId,
    required this.userId,
    required this.status,
  });

  final String outingId;
  final String userId;
  final AttendanceStatus status;

  Map<String, dynamic> toJson() => {
        'outingId': outingId,
        'userId': userId,
        'status': status.name,
      };

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      outingId: json['outingId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: AttendanceStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => AttendanceStatus.notVoted,
      ),
    );
  }
}
