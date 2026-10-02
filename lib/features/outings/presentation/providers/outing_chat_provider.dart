import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/error/app_error_feedback.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';
import 'package:yalla_5roga/features/outings/domain/entities/chat_message.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outing_chat_repository.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

class OutingChatProvider extends ChangeNotifier {
  OutingChatProvider({
    required this.repository,
    required this.unreadCounts,
    required this.outings,
  });

  final OutingChatRepository repository;
  final UnreadCountsRepository unreadCounts;
  final OutingsProvider outings;

  var _unread = <String, int>{};
  int _unreadChatCount = 0;
  var _isLoading = false;
  var _isUpdating = false;
  var _hasLoaded = false;
  String? _errorMessage;
  final _threads = <String, List<ChatMessage>>{};
  var _epoch = 0;

  int get unreadChatCount => _unreadChatCount;

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  bool get hasLoaded => _hasLoaded;

  bool get isInitialLoading => !_hasLoaded;

  String? get errorMessage => _errorMessage;

  int unreadFor(String outingId) => _unread[outingId] ?? 0;

  List<ChatMessage> messagesFor(String outingId) {
    final thread = _threads[outingId];
    if (thread != null) return List.unmodifiable(thread);
    return const [];
  }

  Future<void> loadMessages(String outingId) async {
    final result = await repository.getMessages(outingId);
    result.fold((failure) {
      _errorMessage = failure.message;
      AppErrorFeedback.report(
        failure,
        kind: AppErrorKind.load,
        context: 'loadMessages',
      );
    }, (messages) => _threads[outingId] = List.of(messages));
    notifyListeners();
  }

  void applyCounts(UnreadCounts counts) {
    _unreadChatCount = counts.unreadChatCount;
    _unread = Map.of(counts.chatUnreadByOutingId);
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    final token = ++_epoch;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await unreadCounts.fetchCounts();
    if (token != _epoch) {
      _finishInitialLoad();
      return;
    }
    result.fold<void>((failure) {
      _errorMessage = failure.message;
      AppErrorFeedback.report(
        failure,
        kind: AppErrorKind.load,
        context: 'chatUnread',
      );
    }, applyCounts);

    _finishInitialLoad();
  }

  void _finishInitialLoad() {
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  Future<bool> markRead(String outingId) async {
    final token = ++_epoch;
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.markRead(outingId);
    if (token != _epoch) return false;
    final success = result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.send,
          context: 'chatMarkRead',
        );
        return false;
      },
      (read) {
        _unread[outingId] = read.unreadCount;
        _unreadChatCount = read.unreadChatCount;
        return true;
      },
    );

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  bool isChatClosed(String outingId) {
    final outing = outings.findById(outingId);
    if (outing == null) return false;
    return outing.isPastOuting || outing.status == OutingStatus.past;
  }

  Future<bool> send(
    String outingId,
    String text,
    L10n l10n, {
    String? senderId,
    String? senderName,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (isChatClosed(outingId)) return false;
    final result = await repository.sendMessage(
      outingId: outingId,
      text: trimmed,
      senderId: senderId ?? 'me',
      senderName: senderName ?? l10n.you,
    );
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        AppErrorFeedback.report(
          failure,
          kind: AppErrorKind.send,
          context: 'sendChat',
        );
        notifyListeners();
        return false;
      },
      (message) {
        final thread = _threads.putIfAbsent(outingId, () => <ChatMessage>[]);
        thread.add(message);
        notifyListeners();
        _progressDelivery(outingId, message.id);
        return true;
      },
    );
  }

  Future<void> _progressDelivery(String outingId, String messageId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!_updateStatus(outingId, messageId, MessageDeliveryStatus.delivered))
      return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _updateStatus(outingId, messageId, MessageDeliveryStatus.seen);
  }

  bool _updateStatus(
    String outingId,
    String messageId,
    MessageDeliveryStatus status,
  ) {
    final thread = _threads[outingId];
    if (thread == null) return false;
    final index = thread.indexWhere((message) => message.id == messageId);
    if (index < 0) return false;
    thread[index] = thread[index].copyWith(deliveryStatus: status);
    notifyListeners();
    return true;
  }

  void clear() {
    _epoch++;
    _unread = {};
    _unreadChatCount = 0;
    _isLoading = false;
    _isUpdating = false;
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
  }
}
