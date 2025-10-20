import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/screens/cart_screen.dart';
import 'package:madshop_ui_petrova/screens/home_screen.dart';
import 'package:madshop_ui_petrova/models/product.dart';
import 'package:madshop_ui_petrova/theme/text_styles.dart';
import '../widgets/card_product.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  int _currentIndex = 1;

  void _removeFromFavourite(int index) {
    setState(() {
      final product = favouriteProducts[index];
      product.isLiked = false;

      favouriteProducts.removeAt(index);

      final globalIndex = globalProducts.indexWhere((p) => p.id == product.id);
      if (globalIndex != -1) {
        globalProducts[globalIndex].isLiked = false;
      }
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
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CartScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Text('Favourites', style: TextStyles.headlinePasswordAndPage,),
        ),
      ),
      body: favouriteProducts.isEmpty
          ? const Center(
        child: Text(
          'Нет избранных товаров',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.only(left: 15, right: 20),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 0,
            childAspectRatio: 0.62,
          ),
          itemCount: favouriteProducts.length,
          itemBuilder: (context, index) {
            final product = favouriteProducts[index];
            return GestureDetector(
              child: CardProduct(
                id: product.id,
                title: product.title,
                price: product.price.toDouble(),
                imagePath: product.imagePath,
                isLiked: product.isLiked,
                isTrash: product.isTrash,
                onLikePressed: () => _removeFromFavourite(index),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Home_unselect.png',),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/heart_select.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Cart_white.png', color: Colors.blue,),
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