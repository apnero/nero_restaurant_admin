import 'package:flutter/material.dart';
import 'package:nero_restaurant_admin/model/selection_model.dart';
import 'package:nero_restaurant_admin/model/item_model.dart';

class OrderStructurePage extends StatelessWidget {
  OrderStructurePage({Key key, this.context, this.name, this.selections})
      : super(key: key);
  final BuildContext context;
  final String name;
  final List<Selection> selections;



  List<String> _getList(Iterable<List<String>> list) {
    List<String> outputList = [];

    list.forEach((l) => outputList.addAll(l));

    return outputList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          border: const Border(
            top: const BorderSide(width: 1.0, color: const Color(0xFFFFFFFFFF)),
            left:
            const BorderSide(width: 1.0, color: const Color(0xFFFFFFFFFF)),
            right:
            const BorderSide(width: 1.0, color: const Color(0xFFFFFFFFFF)),
            bottom:
            const BorderSide(width: 2.0, color: const Color(0xFFFFFFFFFF)),
          ),
        ),
        padding: EdgeInsets.all(30.0),
        child: new Container(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Text(
                    name,
                    style: Theme.of(context).textTheme.headline,
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: selections.map<Widget>((Selection selection) {
                      return new Container(
                          decoration: const BoxDecoration(
                            border: const Border(
                                bottom: const BorderSide(
                                  width: 1.0,
                                  color:
                                  Colors.white30, //const Color(0xFFFF000000)),
                                ),
                                top: const BorderSide(
                                  width: 1.0,
                                  color:
                                  Colors.white30, //const Color(0xFFFF000000)),
                                )),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(children: <Widget>[
                            new Padding(
                                padding: EdgeInsets.only(
                                  right: 20.0,
                                ),
                                child: new Text(
                                   Item.getItemFromDocId(selection.itemDocId).name, style: Theme.of(context).textTheme.title,)),
                            Expanded(child:
                            new Wrap(

                              spacing: 3.0,
                              runSpacing: 2.0,
                              children: _getList(selection.choices.values)
                                  .map<Widget>((String choice) {
                                return new ChoiceChip(
                                  backgroundColor: Colors.blue,
                                  label: new Text(choice),
                                  selected: false,
                                  onSelected: (bool selected) => null,
                                );
                              }).toList(),
                            ),
                            )]));
                    }).toList(),
                  ),
                ],
              )),


        );
  }
}
