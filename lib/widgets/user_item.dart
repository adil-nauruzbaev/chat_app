import 'package:chat_app_test/constants/colors.dart';
import 'package:chat_app_test/models/user_profile.dart';
import 'package:flutter/material.dart';

class UserItem extends StatelessWidget {
  final UserProfile user;
  final Function onTap;
  const UserItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name!,
                  style: const TextStyle(
                      color: ColorSelect.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Написать сообщение',
                  style: TextStyle(
                      color: ColorSelect.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
