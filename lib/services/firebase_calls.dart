import 'package:nero_restaurant_admin/model/globals.dart' as globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nero_restaurant_admin/model/item_model.dart';
import 'package:nero_restaurant_admin/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';
import 'package:nero_restaurant_admin/model/selection_model.dart';

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
  DocumentSnapshot userRecord;
  if (firebaseUser != null) {
    userRecord = await refUsers.document(firebaseUser.uid).get();

    if (userRecord.data == null) {
      // no user record exists, time to create

      await refUsers.document(firebaseUser.uid).setData({
        "id": firebaseUser.uid,
        "photoUrl": firebaseUser.photoUrl,
        "email": firebaseUser.email,
        "displayName": firebaseUser.displayName,
        "pushToken": pushToken,
        "admin": false,
        "points": 0.0,
      });

      globals.currentUser = User.fromFirebaseUser(firebaseUser);
    } else
      globals.currentUser = User.fromDocument(userRecord);
  }
}

Future<Null> completeOrder(String uid, List<Selection> selectionList, double manualPrice) async {
  double cost = 0.0;
  Map<String, dynamic> map = new Map();
  map.addAll({'status': 'complete'});
  Firestore.instance.runTransaction((transaction) async {
    selectionList.forEach((selection) {
      refSelections.document(selection.selectionId).updateData(map);
      cost += getItemFromDocId(selection.itemDocId).price;
    });


    map.addAll({'uid': uid});
    if(cost != 0.0)
      map.addAll({'cost': cost});
    else map.addAll({'cost':manualPrice});
    final DocumentReference document = refOrders.document();
    document.setData(map);
  });
}

Future<Map<String, List<Selection>>> getOrders() async {
  Map<String, List<Selection>> selectionMap = new Map();
  List<Selection> selectionList = new List();
  Set setOfUids = new Set();

  await refSelections.where('status', isEqualTo: 'working').getDocuments().then(
      (querySnapshot) => querySnapshot.documents.forEach((document) =>
          selectionList.add(Selection.fromSelectionDoc(document))));

  selectionList.forEach((selection) => setOfUids.add(selection.uid));

  setOfUids.forEach((uid) {
    List<Selection> list = [];
    selectionList.forEach((selection) {
      if (uid == selection.uid) list.add(selection);
    });
    selectionMap.addAll({getDisplayName(uid): list});
  });
  globals.currentOrders = selectionMap;
  return selectionMap;
}
