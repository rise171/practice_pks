import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/screens/create_screen.dart';
import 'package:madshop_ui_petrova/screens/password_screen.dart';
import 'package:madshop_ui_petrova/theme/colors.dart';
import 'package:madshop_ui_petrova/theme/text_styles.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'assets/images/Bubbles1.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Login', style: TextStyles.headlineLogin),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Go to see you again!', style: TextStyles.underText),
                      Icon(Icons.favorite, color: Colors.black, size: 15.93),
                    ],
                  ),
                  SizedBox(height: 17),
                  Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background_text_field,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide.none
                          ),
                          hintText: 'Email',
                        ),
                      ),
                      SizedBox(height: 36),
                      SizedBox(
                        height: 61,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Login',
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
                                builder: (context) => const CreateAccountScreen(),
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
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}