import 'package:cloud_functions/cloud_functions.dart';

class CloudService {
  static Future<HttpsCallableResult> createPaymentIntent(
          double amount, String currency, String customer) async =>
      await CloudFunctions.instance
          .getHttpsCallable(functionName: 'createPaymentIntent')
          .call(<String, dynamic>{
        'amount': amount.toStringAsPrecision(4),
        'currency': currency,
        'customer': customer
      });
}
