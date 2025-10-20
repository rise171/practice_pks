import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/screens/home_screen.dart';
import 'package:madshop_ui_petrova/theme/colors.dart';
import 'favourite_screen.dart';
import 'package:madshop_ui_petrova/models/product.dart';
import '../widgets/card_product.dart';
import '../widgets/cart_card.dart';
import 'package:madshop_ui_petrova/theme/text_styles.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 2;

  int get _totalCartItems {
    return cartProducts.fold(0, (sum, product) => sum + product.quantity);
  }

  void _increaseQuantity(int index) {
    setState(() {
      final product = cartProducts[index];
      final newQuantity = product.quantity + 1;
      cartProducts[index] = product.copyWith(quantity: newQuantity);
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      final product = cartProducts[index];
      final currentQuantity = product.quantity;
      if (currentQuantity > 1) {
        cartProducts[index] = product.copyWith(quantity: currentQuantity - 1);
      } else {
        _removeFromCart(index);
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      final product = cartProducts[index];

      final globalIndex = globalProducts.indexWhere((p) => p.id == product.id);
      if (globalIndex != -1) {
        globalProducts[globalIndex].isTrash = false;
      }

      cartProducts.removeAt(index);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavouriteScreen(),
          ),
        );
        break;
      case 2:
        break;
    }
  }

  double get _totalPrice {
    return cartProducts.fold(0, (sum, product) {
      return sum + (product.price * product.quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Row(
            children: [
              const Text('Cart', style: TextStyles.headlinePasswordAndPage,),
              const SizedBox(width: 7),
              if (cartProducts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.countText,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '$_totalCartItems',
                    style: TextStyles.priceText
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 20, bottom: 80),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartProducts.length,
              itemBuilder: (context, index) {
                final product = cartProducts[index];
                return CardCart(
                  id: product.id,
                  title: product.title,
                  price: product.price.toDouble(),
                  imagePath: product.imagePath,
                  isLiked: product.isLiked,
                  isTrash: product.isTrash,
                  quantity: product.quantity,
                  onIncrease: () => _increaseQuantity(index),
                  onDecrease: () => _decreaseQuantity(index),
                  onRemove: () => _removeFromCart(index),
                );
              },
            ),
          ),

          if (cartProducts.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                      Text(
                        'Total',
                        style: TextStyles.priceText,
                      ),
                      SizedBox(width: 6,),
                      Text(
                        '${_totalPrice.toStringAsFixed(0)} Р',
                        style: TextStyles.priceText,
                      ),
                    ],),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyles.buttonCheckText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Home_unselect.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Cart_unselect.png'),
            label: '',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blue,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}