import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterpaymentsstripefireba/extensions.dart';
import 'file:///C:/Users/Donatas/AndroidStudioProjects/flutter_forum/flutter_payments_stripe_fireba/lib/pages/auth/home_page.dart';
import 'package:stripe_payment/stripe_payment.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isBusy = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Center(
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.white),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          hintText: "Enter email",
                          hintStyle: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Colors.white)),
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (t) => fieldFocusChange(
                          context, _emailFocusNode, _passwordFocusNode),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Colors.white),
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          hintText: "Enter password",
                          hintStyle: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(color: Colors.white)),
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FlatButton(
                      onPressed: () => _login(),
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
                    Visibility(
                      visible: isBusy,
                      child: CircularProgressIndicator(),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }

  _login() async {
    _updateBusy(busy: true);
    try {
      final AuthResult result = await _auth.signInWithEmailAndPassword(
          email: _emailController.value.text.trim(),
          password: _passwordController.value.text.trim());
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (context) => MyHomePage(
                    title: "Flutter Payments",
                    user: result.user,
                  )),
          (route) => false);
    } catch (error) {
      PlatformException e = error as PlatformException;
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.message.toString()),
      ));
    }
    _updateBusy(busy: false);
  }

  _updateBusy({bool busy}) {
    setState(() {
      isBusy = busy;
    });
  }
}
