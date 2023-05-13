import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/utils.dart';
import '../../../models/call_model.dart';

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => firestore
      .collection('chatappCall')
      .doc(auth.currentUser!.uid)
      .snapshots();

  void makeCall(
    CallModel senderCallData,
    BuildContext context,
    CallModel recieverCallData,
  ) async {
    try {
      await firestore
          .collection('chatappCall')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      await firestore
          .collection('chatappCall')
          .doc(senderCallData.receiverId)
          .set(senderCallData.toMap());
    } catch (e) {
      showSnackBar(
        context: context,
        content: e.toString(),
      );
    }
  }
}
