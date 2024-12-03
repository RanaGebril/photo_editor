import 'package:flutter/material.dart';
import 'package:photo_editor/edit_screen.dart';
import 'package:photo_editor/home_screen.dart';
import 'package:photo_editor/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
          EditScreen.routeName: (context) => EditScreen(),

        },
      );
  }
}