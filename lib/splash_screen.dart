import 'dart:async';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const MyHomePage(title: 'ToDoNest',)));
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
        color: const Color(0xFF38b6ff),
      child: Image.asset('assets/Images/Logo.png',
      ),
    );
  }
}