import 'package:flutter/foundation.dart';
import 'package:yalla_5roga/core/demo/demo_data.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';
import 'package:yalla_5roga/features/outings/domain/repositories/outing_chat_repository.dart';
import 'package:yalla_5roga/features/unread/domain/entities/unread_counts.dart';
import 'package:yalla_5roga/features/unread/domain/repositories/unread_counts_repository.dart';

class OutingChatProvider extends ChangeNotifier {
  OutingChatProvider({
    required this.repository,
    required this.unreadCounts,
  });

  final OutingChatRepository repository;
  final UnreadCountsRepository unreadCounts;

  var _unread = <String, int>{};
  int _unreadChatCount = 0;
  var _isLoading = false;
  var _isUpdating = false;
  var _hasLoaded = false;
  String? _errorMessage;
  final _threads = <String, List<DemoChatMessage>>{};
  var _epoch = 0;
  var _messageSeq = 0;

  int get unreadChatCount => _unreadChatCount;

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  bool get hasLoaded => _hasLoaded;

  bool get isInitialLoading => !_hasLoaded;

  String? get errorMessage => _errorMessage;

  int unreadFor(String eventId) => _unread[eventId] ?? 0;

  List<DemoChatMessage> messagesFor(String eventId) {
    final thread = _threads[eventId];
    if (thread != null) return List.unmodifiable(thread);
    return List.unmodifiable(DemoData.chatMessages);
  }

  void _ensureThread(String eventId) {
    _threads.putIfAbsent(eventId, () => List.of(DemoData.chatMessages));
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
    result.fold<void>(
      (failure) {
        _errorMessage = failure.message;
      },
      applyCounts,
    );

    _finishInitialLoad();
  }

  void _finishInitialLoad() {
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  Future<bool> markRead(String eventId) async {
    final token = ++_epoch;
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.markRead(eventId);
    if (token != _epoch) return false;
    final success = result.fold(
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
      (read) {
        _unread[eventId] = read.unreadCount;
        _unreadChatCount = read.unreadChatCount;
        return true;
      },
    );

    _isUpdating = false;
    notifyListeners();
    return success;
  }

  bool send(String eventId, String text, L10n l10n) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    _ensureThread(eventId);
    final messageId = 'local-${DateTime.now().millisecondsSinceEpoch}-${_messageSeq++}';
    _threads[eventId]!.add(
      DemoChatMessage(
        id: messageId,
        sender: l10n.you,
        senderId: 'me',
        text: trimmed,
        time: l10n.now,
        isMine: true,
        deliveryStatus: MessageDeliveryStatus.sent,
      ),
    );
    notifyListeners();
    _progressDelivery(eventId, messageId);
    return true;
  }

  Future<void> _progressDelivery(String eventId, String messageId) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!_updateStatus(eventId, messageId, MessageDeliveryStatus.delivered)) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _updateStatus(eventId, messageId, MessageDeliveryStatus.seen);
  }

  bool _updateStatus(String eventId, String messageId, MessageDeliveryStatus status) {
    final thread = _threads[eventId];
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
