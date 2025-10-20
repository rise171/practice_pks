import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/theme/text_styles.dart';

class CardProduct extends StatelessWidget {
  final String id;
  final String title;
  final String imagePath;
  final double price;
  final bool isLiked;
  final bool isTrash;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCartPressed;

  const CardProduct({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.isLiked,
    required this.isTrash,
    this.onLikePressed,
    this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            ),
            child:
            Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                      bottomLeft: Radius.circular(7),
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: 0,
                bottom: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onLikePressed,
                        icon: Icon(
                          Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: onCartPressed,
                        icon: Image.asset(
                          isTrash ? 'assets/images/Cart_black.png' : 'assets/images/Cart_white.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.headlineProduct,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 1),

                Text(
                  '$price Р',
                  style: TextStyles.priceText,
                ),
              ],
            ),
          ),
        ],
      );


  }
}