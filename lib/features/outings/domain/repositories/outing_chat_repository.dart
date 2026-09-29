import 'package:dartz/dartz.dart';
import 'package:yalla_5roga/core/error/failures.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_chat_read_result.dart';

abstract class OutingChatRepository {
  Future<Either<Failure, OutingChatReadResult>> markRead(String outingId);
}
