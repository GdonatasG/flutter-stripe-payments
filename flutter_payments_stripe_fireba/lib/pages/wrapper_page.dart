import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/Donatas/AndroidStudioProjects/flutter_forum/flutter_payments_stripe_fireba/lib/pages/unauth/auth_page.dart';
import 'file:///C:/Users/Donatas/AndroidStudioProjects/flutter_forum/flutter_payments_stripe_fireba/lib/pages/auth/home_page.dart';

class WrapperPage extends StatefulWidget {
  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<FirebaseUser>(
            stream: _auth.currentUser().asStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (context) => AuthPage()));
                  });

                  return Container();
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (context) => MyHomePage(
                              title: "Flutter Payments",
                              user: snapshot.data,
                            )));
                  });
                  return Container();
                }
              } else
                return Center(
                  child: CircularProgressIndicator(),
                );
            }),
      ),
    );
  }
}
