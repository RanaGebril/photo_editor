import 'package:flutter/material.dart';

class BottomNavigationItem extends StatelessWidget {
  final Function()? onpressed;
  final String title;
  final IconData? icon;

  BottomNavigationItem(this.icon, {this.onpressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpressed,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}