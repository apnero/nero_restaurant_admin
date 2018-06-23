library nero_restaurant.globals;

import 'package:nero_restaurant_admin/model/item_model.dart';
import 'package:nero_restaurant_admin/model/user_model.dart';
import 'package:nero_restaurant_admin/model/selection_model.dart';

List<Item> allItems;
List<User> allUsers;
User currentUser;
List<Selection> currentCart = [];
Map<String, List<Selection>> currentOrders = new Map();