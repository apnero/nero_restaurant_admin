import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nero_restaurant_admin/model/selection_model.dart';
import 'package:nero_restaurant_admin/ui/home_page/selection_list_item.dart';
import 'package:nero_restaurant_admin/services/firebase_calls.dart';
final refSelections = Firestore.instance.collection('Selections');

class OrderPage extends StatelessWidget {
  OrderPage({Key key, @required this.uid}) : super(key: key);
  final String uid;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Now')),
        body: new StreamBuilder(
            stream: refSelections.where('status', isEqualTo: 'working').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Nothing Found');
              return new ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  padding: const EdgeInsets.only(bottom: 2.0, top: 8.0),
                  itemBuilder: (context, index) => new SelectionListItem(
                    context: context,
                    selection: Selection
                        .fromSelectionDoc(snapshot.data.documents[index]),
                    fromHomePage: false,
                  ));
            }),
        floatingActionButton: new FloatingActionButton.extended(
            key: new ValueKey<Key>(new Key('1')),
            tooltip: 'Done.',
            backgroundColor: Colors.blue,
            icon: new Icon(Icons.payment), //page.fabIcon,
            label: Text('Complete'),
            onPressed: () {
              return showDialog<Null>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: new Text('Complete Order'),
                    content: new SingleChildScrollView(
                      child: new ListBody(
                        children: <Widget>[
                          new Text('The Order is Finished?'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      new FlatButton(
                        child: new Text('OK'),
                        onPressed: () {
                          completeOrder(uid);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
              Navigator.pop(context);

            }));
  }
}