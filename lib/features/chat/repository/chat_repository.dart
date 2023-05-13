import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/enums/enums.dart';
import '../../../common/providers/message_reply_provider.dart';
import '../../../common/repositories/common_firebase_storage_repositories.dart';
import '../../../common/utils/utils.dart';
import '../../../models/models.dart';

final chatRepositoryProvier = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContact() {
    return firestore
        .collection('chatappUsers')
        .doc(auth.currentUser!.uid)
        .collection('chatappChats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];

      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firestore
            .collection('chatappUsers')
            .doc(chatContact.contactId)
            .get();

        var user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  Stream<List<GroupModel>> getChatGroups() {
    return firestore.collection('chatappGroup').snapshots().map((event) {
      List<GroupModel> groups = [];

      for (var document in event.docs) {
        var group = GroupModel.fromMap(document.data());
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }

      return groups;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('chatappUsers')
        .doc(auth.currentUser!.uid)
        .collection('chatappChats')
        .doc(recieverUserId)
        .collection('chatappMessages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  Stream<List<Message>> getGroupChatStream(String gropuId) {
    return firestore
        .collection('chatappGroup')
        .doc(gropuId)
        .collection('chatappChats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String revieverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await firestore.collection('chatappGroup').doc(revieverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('chatappUsers')
          .doc(revieverUserId)
          .collection('chatappChats')
          .doc(auth.currentUser!.uid)
          .set(
            recieverChatContact.toMap(),
          );

      var senderChatContact = ChatContact(
        name: recieverUserData!.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await firestore
          .collection('chatappUsers')
          .doc(auth.currentUser!.uid)
          .collection('chatappChats')
          .doc(revieverUserId)
          .set(
            senderChatContact.toMap(),
          );
    }
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String userName,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUserName,
    required String? recieverUserNamee,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      recieverId: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUserName
              : recieverUserNamee ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    if (isGroupChat) {
      //groups -> group id -> chat -> message
      await firestore
          .collection('chatappGroup')
          .doc(recieverUserId)
          .collection('chatappChats')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
      //users -> sender id ->reciever id -> messages -> message id ->
      await firestore
          .collection('chatappUsers')
          .doc(auth.currentUser!.uid)
          .collection('chatappChats')
          .doc(recieverUserId)
          .collection('chatappMessages')
          .doc(messageId)
          .set(
            message.toMap(),
          );

      //users -> sender id ->sende id -> messages -> message id ->
      await firestore
          .collection('chatappUsers')
          .doc(recieverUserId)
          .collection('chatappChats')
          .doc(auth.currentUser!.uid)
          .collection('chatappMessages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    }
  }

  void sentTextMessage({
    required BuildContext context,
    required String text,
    required String reciverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? reciverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('chatappUsers').doc(reciverUserId).get();
        reciverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();
      _saveDataToContactsSubcollection(
        senderUser,
        reciverUserData,
        text,
        timeSent,
        reciverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: reciverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        userName: senderUser.name,
        messageReply: messageReply,
        senderUserName: senderUser.name,
        recieverUserNamee: reciverUserData?.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
            file,
          );
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap = await firestore
            .collection('chatappUsers')
            .doc(recieverUserId)
            .get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Foto';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎤 Ses';
          break;
        case MessageEnum.gif:
          contactMsg = 'Gif';
          break;
        default:
          contactMsg = 'Gif';
      }

      var userDataMap =
          await firestore.collection('chatappUsers').doc(recieverUserId).get();

      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        userName: senderUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        recieverUserNamee: recieverUserData.name,
        senderUserName: senderUserData.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }

  void sendGifMessage(
      {required BuildContext context,
      required String gifUrl,
      required String reciverUserId,
      required UserModel senderUser,
      required MessageReply? messageReply,
      required bool isGroupChat}) async {
    try {
      var timeSent = DateTime.now();
      UserModel? reciverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('chatappUsers').doc(reciverUserId).get();

        reciverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();
      _saveDataToContactsSubcollection(
        senderUser,
        reciverUserData,
        'GIF',
        timeSent,
        reciverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: reciverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageType: MessageEnum.gif,
        messageId: messageId,
        userName: senderUser.name,
        messageReply: messageReply,
        recieverUserNamee: reciverUserData?.name,
        senderUserName: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('chatappUsers')
          .doc(auth.currentUser!.uid)
          .collection('chatappChats')
          .doc(recieverUserId)
          .collection('chatappMessages')
          .doc(messageId)
          .update({
        'isSeen': true,
      });

      await firestore
          .collection('chatappUsers')
          .doc(recieverUserId)
          .collection('chatappChats')
          .doc(auth.currentUser!.uid)
          .collection('chatappMessages')
          .doc(messageId)
          .update({
        'isSeen': true,
      });
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }
}
