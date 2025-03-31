import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Login Title'),
        ),
        body:
            Container(margin: EdgeInsets.all(100), child: Text('Home Screen')),
      );
    });
  }
}
