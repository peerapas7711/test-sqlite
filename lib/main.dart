// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:test_sqlite/ListItemPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mytheme(),
      routes: {
        '/': (context) => SplashScreen(),
        '/list': (context) => ListItemPage(),
      },
      // home: SplashScreen(),
    );
  }

  ThemeData mytheme() {
    return ThemeData(
      fontFamily: 'Prompt',
      appBarTheme: AppBarTheme(
        // centerTitle: true
        textTheme: TextTheme(
          headline6: TextStyle(
            fontFamily: 'Prompt',
            // color: HexColor('#000000'),
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Flutter Exam',
                    textStyle:
                        TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
                    colors: [
                      Colors.cyanAccent,
                      Colors.purpleAccent,
                      Colors.blueAccent,
                    ],
                  ),
                ],
                isRepeatingAnimation: true,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80, right: 80),
                child: Center(
                    child: LinearProgressIndicator(
                  backgroundColor: Colors.deepPurple,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
