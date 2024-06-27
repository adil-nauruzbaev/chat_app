import 'package:chat_app_test/constants/colors.dart';
import 'package:chat_app_test/models/chat.dart';
import 'package:chat_app_test/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatItem extends StatelessWidget {
  final Chat chat;
  final Function onTap;
  final UserProfile user;
  final bool isCurrentUser;
  const ChatItem({
    super.key,
    required this.chat,
    required this.onTap,
    required this.user,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    DateTime lastMessageDate = chat.lastMessageDate!.toDate();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage: NetworkImage(user.picURL!),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name!,
                    style: const TextStyle(
                        color: ColorSelect.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      if (isCurrentUser)
                        const Text(
                          'Вы: ',
                          style: TextStyle(
                              color: ColorSelect.primaryLabel,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      Text(
                        chat.lastMessage!,
                        style: const TextStyle(
                            color: ColorSelect.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  timeago.format(lastMessageDate),
                  style: const TextStyle(
                      color: ColorSelect.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
