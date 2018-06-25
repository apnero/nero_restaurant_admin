import 'package:nero_restaurant_admin/model/globals.dart' as globals;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:nero_restaurant_admin/model/selection_model.dart';
import 'package:nero_restaurant_admin/services/firebase_calls.dart';
import 'package:nero_restaurant_admin/ui/home_page/structure_page.dart';
import 'package:nero_restaurant_admin/ui/order_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = new Timer.periodic(new Duration(seconds: 10), (Timer timer) async {
      this.setState(() {
      });
    });
  }


  @override
  void dispose() {
    super.dispose();
//    timer.cancel();
  }

  Widget _noAdmin(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Orders'),
        ),
        body: Container(
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(globals.currentUser.displayName,
                        style: Theme.of(context).textTheme.headline),
                Text(globals.currentUser.email,
                        style: Theme.of(context).textTheme.headline),
                    Text('Please request admin access.',
                        style: Theme.of(context).textTheme.headline),
                  ],
                ))),
       );
  }



  Widget _body(BuildContext context) {
    return FutureBuilder<Map<String, List<Selection>>>(
        future: FirebaseCalls.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) {
                Map<String, List<Selection>> map = snapshot.data;
                return StructurePage(
                    context: context,
                    name: map.keys.toList()[index],
                    color: index.isOdd,
                    selections: map.values.toList()[index]);
              },
              itemCount: snapshot.data.length,
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          } else
            return new Container(
              height: 30.0,
            );
        });
  }

  @override
  Widget build(BuildContext context) {
    return globals.currentUser!= null && globals.currentUser.admin ? new Scaffold(
      appBar: new AppBar(
        title: new Text('Orders'),
      ),
      body: _body(context),
      floatingActionButton: new FloatingActionButton.extended(
          icon: new Icon(Icons.scanner),
          key: new ValueKey<Key>(new Key('1')),
          label: new Text('Scan'),
//          backgroundColor: Colors.red,
          onPressed: () =>  scan(),
//              Navigator.push(
//            context,
//            new MaterialPageRoute(
//              builder: (context) => new OrderPage(uid: 'chKH3tF4V7ZEh1Pw9qHnuljeuHt1'),
//            ),
//          )
      ),
      drawer: new Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the Drawer if there isn't enough vertical
        // space to fit everything.
        child: new ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            new DrawerHeader(
              child: new Text('Nero Digital Admin',style: Theme.of(context).textTheme.headline),
              decoration: new BoxDecoration(
//                color: Colors.black54,
              ),
            ),
            new ListTile(
              title: new Text('Send Text to Everyone',style: Theme.of(context).textTheme.headline),
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

    ):globals.currentUser!= null ? _noAdmin(context): new Container();
  }


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
//        Scaffold.of(context).showSnackBar(
//            new SnackBar(content: new Text("User Did Not Grant Permission")));
      });
    } else {
      setState(() {
//        Scaffold
//            .of(context)
//            .showSnackBar(new SnackBar(content: new Text("Unknown Error")));
      });
    }
  } on FormatException {
    setState(() {
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(content: new Text("User Hit Back Button")));
    });
  } catch (e) {
    setState(() {
//      Scaffold
//          .of(context)
//          .showSnackBar(new SnackBar(content: new Text("Unknown Error")));
    });
  }
}
}
