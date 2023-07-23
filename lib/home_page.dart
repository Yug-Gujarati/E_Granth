// ignore_for_file: avoid_unnecessary_containers

import 'dart:async';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
   const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Navigate to the home page after 2 seconds
      Navigator.pushReplacementNamed(context, '/BookPage');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/image/image1.jpg',
        fit:BoxFit.cover,
      ),
      );
  }
}

