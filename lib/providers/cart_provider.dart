import 'package:flutter/foundation.dart';
import '../models/gear_item.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  List<CartItem> get itemsList => _items.values.toList();

  int get totalItemCount {
    int total = 0;
    _items.forEach((_, item) => total += item.quantity);
    return total;
  }

  /// Total tarif sewa per 1 hari untuk seluruh item dalam keranjang
  int get subtotalPerDay {
    int total = 0;
    _items.forEach((_, item) => total += item.subtotal);
    return total;
  }

  /// Total biaya sewa dikalikan jumlah hari
  int calculateGrandTotal(int days) {
    return subtotalPerDay * days;
  }

  int getItemQuantity(String gearId) {
    return _items[gearId]?.quantity ?? 0;
  }

  void addItem(GearItem gear) {
    if (_items.containsKey(gear.id)) {
      _items[gear.id]!.quantity += 1;
    } else {
      _items[gear.id] = CartItem(gear: gear, quantity: 1);
    }
    notifyListeners();
  }

  void decrementItem(String gearId) {
    if (!_items.containsKey(gearId)) return;
    if (_items[gearId]!.quantity > 1) {
      _items[gearId]!.quantity -= 1;
    } else {
      _items.remove(gearId);
    }
    notifyListeners();
  }

  void removeItem(String gearId) {
    _items.remove(gearId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
