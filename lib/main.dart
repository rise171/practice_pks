import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Практика 3"), centerTitle: true,),
        body: Column(
          children: [
            SizedBox(height: 150),
            Text(
              "Добро пожаловать!",
              style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 50,),
            ElevatedButton(
              onPressed: () {},
              child: Text("Кнопка"),
            ),
            Container(
              width: 200,
              height: 200,
              color: Color(0xFFFF0000),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.purpleAccent),
                SizedBox(width: 150),
                Icon(Icons.ac_unit_outlined, color: Colors.blue)
              ],
            ),
          ],
        ),
      ),
    );
  }
}