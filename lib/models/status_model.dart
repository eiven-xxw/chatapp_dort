import 'package:equatable/equatable.dart';

class Status extends Equatable {
  final String uid;
  final String userName;
  final String phoneNumber;
  final List<String> photoUrl;
  final DateTime createdAt;
  final String profilePic;
  final String statusId;
  final List<String> whoCanSee;

  const Status({
    required this.uid,
    required this.userName,
    required this.phoneNumber,
    required this.photoUrl,
    required this.createdAt,
    required this.profilePic,
    required this.statusId,
    required this.whoCanSee,
  });

  Status copyWith({
    String? uid,
    String? userName,
    String? phoneNumber,
    List<String>? photoUrl,
    DateTime? createdAt,
    String? profilePic,
    String? statusId,
    List<String>? whoCanSee,
  }) {
    return Status(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      profilePic: profilePic ?? this.profilePic,
      statusId: statusId ?? this.statusId,
      whoCanSee: whoCanSee ?? this.whoCanSee,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'profilePic': profilePic,
      'statusId': statusId,
      'whoCanSee': whoCanSee,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: List<String>.from(map['photoUrl']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      profilePic: map['profilePic'] ?? '',
      statusId: map['statusId'] ?? '',
      whoCanSee: List<String>.from(map['whoCanSee']),
    );
  }

  @override
  List<Object> get props {
    return [
      uid,
      userName,
      phoneNumber,
      photoUrl,
      createdAt,
      profilePic,
      statusId,
      whoCanSee,
    ];
  }
}
