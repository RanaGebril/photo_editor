import 'package:flutter/material.dart';
import 'package:photo_editor/edit_screen.dart';
import 'package:photo_editor/filter/filter_screen.dart';
import 'package:photo_editor/home_screen.dart';
import 'package:photo_editor/providers/edit_provider.dart';
import 'package:photo_editor/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditProvider(),
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          HomeScreen.routeName: (context) => HomeScreen(),
          EditScreen.routeName: (context) => EditScreen(),
          FilterScreen.routeName: (context) => FilterScreen(),
        },
      ),
    );
  }
}