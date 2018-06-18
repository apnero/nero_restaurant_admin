import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nero_restaurant_admin/model/item_model.dart';
import 'package:nero_restaurant_admin/model/selection_model.dart';
import 'package:nero_restaurant_admin/model/user_model.dart';
import 'package:duration/duration.dart';

class SelectionListItem extends StatelessWidget {
  final BuildContext context;
  final Selection selection;

  SelectionListItem({@required this.context, @required this.selection});

  List<String> mapToOneList(Map<String, List<String>> map) {
    List<String> newList = [];
    map.forEach((k, v) => newList.addAll(v));
    return newList;
  }

  Color _nameToColor(String name) {
    assert(name.length > 1);
    final int hash = name.hashCode & 0xffff;
    final double hue = 360.0 * hash / (1 << 15);
    return new HSVColor.fromAHSV(1.0, hue, 0.4, 0.90).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _nameToColor(selection.uid.toString()),
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(16.0),
          topRight: const Radius.circular(16.0),
          bottomLeft: const Radius.circular(16.0),
          bottomRight: const Radius.circular(16.0),
        )),
        child: new Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: new Column(children: <Widget>[
              new Row(children: <Widget>[
                new Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new CachedNetworkImageProvider(
                                getItemFromDocId(selection.itemDocId).url)))),
                new Container(
                    height: 140.0,
                    padding: const EdgeInsets.only(left: 10.0, top: 4.0),
                    child: new Row(children: <Widget>[
                      new Padding(
                          padding: new EdgeInsets.only(left: 7.0, right: 20.0),
                          child: new Text(
                              getItemFromDocId(selection.itemDocId).name)),
                      new Column(
                        children: mapToOneList(selection.choices)
                            .map((String string) {
                          return new Wrap(
                            children: [
                              new Padding(
                                padding:
                                    new EdgeInsets.symmetric(vertical: 3.0),
                                child: new FilterChip(
                                  labelPadding:
                                      new EdgeInsets.symmetric(horizontal: 5.0),
                                  backgroundColor: Colors.lightGreenAccent,
                                  onSelected: null,
                                  selectedColor: Colors.blue,
                                  label: new Text(string),
                                  selected: true,
                                ),
                              )
                            ],
                          );
                        }).toList(),
                      )
                    ])),
              ]),
              new Row(
                  children: <Widget>[
                    new Text(getDisplayName(selection.uid)),
                    new Text("  Sent " + printDuration(
                        DateTime.now().difference(selection.date),
                        tersity: DurationTersity.hour) +
                        ' ago.'),
            ])])));
  }
}
