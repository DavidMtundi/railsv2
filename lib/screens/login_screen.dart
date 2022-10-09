import 'package:flutter/material.dart';

import '../register/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text("Google Login"),
        backgroundColor: Colors.green,
      ),
      body: Container(
          width: 50,
          height: 40,
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: size.height * 0.2,
              bottom: size.height * 0.5),
          child: ElevatedButton(
              onPressed: () {
                AuthService().handleAuthState();
              },
              child: Text('SignIn'))),
    );
  }
}
