import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendText extends StatefulWidget {
  @override
  SendTextState createState() => new SendTextState();
}

class SendTextState extends State<SendText> {

  final refNotifications = Firestore.instance.collection('Notifications');
  final titleController = new TextEditingController();
  final messageController = new TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<Null> sendNotification() async {
    final DocumentReference document = refNotifications.document();
    document.setData(<String, dynamic>{
      'title': titleController.text,
      'message': messageController.text,
      'time': new DateTime.now().millisecondsSinceEpoch,
    });
    messageController.clear();
    titleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const SliverAppBar(
        pinned: true,
        expandedHeight: 80.0,
        flexibleSpace: const FlexibleSpaceBar(
          title: const Text('Send Notification'),
        ),
      ),
      new SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
          sliver: SliverList(
              delegate: new SliverChildListDelegate(
            <Widget>[
              new Center(
                  child: new Container(
                      width: 400.0,
                      child: new Column(children: <Widget>[
                        const SizedBox(height: 15.0),
                        new TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Title',
                              suffixStyle:
                                  const TextStyle(color: Colors.green)),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20.0),
                        new TextFormField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'What do you want to say?',
                            labelText: 'Message',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 80.0),
                        new Center(
                          child: new RaisedButton(
                              child: const Text('SUBMIT'),
                              onPressed: () {
                                sendNotification();
                                Navigator.pop(context);
                                showModalBottomSheet<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return new Container(
                                          child: new Padding(
                                              padding:
                                                  const EdgeInsets.all(32.0),
                                              child: new Text(
                                                  'The Notification has been sent.',
                                                  textAlign: TextAlign.center,
                                                  style: new TextStyle(
                                                      color: Theme
                                                          .of(context)
                                                          .accentColor,
                                                      fontSize: 24.0))));
                                    });
                              }),
                        ),
                      ])))
            ],
          )))
    ]));
  }
}
