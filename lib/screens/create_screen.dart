import 'package:flutter/material.dart';
import 'package:madshop_ui_petrova/theme/colors.dart';
import 'package:madshop_ui_petrova/theme/text_styles.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(padding: EdgeInsetsGeometry.only(bottom: 0), child: Image.asset('assets/images/Bubbles.png'),),
          Column(
            children: [
              Padding(padding: EdgeInsetsGeometry.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  SizedBox(height: 72,),
                  Padding(padding: EdgeInsetsGeometry.only(left: 10), child: Text('Create \nAccount', style: TextStyles.headlineCreateAc)),
                  SizedBox(height: 176),
                  TextField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background_text_field,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: BorderSide.none
                        ),
                        hintText: 'Email'),
                  ),
                  SizedBox(height: 8,),
                  TextField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background_text_field,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60),
                            borderSide: BorderSide.none
                        ),
                        hintText: 'Password'),
                  ),
                    SizedBox(height: 8,),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background_text_field,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(60),
                          borderSide: BorderSide.none
                      ),
                      hint: Row(children: [
                        Image.asset('assets/images/russia.png'), Text('  |  Your Number')
                      ],),
                    ),
                  ),
                ],
                  ),
              ),
              SizedBox(height: 52,),
              Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 20), child:
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.button, padding: EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen(),),);
                    },
                    child: Text('Done', style: TextStyles.buttonText,)),
              ),)
            ],
          )
        ],
      ),
    );
  }
}
