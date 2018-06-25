import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_ui/flutter_firebase_ui.dart';
import 'package:nero_restaurant_admin/ui/home_page/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nero_restaurant_admin/services/firebase_calls.dart';
import 'package:nero_restaurant_admin/ui/send_text.dart';


void main() => runApp(new NeroRestaurant());

class NeroRestaurant extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Nero Digital',
      theme: ThemeData.dark(),
      home: new LoginPage(title: 'Nero Digital'),
      routes: <String, WidgetBuilder>{
        // Set named routes
        "/send_text": (BuildContext context) => new SendText(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<FirebaseUser> _listener;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  FirebaseUser _currentUser;
  String pushToken = '';

  @override
  void initState() {
    super.initState();
    FirebaseCalls.loadItems().then((status) => setState(() {}));
    FirebaseCalls.loadUsers().then((status) => setState(() {}));

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        _onMessageDialog(context, message);
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print(token);
      pushToken = token;
    });
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  _onMessageDialog(BuildContext context,Map<String, dynamic> message) {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(message['title']),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(message['body']),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.pop(context);

              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return new SignInScreen(
        title: "Nero Restaurant",
        header: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: new Image.asset(
              'assets/images/ndm_logo.png',
              width: 245.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
        providers: [
          ProvidersTypes.facebook,
          ProvidersTypes.google,
          ProvidersTypes.email
        ],
      );
    } else {
      return new HomePage();
    }
  }

  void _checkCurrentUser() async {
    try {
      _currentUser = await _auth.currentUser();
      _currentUser?.getIdToken(refresh: true);

      if (_currentUser != null) FirebaseCalls.saveUser(_currentUser, pushToken);

      _listener = _auth.onAuthStateChanged.listen((FirebaseUser user) {
        setState(() {
          _currentUser = user;
          if (_currentUser != null)
            FirebaseCalls.saveUser(_currentUser, pushToken);
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

