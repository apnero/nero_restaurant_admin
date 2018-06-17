import 'package:nero_restaurant_admin/model/globals.dart' as globals;

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  const User(
      {this.id,
      this.photoUrl,
      this.email,
      this.displayName,
      this.admin,
      this.pushToken});

  final String email;
  final String id;
  final String photoUrl;
  final String displayName;
  final bool admin;
  final String pushToken;

  factory User.fromDocument(DocumentSnapshot document) {
    return new User(
      email: document['email'],
      photoUrl: document['photoUrl'],
      id: document.documentID,
      displayName: document['displayName'],
      admin: document['admin'],
      pushToken: document['pushToken'],
    );
  }
}

String getDisplayName(String id) {
  String name = '';
  globals.allUsers.forEach((user) {
    if (user.id == id) name = user.displayName;
  });
  return name;
}
