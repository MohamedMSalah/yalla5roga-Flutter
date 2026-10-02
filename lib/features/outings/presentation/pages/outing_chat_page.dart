import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/utils/member_display_name.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_icon_button.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
import 'package:yalla_5roga/features/auth/presentation/providers/auth_provider.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outing_chat_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_chat_skeleton.dart';

class OutingChatPage extends StatefulWidget {
  const OutingChatPage({super.key, required this.event});

  final HeroSlide event;

  @override
  State<OutingChatPage> createState() => _OutingChatPageState();
}

class _OutingChatPageState extends State<OutingChatPage> {
  static const _mentionAllToken = 'all';

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Query after `@` while mentioning; null when the picker is hidden.
  String? _mentionQuery;
  int? _mentionStart;
  var _ignoreMentionUpdates = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OutingsProvider>().refreshLifecycle();
      final chat = context.read<OutingChatProvider>();
      chat.loadMessages(widget.event.id);
      chat.markRead(widget.event.id);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_ignoreMentionUpdates) return;

    final text = _controller.text;
    final selection = _controller.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      _clearMention();
      return;
    }

    final cursor = selection.baseOffset;
    if (cursor < 0 || cursor > text.length) {
      _clearMention();
      return;
    }

    final before = text.substring(0, cursor);
    final atIndex = before.lastIndexOf('@');
    if (atIndex < 0) {
      _clearMention();
      return;
    }
    if (atIndex > 0) {
      final previous = before[atIndex - 1];
      if (!_isMentionBoundary(previous)) {
        _clearMention();
        return;
      }
    }

    final query = before.substring(atIndex + 1);
    if (query.contains('\n')) {
      _clearMention();
      return;
    }

    setState(() {
      _mentionStart = atIndex;
      _mentionQuery = query;
    });
  }

  bool _isMentionBoundary(String char) =>
      char == ' ' || char == '\n' || char == '\t';

  void _clearMention() {
    if (_mentionQuery == null && _mentionStart == null) return;
    setState(() {
      _mentionQuery = null;
      _mentionStart = null;
    });
  }

  bool _showMentionAll(String? query) {
    if (query == null) return false;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return _mentionAllToken.startsWith(q) ||
        'everyone'.startsWith(q) ||
        'الجميع'.startsWith(q);
  }

  List<GroupMember> _mentionCandidates(List<GroupMember> members) {
    final query = _mentionQuery;
    if (query == null) return const [];
    final q = query.trim().toLowerCase();
    final filtered = members.where((member) {
      final name = MemberDisplayName.resolve(member).toLowerCase();
      if (q.isEmpty) return true;
      return name.startsWith(q) ||
          name.split(' ').any((part) => part.startsWith(q));
    }).toList();
    filtered.sort(
      (a, b) =>
          MemberDisplayName.resolve(a).compareTo(MemberDisplayName.resolve(b)),
    );
    return filtered;
  }

  void _insertMentionToken(String token) {
    final start = _mentionStart;
    if (start == null) return;
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset.clamp(0, text.length);
    final mention = '@$token ';
    final next = text.replaceRange(start, cursor, mention);

    _ignoreMentionUpdates = true;
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + mention.length),
    );
    setState(() {
      _mentionQuery = null;
      _mentionStart = null;
      _ignoreMentionUpdates = false;
    });
    _focusNode.requestFocus();
  }

  void _insertMention(GroupMember member) {
    _insertMentionToken(MemberDisplayName.resolve(member));
  }

  void _insertMentionAll() {
    _insertMentionToken(_mentionAllToken);
  }

  Future<void> _send() async {
    final chat = context.read<OutingChatProvider>();
    if (chat.isChatClosed(widget.event.id)) return;
    final auth = context.read<AuthProvider>();
    final sent = await chat.send(
      widget.event.id,
      _controller.text,
      context.l10n,
      senderId: auth.user?.id,
      senderName: auth.user?.name ?? context.l10n.you,
    );
    if (sent && mounted) {
      _controller.clear();
      _clearMention();
    }
  }

  IconData _statusIcon(MessageDeliveryStatus status) {
    return switch (status) {
      MessageDeliveryStatus.sent => Icons.check,
      MessageDeliveryStatus.delivered ||
      MessageDeliveryStatus.seen => Icons.done_all,
    };
  }

  Color _statusColor(MessageDeliveryStatus status) {
    return switch (status) {
      MessageDeliveryStatus.seen => const Color(0xFF90CAF9),
      _ => Colors.white70,
    };
  }

  List<GroupMember> _groupMembers(
    GroupsProvider groups,
    OutingsProvider outings,
  ) {
    final groupId = widget.event.groupId;
    if (groupId != null) {
      final group = groups.findById(groupId);
      if (group != null) return group.people;
    }
    return outings.membersForOuting(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final chat = context.watch<OutingChatProvider>();
    final groups = context.watch<GroupsProvider>();
    final outings = context.watch<OutingsProvider>();
    final messages = chat.messagesFor(widget.event.id);
    final closed = chat.isChatClosed(widget.event.id);
    final members = _groupMembers(groups, outings);
    final mentionCandidates = closed
        ? const <GroupMember>[]
        : _mentionCandidates(members);
    final showMentionAll = !closed && _showMentionAll(_mentionQuery);
    final showMentions =
        !closed &&
        _mentionQuery != null &&
        (showMentionAll ||
            mentionCandidates.isNotEmpty ||
            _mentionQuery!.isEmpty);

    return Scaffold(
      appBar: AppPageBar(title: widget.event.title, subtitle: l10n.outingChat),
      body: Column(
        children: [
          Expanded(
            child: chat.isInitialLoading
                ? const OutingChatSkeleton()
                : messages.isEmpty
                ? AppEmptyState(
                    icon: Icons.chat_bubble_outline,
                    message: l10n.noChatMessages,
                    subtitle: l10n.noChatMessagesHint,
                  )
                : ListView.separated(
                    padding: Responsive.pagePadding(),
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => 10.gapH,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final align = message.isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft;
                      final member = message.senderId == null
                          ? null
                          : groups.memberById(message.senderId!);
                      final senderName = l10n.digits(
                        member != null
                            ? MemberDisplayName.resolve(member)
                            : message.sender,
                      );
                      return Align(
                        alignment: align,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!message.isMine) ...[
                              AppNetworkImage.avatar(
                                url: message.avatar ?? '',
                                width: 28.w,
                                height: 28.w,
                                radius: 999,
                              ),
                              8.gapW,
                            ],
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 240.w),
                              child: Container(
                                padding: Responsive.padding(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: message.isMine
                                      ? AppColors.brand600
                                      : palette.surface,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: message.isMine
                                      ? null
                                      : Border.all(color: palette.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!message.isMine)
                                      Text(
                                        senderName,
                                        style: TextStyle(
                                          color: AppColors.brand600,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    _MentionText(
                                      text: message.text,
                                      members: members,
                                      style: TextStyle(
                                        color: message.isMine
                                            ? Colors.white
                                            : palette.textPrimary,
                                        fontSize: Responsive.fontSm,
                                      ),
                                      mentionStyle: TextStyle(
                                        color: message.isMine
                                            ? Colors.white
                                            : AppColors.brand600,
                                        fontSize: Responsive.fontSm,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    4.gapH,
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.l10n.digits(message.time),
                                          style: TextStyle(
                                            color: message.isMine
                                                ? Colors.white70
                                                : palette.textMuted,
                                            fontSize: Responsive.fontXs,
                                          ),
                                        ),
                                        if (message.isMine) ...[
                                          4.gapW,
                                          Icon(
                                            _statusIcon(message.deliveryStatus),
                                            size: 14.sp,
                                            color: _statusColor(
                                              message.deliveryStatus,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (showMentions)
            _MentionPicker(
              members: mentionCandidates,
              showMentionAll: showMentionAll,
              mentionAllLabel: l10n.mentionAllLabel,
              mentionAllSubtitle: l10n.mentionAll,
              emptyLabel: l10n.noMembersToMention,
              title: l10n.mentionSomeone,
              onSelected: _insertMention,
              onMentionAll: _insertMentionAll,
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: Responsive.padding(horizontal: 16, top: 8, bottom: 8),
              child: closed
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: palette.surfaceMuted,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 18.w,
                                color: palette.textMuted,
                              ),
                              8.gapW,
                              Text(
                                l10n.chatClosed,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                          4.gapH,
                          Text(
                            l10n.chatClosedHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: InputDecoration(
                              hintText: l10n.writeMessage,
                              filled: true,
                              fillColor: palette.inputFill,
                            ),
                          ),
                        ),
                        8.gapW,
                        AppIconButton(
                          icon: Icons.send_rounded,
                          background: AppColors.brand600,
                          foreground: Colors.white,
                          onTap: _send,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentionPicker extends StatelessWidget {
  const _MentionPicker({
    required this.members,
    required this.showMentionAll,
    required this.mentionAllLabel,
    required this.mentionAllSubtitle,
    required this.onSelected,
    required this.onMentionAll,
    required this.title,
    required this.emptyLabel,
  });

  final List<GroupMember> members;
  final bool showMentionAll;
  final String mentionAllLabel;
  final String mentionAllSubtitle;
  final ValueChanged<GroupMember> onSelected;
  final VoidCallback onMentionAll;
  final String title;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final itemCount = members.length + (showMentionAll ? 1 : 0);
    return Material(
      color: palette.surface,
      elevation: 2,
      child: Container(
        constraints: BoxConstraints(maxHeight: 220.h),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: Responsive.padding(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.sp,
                  color: palette.textMuted,
                ),
              ),
            ),
            if (itemCount == 0)
              Padding(
                padding: Responsive.padding(horizontal: 16, vertical: 12),
                child: Text(
                  emptyLabel,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: Responsive.fontSm,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: 8.h),
                  itemCount: itemCount,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: palette.border),
                  itemBuilder: (context, index) {
                    if (showMentionAll && index == 0) {
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.brand50,
                          child: Icon(
                            Icons.groups_outlined,
                            color: AppColors.brand600,
                            size: 18.sp,
                          ),
                        ),
                        title: Text(
                          mentionAllLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: Responsive.fontSm,
                            color: AppColors.brand600,
                          ),
                        ),
                        subtitle: Text(
                          mentionAllSubtitle,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: palette.textMuted,
                          ),
                        ),
                        onTap: onMentionAll,
                      );
                    }
                    final member = members[index - (showMentionAll ? 1 : 0)];
                    final name = MemberDisplayName.resolve(member);
                    return ListTile(
                      dense: true,
                      leading: AppNetworkImage.avatar(
                        url: member.avatar,
                        width: 36.w,
                        height: 36.w,
                        radius: 999,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.fontSm,
                        ),
                      ),
                      onTap: () => onSelected(member),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MentionText extends StatelessWidget {
  const _MentionText({
    required this.text,
    required this.members,
    required this.style,
    required this.mentionStyle,
  });

  final String text;
  final List<GroupMember> members;
  final TextStyle style;
  final TextStyle mentionStyle;

  @override
  Widget build(BuildContext context) {
    final names = <String>[
      _OutingChatPageState._mentionAllToken,
      ...members
          .map(MemberDisplayName.resolve)
          .where((name) => name.trim().isNotEmpty),
    ]..sort((a, b) => b.length.compareTo(a.length));

    if (!text.contains('@')) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    var i = 0;
    while (i < text.length) {
      if (text[i] != '@') {
        final nextAt = text.indexOf('@', i);
        final end = nextAt < 0 ? text.length : nextAt;
        spans.add(TextSpan(text: text.substring(i, end), style: style));
        i = end;
        continue;
      }

      var matched = false;
      for (final name in names) {
        final token = '@$name';
        if (text.startsWith(token, i)) {
          final boundary = i + token.length;
          final okBoundary =
              boundary >= text.length ||
              RegExp(r'[\s,.!?;:]').hasMatch(text[boundary]);
          if (okBoundary) {
            spans.add(TextSpan(text: token, style: mentionStyle));
            i = boundary;
            matched = true;
            break;
          }
        }
      }
      if (!matched) {
        spans.add(TextSpan(text: '@', style: style));
        i += 1;
      }
    }

    return Text.rich(TextSpan(children: spans));
  }
}
