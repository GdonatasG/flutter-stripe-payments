'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
//const logging = require('@google-cloud/logging')();
const stripe = require('stripe')(functions.config().stripe.token);
//const currency = functions.config().stripe.currency || 'EUR';


//creating stripe payment intent and attaching it to the specific customer
exports.createPaymentIntent = functions.https.onCall((data, context) => {
    return stripe.paymentIntents.create({
    amount: data.amount,
    currency: data.currency,
    customer: data.customer,
    payment_method_types: ['card'],
  });
});

// creating stripe customer
exports.createStripeCustomer = functions.auth.user().onCreate(async (user) => {
  const customer = await stripe.customers.create({email: user.email});
  return admin.firestore().collection('stripe_customers').doc(user.uid).set({customer_id: customer.id});
});


// attaching payment source to the specific customer
exports.addPaymentSource = functions.firestore.document('/stripe_customers/{userId}/sources/{pushId}').onCreate(async (snap, context) => {
  const paymentMethod = snap.data();
  if (paymentMethod === null){
    return null;
  }

  try {
    const snapshot = await admin.firestore().collection('stripe_customers').doc(context.params.userId).get();
    const customer =  snapshot.data().customer_id;
    return await stripe.paymentMethods.attach(paymentMethod.id, {customer: customer});
  } catch (error) {
    await snap.ref.set({'error':userFacingMessage(error)},{merge:true});
    return reportError(error, {user: context.params.userId});
  }
});

// To keep on top of errors, we should raise a verbose error report with Stackdriver rather
// than simply relying on console.error. This will calculate users affected + send you email
// alerts, if you've opted into receiving them.
// [START reporterror]
function reportError(err, context = {}) {
  // This is the name of the StackDriver log stream that will receive the log
  // entry. This name can be any valid log stream name, but must contain "err"
  // in order for the error to be picked up by StackDriver Error Reporting.
  const logName = 'errors';
  const log = logging.log(logName);

  // https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
  const metadata = {
    resource: {
      type: 'cloud_function',
      labels: {function_name: process.env.FUNCTION_NAME},
    },
  };

  // https://cloud.google.com/error-reporting/reference/rest/v1beta1/ErrorEvent
  const errorEvent = {
    message: err.stack,
    serviceContext: {
      service: process.env.FUNCTION_NAME,
      resourceType: 'cloud_function',
    },
    context: context,
  };

  // Write the error log entry
  return new Promise((resolve, reject) => {
    log.write(log.entry(metadata, errorEvent), (error) => {
      if (error) {
       return reject(error);
      }
      return resolve();
    });
  });
}
// [END reporterror]

// Sanitize the error message for the user
function userFacingMessage(error) {
  return error.type ? error.message : 'An error occurred, developers have been alerted';
}
