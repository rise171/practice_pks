import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyHomePage> {
  int counter = 0;
  void incrementCounter() {
    setState(() {
      counter++;
    });
  }
  void restartCounter() {
    setState(() {
      counter = 0;
    });
  }

  void longCounter() {
    setState(() {
      counter += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Практика 4"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Значение счётчика: $counter "),
            SizedBox(
              height: 20,
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0),
              child:
                Container(
                  color: Colors.purpleAccent,
                  padding: EdgeInsets.all(10.0),
                  child: ElevatedButton(onPressed: () {
                    incrementCounter();
                  }, onLongPress: () {
                    longCounter();
                  }, child: Text("Увеличить")),
                ),
            ),
            Container(
              color: Colors.purple,
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(onPressed: () {
                restartCounter();
              }, child: Text("Сбросить")),
            ),
          ],
        ),
      ),
    );
  }
}
