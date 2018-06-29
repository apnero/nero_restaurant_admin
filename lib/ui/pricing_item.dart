import 'package:flutter/material.dart';
import 'package:nero_restaurant_admin/model/selection_price_model.dart';
class PricingItem extends StatefulWidget {
  final BuildContext context;
  final List<SelectionPrice> selectionPriceList;

  PricingItem({@required this.context, @required this.selectionPriceList});
  @override
  _PricingItem createState() => new _PricingItem();
}

class _PricingItem extends State<PricingItem> {
  double price = 0.0;

  @override
  void initState() {
    _calcPrice();
    super.initState();
  }

  double _calcPrice() {
    widget.selectionPriceList
        .forEach((selectionPrice) => price += selectionPrice.price);
    return price;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Divider(color: Colors.blue),
            Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Tax 6.35\%',
                        style: Theme
                            .of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.black),
                      ),
                      Text(
                        '\$' + (price * 0.0635).toStringAsFixed(2),
                        style: Theme
                            .of(context)
                            .textTheme
                            .subhead
                            .copyWith(color: Colors.black),
                      ),
                      Divider(color: Colors.blue),
                    ])),
            Divider(color: Colors.blue),
            Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Total',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.black),
                      ),
                      Text(
                        '\$' + (price * 1.0635).toStringAsFixed(2),
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.black),
                      ),
                      Divider(color: Colors.blue),
                    ])),
          ],
        ));
  }
}
