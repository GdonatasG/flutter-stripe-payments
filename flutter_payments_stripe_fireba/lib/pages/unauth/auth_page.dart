import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () => Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (context) => LoginPage(),
                        fullscreenDialog: true)),
                child: Text(
                  "LOGIN",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
                color: Colors.blue.shade800,
              ),
              SizedBox(
                height: 10,
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                        fullscreenDialog: true)),
                child: Text(
                  "REGISTER",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(color: Colors.white),
                ),
                color: Colors.blue.shade800,
              )
            ],
          ),
        ),
      ),
    );
  }
}
