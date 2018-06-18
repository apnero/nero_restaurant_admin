import 'package:nero_restaurant_admin/model/globals.dart' as globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nero_restaurant_admin/model/item_model.dart';
import 'package:nero_restaurant_admin/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';

final refItems = Firestore.instance.collection('Items');
final refSelections = Firestore.instance.collection('Selections');
final refUsers = Firestore.instance.collection('Users');
final refOrders = Firestore.instance.collection('Complete');

Future loadItems() async {
  List<Item> itemList = [];

  await refItems.getDocuments().then((querySnapshot) => querySnapshot.documents
      .forEach((document) => itemList.add(Item.fromDocument(document))));

  globals.allItems = itemList;
  return;
}

Future loadUsers() async {
  List<User> userList = [];

  await refUsers.getDocuments().then((querySnapshot) => querySnapshot.documents
      .forEach((document) => userList.add(User.fromDocument(document))));

  globals.allUsers = userList;
  return;
}

Future saveUser(FirebaseUser firebaseUser, String pushToken) async {
  DocumentSnapshot userRecord = await refUsers.document(firebaseUser.uid).get();
  if (userRecord.data == null) {
    // no user record exists, time to create

    refUsers.document(firebaseUser.uid).setData({
      "id": firebaseUser.uid,
      "photoUrl": firebaseUser.photoUrl,
      "email": firebaseUser.email,
      "displayName": firebaseUser.displayName,
      "pushToken": pushToken,
      "admin": false,
    });
  }
}

Future<Null> completeOrder(String uidString) async {
  final DocumentReference document = refOrders.document();
  document.setData(<String, dynamic>{'uid': uidString});
}



