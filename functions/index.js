"use strict";

const admin = require('firebase-admin');

const functions = require('firebase-functions');

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();



exports.completeOrder = functions.firestore
    .document('Complete/{id}')
    .onCreate((snap, context) => {

        console.log('LOGGER -- Trying to completeOrder');
        let uid = snap.data().uid

        var query = db.collection('Selections').where('uid', '==', uid).where('status', '==', 'working')
            .get()
            .then(snapshot => {
                snapshot.forEach(snapshot => {
                    snapshot.ref.update('status', 'complete');

                })
                console.log('Here');
                return;
            })
            .catch((error) => {
                console.log('Error sending message:', error);
                throw new Error('Error sending message');
            });
            return;

    });


exports.sendOrder = functions.firestore
    .document('Sent/{id}')
    .onCreate((snap, context) => {

        console.log('LOGGER -- Trying to sendOrder');
        let uid = snap.data().uid;
        let date = snap.data().date;
        var query = db.collection('Selections').where('uid', '==', uid).where('inCart', '==', true)
            .get()
            .then(snapshot => {
                snapshot.forEach(snapshot => {
                    snapshot.ref.update({'status': 'working'});
                    snapshot.ref.update({'date': date});
                    snapshot.ref.update({'inCart': false});
                })
                console.log('There');
                return result;
            })
            .catch((error) => {
                console.log('Error sending message:', error);
                throw new Error('Error sending message');
            });

            return;
    });









// exports.sendNotificationOnCreate = functions.firestore
//   .document('Notifications/{id}')
//   .onCreate((snap, context) => {

//     console.log('LOGGER -- Trying to send event push message');

//     let msg = snap.data().message;
//     let title = snap.data().title;
//     let tokens = [];
//     console.log('title: ', title, ' msg: ', msg);
//     // This registration token comes from the client FCM SDKs.
//     // var fcmToken = 'c3aHR6j3QJE:APA91bGy3xturh8PQ1gYpGiIM6KwoiibOzljmWrBDFB-87TLNvtV_EVVrmVDZIklupWBpJRoy6QoOn1lq9BWSWOFVZDW1ZFMrwlhumwN3HikWRxL9iUzvY9aAnIPug9G6TKUqha_1VqQ';
//     // tokens.push(fcmToken);
//     // See documentation on defining a message payload.
//     var message = {
//         notification: {
//             title: title,
//             body: msg
//         },
//     };

//     new Promise(function(resolve, reject) {

//         var query = db.collection('Users').get()
//             .then(snapshot => {
//                 snapshot.forEach(snapshot => {
//                     tokens.push(snapshot.get('pushToken'));
//                     console.log('tok: ', tokens);
//                 });
//                 return admin.messaging().sendToDevice(tokens, message);
//             }).then((result) => {
//                 // Response is a message ID string.
//                 console.log('Successfully sent message:', result);
//                 return result;
//             })
//             .catch((error) => {
//                 console.log('Error sending message:', error);
//                 throw new Error('Error sending message');
//             });
            
//     });


// });