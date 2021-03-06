import 'package:nero_restaurant_admin/model/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nero_restaurant_admin/model/user_model.dart';
import 'package:nero_restaurant_admin/services/firebase_calls.dart';
import 'package:nero_restaurant_admin/ui/order_structure_page.dart';
import 'package:nero_restaurant_admin/ui/pricing_item.dart';
import 'package:nero_restaurant_admin/model/selection_price_model.dart';
import 'package:nero_restaurant_admin/model/selection_model.dart';
import 'package:nero_restaurant_admin/model/item_model.dart';

class OrderPage extends StatefulWidget {
  OrderPage({Key key, this.uid}) : super(key: key);
  final String uid;

  @override
  OrderPageState createState() => new OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  String thisUserName = '';
  final _controller = new TextEditingController();

  @override
  void initState() {
    thisUserName = User.getDisplayName(widget.uid);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _controller.dispose();
    super.dispose();
  }

  _confirmationDialog(BuildContext context) {
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
                FirebaseCalls.completeOrder(
                    widget.uid, globals.currentOrders[thisUserName], 0.0);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  _noPreorderDialog(BuildContext context) {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Enter cost of purchase:'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: _controller,
                  decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '\$',
                      suffixStyle: const TextStyle(color: Colors.green)),
                  maxLines: 1,
                  inputFormatters: [
//                    WhitelistingTextInputFormatter(
//                        new RegExp('^[0-9]+(\\.[0-9]{1,2})?\$')),
                  ],
                ),
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
                FirebaseCalls.completeOrder(
                    widget.uid, [], double.parse(_controller.text));
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _noOrder(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Orders'),
        ),
        body: Container(
            child: Center(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(thisUserName, style: Theme.of(context).textTheme.headline),
            Text('There are no pending Orders',
                style: Theme.of(context).textTheme.headline),
          ],
        ))),
        floatingActionButton: new FloatingActionButton.extended(
            key: new ValueKey<Key>(new Key('1')),
            tooltip: 'Done.',
            backgroundColor: Colors.red,
            icon: new Icon(Icons.payment), //page.fabIcon,
            label: Text('Manually Enter Price'),
            onPressed: () {
              _noPreorderDialog(context);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return globals.currentOrders.containsKey(thisUserName)
        ? new Scaffold(
            appBar: new AppBar(
              title: new Text('Orders'),
            ),
            body: SingleChildScrollView(child: Column(children: <Widget>[
              OrderStructurePage(
                  context: context,
                  name: thisUserName,
                  selections: globals.currentOrders[thisUserName]),
              PricingItem(context: context, selectionPriceList: globals.currentOrders[thisUserName].map<SelectionPrice>((Selection selection) {
                return SelectionPrice.from(selection.selectionId, Item.getItemFromDocId(selection.itemDocId).price);},
              ).toList()),
              SizedBox(height: 80.0,),
            ])),
            floatingActionButton: new FloatingActionButton.extended(
                key: new ValueKey<Key>(new Key('1')),
                tooltip: 'Done.',
//                backgroundColor: Colors.red,
                icon: new Icon(Icons.payment), //page.fabIcon,
                label: Text('Complete'),
                onPressed: () {
                  _confirmationDialog(context);
                }))
        : _noOrder(context);
  }
}
