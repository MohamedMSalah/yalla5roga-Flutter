import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/core/network/mock_repository.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_chat_read_result.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outing_chat_repository.dart';

class OutingChatMockRepository implements OutingChatRepository {
  const OutingChatMockRepository();

  @override
  Future<Either<Failure, OutingChatReadResult>> markRead(String outingId) {
    return mockRight(
      OutingChatReadResult(outingId: outingId, unreadCount: 0, unreadChatCount: 0),
    );
  }
}
