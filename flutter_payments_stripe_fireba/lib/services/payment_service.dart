import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentService {
  Future<void> addCard(PaymentMethod method, uid) async {
    await Firestore.instance
        .collection('stripe_customers')
        .document(uid)
        .collection('sources')
        .add(method.toJson());
  }
}
