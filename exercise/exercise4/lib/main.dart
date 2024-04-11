import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Animation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  // Add the Key parameter to the constructor
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Page'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SecondPage())),
          child: const Hero(
            tag: 'hero-tag',
            child: Icon(
              Icons.star,
              color: Colors.blue,
              size: 50.0,
            ),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  // Add the Key parameter to the constructor
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: const Center(
        child: Hero(
          tag: 'hero-tag',
          child: Icon(
            Icons.star,
            color: Colors.blue,
            size: 200.0,
          ),
        ),
      ),
    );
  }
}


