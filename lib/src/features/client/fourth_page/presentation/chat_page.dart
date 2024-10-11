import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:intl/intl.dart';
import 'package:tredo/src/core/resources/resources.dart';
import 'package:tredo/src/features/app/widgets/app_bar_with_title.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  final String recipientEmail;

  const ChatPage({super.key, required this.recipientEmail});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWithTitle(title: 'Chat Page'),
            // const SizedBox(height: 21),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(_getChatId())
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Start conversation'));
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe =
                          message['sender'] == _auth.currentUser!.email;
                      final timestamp = message['timestamp'] != null
                          ? (message['timestamp'] as Timestamp).toDate()
                          : null;
                      final messageDate = timestamp ?? DateTime.now();

                      // Determine whether to show a date divider
                      bool showDateDivider = false;
                      if (index == 0 ||
                          _isDifferentDate(
                              messages[index - 1]['timestamp'] as Timestamp?,
                              messageDate)) {
                        showDateDivider = true;
                      }

                      return Column(
                        children: [
                          if (showDateDivider) _buildDateDivider(messageDate),
                          _buildChatBubble(
                            message['text'] as String,
                            timestamp,
                            isMe,
                            message['sender'] as String,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            chatInputField(),
          ],
        ),
      ),
    );
  }

  String _getChatId() {
    final currentUserEmail = _auth.currentUser!.email!;
    final recipientEmail = widget.recipientEmail;
    return currentUserEmail.compareTo(recipientEmail) < 0
        ? '$currentUserEmail-$recipientEmail'
        : '$recipientEmail-$currentUserEmail';
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final chatId = _getChatId();
      _firestore.collection('chats').doc(chatId).collection('messages').add({
        'text': _messageController.text,
        'sender': _auth.currentUser!.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  Widget _buildChatBubble(
      String messageText, DateTime? timestamp, bool isMe, String sender) {
    final formattedTime = timestamp != null
        ? DateFormat('HH:mm').format(timestamp)
        : 'Sending...';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: PhysicalShape(
        clipper: isMe
            ? ChatBubbleClipper6(type: BubbleType.sendBubble)
            : ChatBubbleClipper6(type: BubbleType.receiverBubble),
        elevation: 2,
        color: isMe ? AppColors.kWhite : AppColors.kBrandSecondary,
        shadowColor: Colors.grey.shade200,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: isMe
              ? const EdgeInsets.only(top: 10, bottom: 15, left: 10, right: 24)
              : const EdgeInsets.only(top: 10, bottom: 15, left: 24, right: 10),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: AppTextStyles.os12w600GreyNeutral,
              ),
              const SizedBox(height: 4),
              Text(
                messageText,
                style: AppTextStyles.os16w500,
              ),
              const SizedBox(height: 8),
              Text(
                formattedTime,
                style: AppTextStyles.os11w500GreyNeutral,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    String formattedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      formattedDate = 'Today';
    } else if (messageDate == yesterday) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = DateFormat('dd.MM.yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          formattedDate,
          style: AppTextStyles.os14w600GreyNeutral,
        ),
      ),
    );
  }

  bool _isDifferentDate(Timestamp? previousTimestamp, DateTime currentDate) {
    if (previousTimestamp == null) return true;
    final previousDate = previousTimestamp.toDate();
    return previousDate.year != currentDate.year ||
        previousDate.month != currentDate.month ||
        previousDate.day != currentDate.day;
  }

  Widget chatInputField() => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        decoration: const BoxDecoration(
          color: AppColors.kGlobalBackground,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E5EA),
            ),
          ),
        ),
        child: Stack(
          children: [
            TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.kWhite,
                contentPadding: const EdgeInsets.only(
                  right: 42,
                  left: 16,
                  top: 18,
                ),
                hintText: 'Enter a message',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      );
}
