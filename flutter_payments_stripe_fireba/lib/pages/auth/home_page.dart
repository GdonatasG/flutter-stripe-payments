import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterpaymentsstripefireba/pages/auth/user_cards_page.dart';
import 'package:flutterpaymentsstripefireba/pages/unauth/auth_page.dart';
import 'package:flutterpaymentsstripefireba/services/cloud_service.dart';
import 'package:flutterpaymentsstripefireba/services/stripe_service.dart';
import 'package:flutterpaymentsstripefireba/stripe.dart';
import 'package:stripe_payment/stripe_payment.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final FirebaseUser user;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isBusy = false;

  TextEditingController _amountController = TextEditingController();
  FocusNode _amountFieldFocus = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    StripeService.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (context) => UserCardsPage(
                        userId: widget.user.uid,
                      ),
                  fullscreenDialog: true)),
              icon: Icon(Icons.credit_card),
            ),
            IconButton(
              onPressed: () => _auth.signOut().then((value) => {
                    Navigator.of(context).pushReplacement(
                        new MaterialPageRoute(builder: (context) => AuthPage()))
                  }),
              icon: Icon(Icons.exit_to_app),
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      double amount = double.tryParse(value);
                      if (amount == null) return "Enter correct amount!";
                      if (amount < 0.5) return "Enter higher amount (>=0.5)";
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: Colors.white),
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintText: "Enter amount..",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Colors.white)),
                    controller: _amountController,
                    focusNode: _amountFieldFocus,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FlatButton(
                    onPressed: () =>
                        _formKey.currentState.validate() ? _checkout() : null,
                    child: Text(
                      "PAY",
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
              ),
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  _checkout() async {
    _updateBusy(busy: true);
    final PaymentMethod paymentMethod =
        await Navigator.of(context).push(new MaterialPageRoute(
            builder: (context) => UserCardsPage(
                  userId: widget.user.uid,
                  isCheckout: true,
                )));

    if (paymentMethod == null) {
      _updateBusy(busy: false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Choose a credit card first!"),
      ));
    } else {
      var customerDocument = await Firestore.instance
          .collection('stripe_customers')
          .document(widget.user.uid)
          .get();
      double amount = double.tryParse(_amountController.value.text);
      CloudService.createPaymentIntent(
              amount * 100, 'eur', customerDocument.data['customer_id'])
          .then((response) {
        confirmDialog(response.data["client_secret"], paymentMethod);
      }).catchError((err) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Something went wrong! Try again"),
        ));
      });
      _updateBusy(busy: false);
    }
  }

  confirmDialog(String sec, PaymentMethod paymentMethod) {
    var confirm = AlertDialog(
      title: Text("Confirm Payment"),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Confirm payment with card **** ${paymentMethod.card.last4}",
              // style: TextStyle(fontSize: 25),
            ),
            Text("Charge amount: ${_amountController.value.text}€")
          ],
        ),
      ),
      actions: <Widget>[
        new RaisedButton(
          child: new Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
            final snackBar = SnackBar(
              content: Text('Payment Cancelled'),
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          },
        ),
        new RaisedButton(
          child: new Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop();
            _confirmPayment(sec, paymentMethod); // function to confirm Payment
          },
        ),
      ],
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return confirm;
        });
  }

  _confirmPayment(String sec, PaymentMethod paymentMethod) async {
    _updateBusy(busy: true);
    var response = await StripeService.confirmPaymentIntent(sec, paymentMethod);
    if (response.success) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Completed!"),
      ));
      _amountController.clear();
      print(
          "last4: ${paymentMethod.card.last4}, payment method id: ${paymentMethod.id}");
    } else
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Failed to pay!"),
      ));
    _updateBusy(busy: false);
  }

  _updateBusy({bool busy}) {
    setState(() {
      isBusy = busy;
    });
  }
}
