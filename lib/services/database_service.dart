import 'package:chat_app_test/models/chat.dart';
import 'package:chat_app_test/models/message.dart';
import 'package:chat_app_test/models/user_profile.dart';
import 'package:chat_app_test/services/auth_service.dart';
import 'package:chat_app_test/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;
  late AuthService _authService;
  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCOllectionReferences();
  }
  void _setupCOllectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) => UserProfile.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatsCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshots, _) => Chat.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (chat, _) => chat.toJson(),
            );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfile(String uid) {
    return _usersCollection?.where("uid", isEqualTo: uid).snapshots()
        as Stream<QuerySnapshot<UserProfile>>;
  }

  Stream<QuerySnapshot<Chat>> getChats() {
    return _chatsCollection!
        .orderBy("lastMessageDate", descending: true)
        .where("participants", arrayContains: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<Chat>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
      lastMessage: '',
      lastMessageDate: Timestamp.fromDate(DateTime.now()),
      lastMessageSenderID: '',
    );
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    await docRef.update(
      {
        'messages': FieldValue.arrayUnion(
          [
            message.toJson(),
          ],
        )
      },
    );
  }

  Future<void> updateChatData(
    String uid1,
    String uid2,
    String lastMessage,
    String lastMessageSenderID,
    Timestamp lastMessageDate,
  ) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    await docRef.update(
      {
        'lastMessage': lastMessage,
        'lastMessageSenderID': lastMessageSenderID,
        'lastMessageDate': lastMessageDate,
      },
    );
  }

  Stream getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection?.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
