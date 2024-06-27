import 'package:chat_app_test/constants/colors.dart';
import 'package:chat_app_test/models/chat.dart';
import 'package:chat_app_test/models/user_profile.dart';
import 'package:chat_app_test/pages/chat_page.dart';
import 'package:chat_app_test/services/alert_service.dart';
import 'package:chat_app_test/services/auth_service.dart';
import 'package:chat_app_test/services/database_service.dart';
import 'package:chat_app_test/services/navigation_service.dart';
import 'package:chat_app_test/widgets/chat_item.dart';
import 'package:chat_app_test/widgets/user_item.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    super.initState();
  }

  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _appBar(),
                _searchBar(),
                _chatList(),
                _labelUser(),
                _userList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Чаты',
          style: TextStyle(
            color: ColorSelect.primaryLabel,
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () async {
            bool result = await _authService.logout();
            if (result) {
              _navigationService.pushReplacementNamed('/login');
              _alertService.showToast(
                  text: "Вы успешно вышли из аккаунта!", icon: Icons.check);
            } else {}
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Row(
        children: [
          const ImageIcon(
            AssetImage("assets/images/icons/Search_s.png"),
            color: ColorSelect.secondaryLabel,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              autofocus: false,
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Поиск',
                hintStyle: TextStyle(
                    color: ColorSelect.secondaryLabel,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _databaseService.getChats(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('Нет доступных чатов'),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final chats = snapshot.data!.docs;

          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Chat chat = chats[index].data();
              String uidOtherUser = chat.participants!
                  .where((p) => p != _authService.user!.uid)
                  .toString()
                  .replaceAll(RegExp(r'^\(|\)$'), '');
              bool isCurrentUser =
                  chat.lastMessageSenderID! == _authService.user!.uid;

              return StreamBuilder(
                stream: _databaseService.getUserProfile(uidOtherUser),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Не удалось загрузить данные'),
                    );
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    if (search.isEmpty) {
                      UserProfile? otherUser = snapshot.data!.docs.first.data();

                      return ChatItem(
                        chat: chat,
                        onTap: () async {
                          _navigationService.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(
                                  chatUser: otherUser,
                                );
                              },
                            ),
                          );
                        },
                        user: otherUser,
                        isCurrentUser: isCurrentUser,
                      );
                    } else if (snapshot.data!.docs.first
                        .data()
                        .name
                        .toString()
                        .toLowerCase()
                        .startsWith(
                          search.toLowerCase(),
                        )) {
                      UserProfile? otherUser = snapshot.data!.docs.first.data();
                      return ChatItem(
                        chat: chat,
                        onTap: () async {
                          _navigationService.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(
                                  chatUser: otherUser,
                                );
                              },
                            ),
                          );
                        },
                        user: otherUser,
                        isCurrentUser: isCurrentUser,
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                },
              );
            },
            itemCount: chats.length,
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _labelUser() {
    return const Text(
      'Все пользователи',
      style: TextStyle(
        color: ColorSelect.primaryLabel,
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _userList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Не удалось загрузить данные'),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              return UserItem(
                user: user,
                onTap: () async {
                  final chatExists = await _databaseService.checkChatExists(
                      _authService.user!.uid, user.uid!);
                  if (!chatExists) {
                    await _databaseService.createNewChat(
                      _authService.user!.uid,
                      user.uid!,
                    );
                  }
                  _navigationService.push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ChatPage(
                          chatUser: user,
                        );
                      },
                    ),
                  );
                },
              );
            },
            itemCount: users.length,
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
