import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/screens/cart_screen.dart';
import 'favourite_screen.dart';
import 'package:madshop_ui_petrova/models/product.dart';
import '../widgets/card_product.dart';
import '../widgets/cart_card.dart';
import '../theme/text_styles.dart';

List<Product> globalProducts = [
  Product(id: '1',
      title: 'Туфли с цветочным узором',
      imagePath: 'assets/images/shoes_1.jpg',
      isLiked: false,
      isTrash: false,
      price: 1900),
  Product(id: '2',
      title: 'Футболка винтажная, джинсовый стиль',
      imagePath: 'assets/images/shirt_3.jpg',
      isLiked: false,
      isTrash: false,
      price: 1000),
  Product(id: '3',
      title: 'Футболка винтажная',
      imagePath: 'assets/images/shirt_4.jpg',
      isLiked: false,
      isTrash: false,
      price: 900),
  Product(id: '4',
      title: 'Рубашка молодежная',
      imagePath: 'assets/images/shirt_1.jpg',
      isLiked: false,
      isTrash: false,
      price: 1700),
  Product(id: '5', title: 'Рубашка', imagePath: 'assets/images/shirt_2.jpg', isLiked: false, isTrash: false, price: 2300),
  Product(id: '6', title: 'Ботинки', imagePath: 'assets/images/shoes_2.jpg', isLiked: false, isTrash: false, price: 1000),
  Product(id: '7', title: 'Шарф теплый, зимний', imagePath: 'assets/images/scarf.jpg', isLiked: false, isTrash: false, price: 500),
  Product(id: '8', title: 'Штаны в китайском стиле', imagePath: 'assets/images/pants_1.jpg', isLiked: false, isTrash: false, price: 700),
  Product(id: '9', title: 'Штаны', imagePath: 'assets/images/pants_2.jpg', isLiked: false, isTrash: false, price: 900),
  Product(id: '10', title: 'Джинсовка', imagePath: 'assets/images/jacket.jpg', isLiked: false, isTrash: false, price: 3000),
];

List<Product> favouriteProducts = [];

List<Product> cartProducts = [];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = globalProducts;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = globalProducts;
      } else {
        _filteredProducts = globalProducts.where((product) {
          return product.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredProducts = globalProducts;
    });
  }

  void _toggleFavourite(int index) {
    setState(() {
      final product = _filteredProducts[index];
      product.isLiked = !product.isLiked;

      if (product.isLiked) {
        favouriteProducts.add(product);
      } else {
        favouriteProducts.removeWhere((p) => p.id == product.id);
      }
    });
  }

  void _toggleCart(int index) {
    setState(() {
      final product = _filteredProducts[index];
      product.isTrash = !product.isTrash;

      if (product.isTrash) {
        cartProducts.add(product.copyWith(quantity: 1));
      } else {
        cartProducts.removeWhere((p) => p.id == product.id);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CartScreen(),
          ),
        );
        break;
    }
  }

  int get _totalCartItems {
    return cartProducts.fold(0, (sum, product) => sum + product.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Row(
            children: [
              const Text('Shop', style: TextStyles.headlinePasswordAndPage,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 19),
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: _clearSearch,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 20),
        child: _filteredProducts.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Товары не найдены',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
            ],
          ),
        )
            : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 0,
            childAspectRatio: 0.62,
          ),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return GestureDetector(
              child: CardProduct(
                id: product.id,
                title: product.title,
                price: product.price.toDouble(),
                imagePath: product.imagePath,
                isLiked: product.isLiked,
                isTrash: product.isTrash,
                onLikePressed: () => _toggleFavourite(index),
                onCartPressed: () => _toggleCart(index),
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
            icon: Image.asset('assets/images/Home.png', color: Colors.black,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, color: Colors.blue,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Cart_white.png', color: Colors.blue,),
            label: '',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}