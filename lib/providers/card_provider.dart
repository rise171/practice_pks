import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _cartItems = [];
  final List<Product> _favoriteItems = [];

  List<Product> get cartItems => _cartItems;
  List<Product> get favoriteItems => _favoriteItems;

  double get totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.price);
  }

  void addToCart(Product product) {
    if (!_cartItems.contains(product)) {
      product.isTrash = true;
      _cartItems.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(Product product) {
    product.isTrash = false;
    _cartItems.remove(product);
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    product.isLiked = !product.isLiked;
    if (product.isLiked) {
      _favoriteItems.add(product);
    } else {
      _favoriteItems.remove(product);
    }
    notifyListeners();
  }

  void clearCart() {
    for (var item in _cartItems) {
      item.isTrash = false;
    }
    _cartItems.clear();
    notifyListeners();
  }
}