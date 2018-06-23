import 'package:nero_restaurant_admin/model/globals.dart' as globals;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  const User(
      {
        this.id,
        this.photoUrl,
        this.email,
        this.displayName,
        this.admin,
        this.pushToken,
        this.points,});

  final String email;
  final String id;
  final String photoUrl;
  final String displayName;
  final bool admin;
  final String pushToken;
  final double points;

  factory User.fromDocument(DocumentSnapshot document) {
    return new User(
      email: document['email'],
      photoUrl: document['photoUrl'],
      id: document['id'],
      displayName: document['displayName'],
      admin: document['admin'],
      pushToken: document['pushToken'],
      points: double.parse(document['points'].toString()),
    );
  }

  //for first run after creating id
  factory User.fromFirebaseUser(FirebaseUser user) {
    return new User(
      email: user.email,
      photoUrl: user.photoUrl,
      id: user.uid,
      displayName: user.displayName,
      admin: false,
      pushToken: '',
      points: 0.0,
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
