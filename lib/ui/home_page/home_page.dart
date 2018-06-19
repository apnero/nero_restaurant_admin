import 'package:nero_restaurant_admin/model/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:nero_restaurant_admin/ui/order_page.dart';
import 'package:flutter/services.dart';
import 'package:nero_restaurant_admin/ui/home_page/selection_list_item.dart';
import 'package:nero_restaurant_admin/model/selection_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final refSelections = Firestore.instance.collection('Selections');

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String barcode;
  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new Text("Nero Digital Admin"),
          elevation: 4.0,
        ),
        body: new StreamBuilder(
            stream: refSelections
                .where('status', isEqualTo: 'working')
                .orderBy('date', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data.documents.length == 0)
                return new Center(
                    child: Image.asset(
                  'assets/images/empty.png',
                  width: 265.0,
                  fit: BoxFit.fitHeight,
                ));
              return globals.allItems != null && globals.allUsers != null
                  ? new ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      padding: const EdgeInsets.only(bottom: 2.0, top: 8.0),
                      itemBuilder: (context, index) => new SelectionListItem(
                            context: context,
                            selection: Selection.fromSelectionDoc(
                                snapshot.data.documents[index]),
                            fromHomePage: true,
                          ))
                  : new Container();
            }),
        floatingActionButton: new FloatingActionButton.extended(
            icon: new Icon(Icons.scanner),
            key: new ValueKey<Key>(new Key('1')),
            label: new Text('Scan'),
            backgroundColor: Colors.blue,
            onPressed: () => scan()),
        drawer: new Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the Drawer if there isn't enough vertical
          // space to fit everything.
          child: new ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              new DrawerHeader(
                child: new Text('Nero Digital Admin'),
                decoration: new BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              new ListTile(
                title: new Text('Send Text to Everyone'),
                onTap: () {
                  // Update the state of the app
                  Navigator.pop(context); // ...
                  Navigator.of(context).pushNamed('/send_text');
                  // Then close the drawer
                },
              ),
            ],
          ),
        ),
      );

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new OrderPage(uid: barcode),
          ),
        );
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          Scaffold.of(context).showSnackBar(
              new SnackBar(content: new Text("User Did Not Grant Permission")));
        });
      } else {
        setState(() {
          Scaffold
              .of(context)
              .showSnackBar(new SnackBar(content: new Text("Unknown Error")));
        });
      }
    } on FormatException {
      setState(() {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("User Hit Back Button")));
      });
    } catch (e) {
      setState(() {
        Scaffold
            .of(context)
            .showSnackBar(new SnackBar(content: new Text("Unknown Error")));
      });
    }
  }
}
