class Product {
  final String id;
  final String title;
  final String imagePath;
  bool isLiked;
  bool isTrash;
  final int price;
  int quantity;

  Product({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.isLiked,
    required this.isTrash,
    required this.price,
    this.quantity = 1,
  });

  // Метод для копирования объекта с измененными полями
  Product copyWith({
    String? id,
    String? title,
    String? imagePath,
    bool? isLiked,
    bool? isTrash,
    int? price,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      isLiked: isLiked ?? this.isLiked,
      isTrash: isTrash ?? this.isTrash,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}