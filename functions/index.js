"use strict";

const admin = require('firebase-admin');

const functions = require('firebase-functions');

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();




exports.completeOrder = functions.firestore
    .document('Complete/{id}')
    .onCreate((snap, context) => {

        console.log('LOGGER -- Trying to completeOrder')
        console.log('uid: ', snap.data().uid)
        console.log('cost: ', snap.data().cost)
        var uid = snap.data().uid
        var points = 0.06 * snap.data().cost
        var userSnapshot
        var userPoints
        var userPushToken

        var promises = [];

        db.collection('Users').where('id', '==', uid)
            .get()
            .then(snapshot => {
                snapshot.forEach(snapshot => {
                    userSnapshot = snapshot
                    promises.push(snapshot.ref.get('points'))

                })


                return Promise.all(promises).then((values) => {
                    var userPoints = values[0].get('points')
                    if (values[0].get('pushToken') !== null)
                        var userPushToken = values[0].get('pushToken')

                    var totalPoints = userPoints + points

                    var message = {
                        notification: {
                            title: 'You have earned ' + points.toFixed(2) + ' points for this visit.',
                            body: 'You now have ' + totalPoints.toFixed(2) + ' points.',
                        },
                    }

                    var promises = []
                    if (userPushToken !== null)
                        promises.push(admin.messaging().sendToDevice(userPushToken, message))
                    promises.push(userSnapshot.ref.update({ 'points': totalPoints }))
                    return Promise.all(promises)

                }).then(result => {
                    console.log('Result: ' ,result)
                    return (result)
                })

            }).catch((error) => {
                console.log('Error :', error)
                return (error)
            })




    })




exports.sendOrder = functions.firestore
    .document('Sent/{id}')
    .onCreate((snap, context) => {

        console.log('LOGGER -- Trying to sendOrder');
        let name = snap.data().name
        let pushToken = snap.data().pushToken;

        var message = {
            notification: {
                title: 'Thank you for the order.',
                body: 'It will be ready to be picked up shortly.',
            },
        };

        var adminMessage = {
            notification: {
                title: 'New Order from' + name + '.',
                body: 'You have just received a new order.',
            },
        };

        var promises = [];
        var tokens = [];

        db.collection('Users').where('admin', '==', true)
            .get()
            .then(snapshot => {
                snapshot.forEach(snapshot => {
                    promises.push(snapshot.ref.get('pushToken'))

                })

                return Promise.all(promises).then((values) => {

                    values.forEach(value => {
                        if (value.get('pushToken') !== null)
                            tokens.push(value.get('pushToken'))
                    })


                    var promises = []
                    promises.push(admin.messaging().sendToDevice(tokens, adminMessage))
                    if (pushToken !== null)
                        promises.push(admin.messaging().sendToDevice(pushToken, message))
                    return Promise.all(promises)

                }).then(result => {
                    console.log('Result: ' ,result)
                    return (result)
                })

            }).catch((error) => {
                console.log('Error :', error)
                return (error)
            })

    })




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


        var promises = [];

        db.collection('Users')
            .get()
            .then(snapshot => {
                snapshot.forEach(snapshot => {
                    promises.push(snapshot.ref.get('pushToken'))

                })

                return Promise.all(promises).then((values) => {

                    values.forEach(value => {
                        if (value.get('pushToken') !== null)
                            tokens.push(value.get('pushToken'))
                    })


                    var promises = []
                    promises.push(admin.messaging().sendToDevice(tokens, message))
                    return Promise.all(promises)

                }).then(result => {
                    console.log('Result: ' ,result)
                    return (result)
                })

            }).catch((error) => {
                console.log('Error :', error)
                return (error)
            })


    })




