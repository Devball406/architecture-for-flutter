import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robust/common/data/remote/result.dart';
import 'package:robust/features/data/models/token.dart';

import 'login.control.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Login Title'),
        ),
        body: Container(
          margin: EdgeInsets.all(100),
          child: TextButton(
              onPressed: () async {
                final token = await ref.read(loginProvider(username: '12a2bb191765a70969985a916aacd409').future);
                token.when(
                  success: (Token value) {

                  },
                  error: (err, stack) {},
                );

                //第二种获取结果方式
                // ref
                //     .read(loginProvider(username: 'username').future)
                //     .then((Result<Token> token) {});
              },
              child: Text('Login')),
        ),
      );
    });
  }
}