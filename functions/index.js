"use strict";

const admin = require('firebase-admin');

const functions = require('firebase-functions');

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();



// exports.completeOrder = functions.firestore
//     .document('Complete/{id}')
//     .onCreate((snap, context) => {

//         console.log('LOGGER -- Trying to completeOrder');
//         let uid = snap.data().uid

//         var query = db.collection('Selections').where('uid', '==', uid).where('status', '==', 'working')
//             .get()
//             .then(snapshot => {
//                 snapshot.forEach(snapshot => {
//                     snapshot.ref.update('status', 'complete');

//                 })
//                 console.log('Here');
//                 return;
//             })
//             .catch((error) => {
//                 console.log('Error sending message:', error);
//                 throw new Error('Error sending message');
//             });
//             return;

//     });




exports.completeOrder = functions.firestore
    .document('Complete/{id}')
    .onCreate((snap, context) => {

        console.log('LOGGER -- Trying to completeOrder');
        let points = 0;
        let cost = 0;
        let uid = snap.data().uid


        const getUser = db.collection('Users').where('id', '==', uid).get();

        const selectionQuery = db.collection('Selections').where('uid', '==', uid).where('status', '==', 'working').get();

        const itemQuery = db.collection('Items').get();

        var promise = Promise.all([getUser, selectionQuery, itemQuery]).then((values) => {

            values[1].forEach((selectionSnapshot => {
                values[2].forEach((itemSnapshot => {
                    if (selectionSnapshot.ref.get('itemDocId') === itemSnapshot.ref.get('docId'))
                        cost += itemSnapshot.ref.get('price');
                    selectionSnapshot.ref.update('status', 'complete');
                    console.log('Price', itemSnapshot.ref.get('price'))
                    
                }));
                console.log("costt", cost);
            }));

            console.log('cost', cost);
            points = cost * 0.02;
            let currentPoints = 0;
            values[0].forEach((userSnapshot => currentPoints = userSnapshot.ref.get('points')))
            let totalUserPoints = currentPoints + points;

            var message = {
                notification: {
                    title: 'You have earned ' + points.toFixed(2) + ' points for this visit.',
                    body: 'You now have ' + totalUserPoints.toFixed(2) + ' points.',
                },
            };


            console.log("msg2", message);
            values[0].forEach((userSnapshot => {
                
               const msg = admin.messaging.sendToDevice(userSnapshot.ref.get('pushToken'), message);
               const userPoints = userSnapshot.ref.update({ 'points': totalUserPoints });

            }))
            console.log('here');
            return;
        })

        return promise.then((result => {console.log('erhe'); return})
        )

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
                    snapshot.ref.update({ 'status': 'working' });
                    snapshot.ref.update({ 'date': date });
                    snapshot.ref.update({ 'inCart': false });
                })
                console.log('There');
                return;
            })
            .catch((error) => {
                console.log('Error sending message:', error);
                throw new Error('Error sending message');
            });

        return;
    });





exports.sendNotificationOnCreate = functions.firestore
    .document('Notifications/{id}')
    .onCreate((snap, context) => {

        console.log('LOGGER -- Trying to send event push message');

        let msg = snap.data().message;
        let title = snap.data().title;
        let tokens = [];
        console.log('title: ', title, ' msg: ', msg);

        var message = {
            notification: {
                title: title,
                body: msg
            },
        };

        return Promise((resolve, reject) => {
            var query = db.collection('Users').get()
                .then(snapshot => {
                    snapshot.forEach(snapshot => {
                        tokens.push(snapshot.get('pushToken'));
                        console.log('tok: ', tokens);
                    });
                    return admin.messaging().sendToDevice(tokens, message);
                }).then((result) => {
                    // Response is a message ID string.
                    console.log('Successfully sent message:', result);
                    return result;
                })
                .catch((error) => {
                    console.log('Error sending message:', error);
                    throw new Error('Error sending message');
                })

        });
    });

