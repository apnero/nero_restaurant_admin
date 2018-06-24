import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nero_restaurant_admin/model/globals.dart' as globals;

class Item {
  const Item({
    this.id,
    this.docId,
    this.name,
    this.description,
    this.heading,
    this.category,
    this.subCategory,
    this.featured,
    this.options,
    this.url,
    this.price,
    this.active,
  });

  final int id;
  final String docId;
  final String name;
  final String description;
  final String heading;
  final String category;
  final String subCategory;
  final bool featured;
  final List<dynamic> options;
  final String url;
  final double price;
  final bool active;

  factory Item.fromDocument(DocumentSnapshot document) {
    return new Item(
      id: document['id'],
      docId: document['docId'],
      name: document['name'],
      description: document['description'],
      heading: document['heading'],
      category: document['category'],
      subCategory: document['subCategory'],
      featured: document['featured'],
      options: document['options'],
      url: document['url'],
      price: document['price'],
      active: document['active'],
    );
  }
}

class ItemMethod {

  static Item getItemFromDocId(String docId) {
    Item thisItem;
    globals.allItems.forEach((item) {
      if (item.docId == docId) thisItem = item;
    });
    return thisItem;
  }
}
