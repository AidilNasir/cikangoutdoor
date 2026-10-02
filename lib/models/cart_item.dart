import 'gear_item.dart';

class CartItem {
  final GearItem gear;
  int quantity;

  CartItem({
    required this.gear,
    this.quantity = 1,
  });

  int get subtotal => gear.pricePerDay * quantity;
}
