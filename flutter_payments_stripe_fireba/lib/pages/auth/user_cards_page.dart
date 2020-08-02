import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/Donatas/AndroidStudioProjects/flutter_forum/flutter_payments_stripe_fireba/lib/services/payment_service.dart';
import 'package:stripe_payment/stripe_payment.dart';

class UserCardsPage extends StatefulWidget {
  final String userId;
  final bool isCheckout;

  const UserCardsPage({Key key, @required this.userId, this.isCheckout = false})
      : super(key: key);

  @override
  _UserCardsPageState createState() => _UserCardsPageState();
}

class _UserCardsPageState extends State<UserCardsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("My Cards"),
        actions: [
          IconButton(
            onPressed: () => _addNewCard(),
            icon: Icon(Icons.credit_card),
          )
        ],
      ),
      body: SafeArea(
        child: _showUserCards(),
      ),
    );
  }

  _addNewCard() async {
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      PaymentService().addCard(paymentMethod, widget.userId).then((value) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Card added!"),
        ));
      }).catchError((error) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      });
    });
  }

  _showUserCards() => StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('stripe_customers')
          .document(widget.userId)
          .collection('sources')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents.length > 0) {
            return _buildListOfCards(snapshot.data.documents);
          } else
            return Center(
              child: Text("You don`t have any cards"),
            );
        } else
          return Center(
            child: CircularProgressIndicator(),
          );
      });

  _buildListOfCards(List<DocumentSnapshot> documents) {
    List<PaymentMethod> methods = List<PaymentMethod>();
    for (DocumentSnapshot doc in documents) {
      methods.add(PaymentMethod.fromJson(doc.data));
    }

    return ListView.separated(
        itemBuilder: (context, index) => ListTile(
              onTap: () => widget.isCheckout
                  ? Navigator.pop(context, methods[index])
                  : null,
              title: Text("**** ${methods[index].card.last4}"),
              subtitle: Text(
                  "Expires at: ${methods[index].card.expMonth}/${methods[index].card.expYear}"),
            ),
        separatorBuilder: (context, index) => Divider(
              color: Colors.black54,
            ),
        itemCount: methods.length);
  }
}
