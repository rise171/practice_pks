import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/screens/create_screen.dart';
import 'package:madshop_ui_petrova/screens/login_screen.dart';
import 'package:madshop_ui_petrova/theme/colors.dart';
import 'providers/card_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.light(
            background: AppColors.background,
          )
        ),
        title: 'Shop',
        debugShowCheckedModeBanner: false,
        home: const CreateAccountScreen( ),
      ),
    );
  }
}