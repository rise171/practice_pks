import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/theme/colors.dart';

class TextStyles {
  // Заголовки
  static const TextStyle headlineCreateAc = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway'
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    fontFamily: 'Nunito Sans',
    color: AppColors.button_text
  );

  static const TextStyle buttonCheckText = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w300,
      fontFamily: 'Nunito Sans',
      color: AppColors.button_text
  );

  static const TextStyle headlineLogin = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.bold,
    fontFamily: 'Raleway',
    letterSpacing: -0.52
  );

  static const TextStyle underText = TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w300,
      fontFamily: 'Nunito Sans',
    color: AppColors.black,
  );

  static const TextStyle underTextLight = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w300,
    fontFamily: 'Nunito Sans',
    color: AppColors.background,
  );

  static const TextStyle headlinePasswordAndPage = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: 'Raleway',
      letterSpacing: -0.28
  );

  static const TextStyle headlineProduct = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Nunito Sans',
  );

  static const TextStyle priceText = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      fontFamily: 'Raleway',
      letterSpacing: -0.17
  );

  static const TextStyle countText = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontFamily: 'Raleway',
      letterSpacing: -0.16
  );



}