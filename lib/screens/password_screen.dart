import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/screens/home_screen.dart';
import 'package:madshop_ui_petrova/screens/login_screen.dart';
import 'package:madshop_ui_petrova/theme/colors.dart';
import 'package:madshop_ui_petrova/theme/text_styles.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset('assets/images/Bubbles2.png'),
          Padding(padding: EdgeInsetsGeometry.all(20),
          child: Column(
            children: [
              SizedBox(height: 240,),
              Text('Hello!', style: TextStyles.headlinePasswordAndPage,),
              SizedBox(height: 30,),
              Text('Type your password', style: TextStyles.underText),
              SizedBox(height: 126,),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background_text_field,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                    borderSide: BorderSide.none
                  ),
                  hintText: 'Password',
                ),
              ),
              SizedBox(height: 82,),
              SizedBox(
                height: 61,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Start',
                    style: TextStyles.buttonText,
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.button),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
                  child: Text(
                    'Cancel',
                    style: TextStyles.underText,
                  ),
                ),
              ),
            ],),)
        ],
      ),
    );
  }
}