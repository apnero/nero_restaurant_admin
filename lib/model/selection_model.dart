import 'package:cloud_firestore/cloud_firestore.dart';

enum Status { open, working, complete }

class Selection {
  String uid;
  String itemDocId;
  String selectionId;
  Map<String, List<String>> choices;
  bool favorite;
  bool inCart;
  Status status;
  String specialInstructions;
  DateTime date;

  Selection.fromItemDoc(DocumentSnapshot document) {
    this.uid = '';
    this.itemDocId = document['docId'];
    this.selectionId = '';
    this.choices = new Map<String, List<String>>();
    this.favorite = false;
    this.inCart = false;
    this.status = Status.open;
    this.specialInstructions = '';
    this.date = new DateTime.now();
  }

  Selection.fromSelectionDoc(DocumentSnapshot document) {
    this.uid = document['uid'];
    this.itemDocId = document['itemDocId'];
    this.selectionId = document['selectionId'];
    this.choices = dynamicToString(document['choices']);
    this.favorite = document['favorite'];
    this.inCart = document['inCart'];
    this.status = stringToEnum(document['status']);
    this.specialInstructions = document['specialInstructions'];
    this.date = document['date'];
  }


  Map<String, dynamic> toMap() => {
        'uid': this.uid,
        'itemDocId': this.itemDocId,
        'selectionId': this.selectionId,
        'choices': this.choices,
        'favorite': this.favorite,
        'inCart': this.inCart,
        'status': enumToString(this.status),
        'specialInstructions': this.specialInstructions,
        'date': this.date,
      };

  String enumToString(Status status) {
    String string = '';
    switch (status) {
      case Status.open:
        return 'open';
        break;
      case Status.working:
        return 'working';
        break;
      case Status.complete:
        return 'complete';
        break;
      default:
        return string;
    }
  }

  Status stringToEnum(String stringStatus) {

    switch (stringStatus) {
      case 'open':
        return Status.open;
        break;
      case 'working':
        return Status.working;
        break;
      case 'complete':
        return Status.complete;
        break;
      default:
        return Status.open;
    }
  }

  Map<String,List<String>> dynamicToString(Map<dynamic,dynamic> map){

    Map<String, List<String>> stringMap = new Map();
    List<dynamic> list;

    map.forEach((k, v) {
      list = v.cast<String>().toList();
      stringMap.addAll({k: list});
    });

    return stringMap;
  }
}
