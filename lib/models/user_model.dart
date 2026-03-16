import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    this.lastSeen,
    this.isOnline = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: map['uid'] ?? uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastSeen: map['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen'])
          : null,
      isOnline: map['isOnline'] ?? false,
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, photoUrl: $photoUrl, isOnline: $isOnline)';
  }
}
