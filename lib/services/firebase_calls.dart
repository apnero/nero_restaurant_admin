import 'package:nero_restaurant_admin/model/globals.dart' as globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nero_restaurant_admin/model/item_model.dart';
import 'package:nero_restaurant_admin/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:async';
import 'package:nero_restaurant_admin/model/selection_model.dart';

class FirebaseCalls {
  static Future loadItems() async {
    final refItems = Firestore.instance.collection('Items');
    List<Item> itemList = [];

    await refItems.getDocuments().then((querySnapshot) => querySnapshot
        .documents
        .forEach((document) => itemList.add(Item.fromDocument(document))));

    globals.allItems = itemList;
    return;
  }

  static Future loadUsers() async {
    final refUsers = Firestore.instance.collection('Users');
    List<User> userList = [];

    await refUsers.getDocuments().then((querySnapshot) => querySnapshot
        .documents
        .forEach((document) => userList.add(User.fromDocument(document))));

    globals.allUsers = userList;
    return;
  }

  static Future saveUser(FirebaseUser firebaseUser, String pushToken) async {
    final refUsers = Firestore.instance.collection('Users');
    DocumentSnapshot userRecord;
    if (firebaseUser != null) {
      try {
        userRecord = await refUsers.document(firebaseUser.uid).get();

        if (userRecord.data == null) {
          // no user record exists, time to create

          await refUsers.document(firebaseUser.uid).setData({
            "id": firebaseUser.uid,
            "photoUrl":
                firebaseUser.photoUrl != null ? firebaseUser.photoUrl : '',
            "email": firebaseUser.email != null ? firebaseUser.email : '',
            "displayName": firebaseUser.displayName != null
                ? firebaseUser.displayName
                : '',
            "pushToken": pushToken,
            "admin": false,
            "points": 0.0,
          });

          globals.currentUser = User.fromFirebaseUser(firebaseUser, pushToken);
        } else
          globals.currentUser = User.fromDocument(userRecord);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  static Future<Null> completeOrder(
      String uid, List<Selection> selectionList, double manualPrice) async {
    final refSelections = Firestore.instance.collection('Selections');
    final refOrders = Firestore.instance.collection('Complete');

    double cost = 0.0;
    Map<String, dynamic> map = new Map();
    map.addAll({'status': 'complete'});
    Firestore.instance.runTransaction((transaction) async {
      selectionList.forEach((selection) {
        refSelections.document(selection.selectionId).updateData(map);
        cost += Item.getItemFromDocId(selection.itemDocId).price;
      });

      map.addAll({'uid': uid});
      if (cost != 0.0)
        map.addAll({'cost': cost});
      else
        map.addAll({'cost': manualPrice});
      final DocumentReference document = refOrders.document();
      document.setData(map);
    });
  }

  static Future<Map<String, List<Selection>>> getOrders() async {
    final refSelections = Firestore.instance.collection('Selections');
    Map<String, List<Selection>> selectionMap = new Map();
    List<Selection> selectionList = new List();
    Set setOfUids = new Set();

    await refSelections
        .where('status', isEqualTo: 'working')
        .getDocuments()
        .then((querySnapshot) => querySnapshot.documents.forEach((document) =>
            selectionList.add(Selection.fromSelectionDoc(document))));

    selectionList.forEach((selection) => setOfUids.add(selection.uid));

    setOfUids.forEach((uid) {
      List<Selection> list = [];
      selectionList.forEach((selection) {
        if (uid == selection.uid) list.add(selection);
      });
      selectionMap.addAll({User.getDisplayName(uid): list});
    });
    globals.currentOrders = selectionMap;
    return selectionMap;
  }
}
