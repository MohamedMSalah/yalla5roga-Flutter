import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/utils/member_display_name.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_icon_button.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
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
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    _controller.dispose();
    super.dispose();
  }

  void _send() async {
    final chat = context.read<OutingChatProvider>();
    if (chat.isChatClosed(widget.event.id)) return;
    final sent = await chat.send(
      widget.event.id,
      _controller.text,
      context.l10n,
    );
    if (sent && mounted) _controller.clear();
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final chat = context.watch<OutingChatProvider>();
    final groups = context.watch<GroupsProvider>();
    final messages = chat.messagesFor(widget.event.id);
    final closed = chat.isChatClosed(widget.event.id);

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
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        color: message.isMine
                                            ? Colors.white
                                            : palette.textPrimary,
                                        fontSize: Responsive.fontSm,
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
