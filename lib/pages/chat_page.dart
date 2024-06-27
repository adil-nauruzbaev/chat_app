import 'dart:io';

import 'package:chat_app_test/constants/colors.dart';
import 'package:chat_app_test/models/chat.dart';
import 'package:chat_app_test/models/message.dart';
import 'package:chat_app_test/models/user_profile.dart';
import 'package:chat_app_test/services/auth_service.dart';
import 'package:chat_app_test/services/database_service.dart';
import 'package:chat_app_test/services/media_service.dart';
import 'package:chat_app_test/services/navigation_service.dart';
import 'package:chat_app_test/services/storage_service.dart';
import 'package:chat_app_test/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatUser});
  final UserProfile chatUser;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;

  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  late StorageService _storageService;
  late NavigationService _navigationService;

  late AuthService _authService;
  late DatabaseService _databaseService;
  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _navigationService = _getIt.get<NavigationService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser =
        ChatUser(id: widget.chatUser.uid!, firstName: widget.chatUser.name);
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            _chat(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 24,
            onPressed: () {
              _navigationService.goBack();
            },
            icon: const ImageIcon(
              AssetImage("assets/images/icons/Arrow_left_s.png"),
              color: ColorSelect.primaryLabel,
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: CircleAvatar(
              radius: 34,
              backgroundImage: NetworkImage(widget.chatUser.picURL!),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chatUser.name!,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Text(
                'В сети',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorSelect.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chat() {
    return Expanded(
      child: StreamBuilder(
        stream: _databaseService.getChatData(
          currentUser!.id,
          otherUser!.id,
        ),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessagesList(chat.messages!);
          }
          return DashChat(
            messageOptions: MessageOptions(
              messageDecorationBuilder:
                  (message, previousMessage, nextMessage) {
                final isUser = message.user.id == _authService.user!.uid;
                return BoxDecoration(
                  color: isUser
                      ? ColorSelect.primaryColor
                      : ColorSelect.secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(21.0),
                    topRight: const Radius.circular(21.0),
                    bottomLeft: isUser
                        ? const Radius.circular(21.0)
                        : const Radius.circular(0.0),
                    bottomRight: isUser
                        ? const Radius.circular(0.0)
                        : const Radius.circular(21.0),
                  ),
                );
              },
              messageTextBuilder: (message, previousMessage, nextMessage) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                          color: ColorSelect.primaryLabel, fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${message.createdAt.hour}:${message.createdAt.minute}",
                      style: const TextStyle(
                          color: ColorSelect.primaryLabel, fontSize: 12),
                    ),
                  ],
                );
              },
              showTime: false,
              showOtherUsersAvatar: false,
              showOtherUsersName: false,
              currentUserContainerColor: ColorSelect.primaryColor,
              currentUserTextColor: ColorSelect.primaryLabel,
              containerColor: ColorSelect.secondaryColor,
              textColor: ColorSelect.primaryLabel,
              messagePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 21,
              timeTextColor: ColorSelect.primaryLabel,
              timeFontSize: 12,
            ),
            inputOptions: InputOptions(
              sendButtonBuilder: (VoidCallback onSend) {
                return const SizedBox.shrink();
              },
              sendOnEnter: true,
              inputDecoration: const InputDecoration.collapsed(
                  hintText: 'Сообщение',
                  hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorSelect.secondaryLabel)),
              alwaysShowSend: false,
              trailing: [
                Padding(
                  padding: const EdgeInsets.only(right: 9),
                  child: IconButton(
                    onPressed: () {},
                    icon: const ImageIcon(
                      AssetImage("assets/images/icons/Audio.png"),
                      color: ColorSelect.primaryLabel,
                    ),
                  ),
                ),
              ],
              leading: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 20),
                  child: IconButton(
                    onPressed: () async {
                      File? file = await _mediaService.getImageFromGallery();
                      if (file != null) {
                        String chatID = generateChatID(
                            uid1: currentUser!.id, uid2: otherUser!.id);
                        String? downloadURL = await _storageService
                            .uploadImageToChat(file: file, chatId: chatID);
                        if (downloadURL != null) {
                          ChatMessage chatMessage = ChatMessage(
                            user: currentUser!,
                            createdAt: DateTime.now(),
                            medias: [
                              ChatMedia(
                                  url: downloadURL,
                                  fileName: '',
                                  type: MediaType.image)
                            ],
                          );
                          _sendMessage(chatMessage);
                        }
                      }
                    },
                    icon: const ImageIcon(
                      AssetImage("assets/images/icons/Attach.png"),
                      color: ColorSelect.primaryLabel,
                    ),
                  ),
                ),
              ],
            ),
            currentUser: currentUser!,
            onSend: _sendMessage,
            messages: messages,
          );
        },
      ),
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
      String lastMessage = chatMessage.text;
      String lastMessageSenderID = currentUser!.id;
      Timestamp lastMessageDate = Timestamp.fromDate(chatMessage.createdAt);
      await _databaseService.updateChatData(currentUser!.id, otherUser!.id,
          lastMessage, lastMessageSenderID, lastMessageDate);
    }
  }

  Future<void> _updateChatData(ChatMessage chatMessage) async {
    {
      String lastMessage = chatMessage.text;
      String lastMessageSenderID = currentUser!.id;
      Timestamp lastMessageDate = Timestamp.fromDate(chatMessage.createdAt);
      await _databaseService.updateChatData(currentUser!.id, otherUser!.id,
          lastMessage, lastMessageSenderID, lastMessageDate);
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
          medias: [
            ChatMedia(
              url: m.content!,
              fileName: '',
              type: MediaType.image,
            )
          ],
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      } else {
        return ChatMessage(
          text: m.content!,
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }
}
