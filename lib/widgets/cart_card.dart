import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/theme/colors.dart';
import 'package:madshop_ui_petrova/theme/text_styles.dart';

class CardCart extends StatelessWidget {
  final String id;
  final String title;
  final String imagePath;
  final double price;
  final bool isLiked;
  final bool isTrash;
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;

  const CardCart({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.isLiked,
    required this.isTrash,
    required this.quantity,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(60),
                          color: Colors.white),
                      child: IconButton(
                        onPressed: onRemove,
                        icon: Image.asset('assets/images/Delete.png', width: 50, height: 50,),
                      ),
                    )
                )


              ],
            )

          ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.headlineProduct,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Text(
                      '${price.toStringAsFixed(0)} Р',
                      style:TextStyles.priceText
                    ),
                    IconButton(
                      onPressed: onDecrease,
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/images/Less.png', width: 24, height: 24,)
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.countText,
                          borderRadius: BorderRadius.circular(50)
                      ),

                      width: 20,
                      height: 30,
                      alignment: AlignmentGeometry.center,
                      child: Text(
                        quantity.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyles.countText
                      ),
                    ),
                    IconButton(
                      onPressed: onIncrease,
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/images/More.png', width: 24, height: 24,),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );


  }
}