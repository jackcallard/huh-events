import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();




// Called upon creating a new user, creates empty userFriends

export const initUser = functions.firestore.document('users/{userID}')
  .onCreate((snapshot, context) => {

    const userID = context.params.userID;
    return admin.firestore().collection('userFriends').doc(userID).set({ 'friends': [] })
  });


//UPDATE

// Called upon a profile update, updates the basic data in each feed and event

export const updateUserData = functions.firestore.document('users/{userID}')
  .onUpdate(async (change, context) => {
    const userID = context.params.userID;
    const docBefore = change.before.data();
    const docAfter = change.after.data();

    if (docBefore.profileName !== docAfter.profileName || docBefore.imageRef !== docAfter.imageRef) {

      await admin.firestore().collection('feed')
        .where('timestamp', '>=', admin.firestore.Timestamp.now())
        .where('userID', '==', userID)
        .get().then((val) => {
          val.docs.forEach(async (doc) => {
            await admin.firestore().doc('feed/' + doc.id).update({
              'basicData': {
                'profileName': docAfter.profileName,
                'imageRef': docAfter.imageRef,
                'username': docAfter.username,
                'uid': docAfter.uid,
              }
            })
          })
        });

      await admin.firestore().collection('publicEvents')
        .where('userID', '==', userID)
        .get().then((val) => {
          val.docs.forEach(async (doc) => {
            await admin.firestore().doc('publicEvents/' + doc.id).update({
              'basicData': {
                'profileName': docAfter.profileName,
                'imageRef': docAfter.imageRef,
                'username': docAfter.username,
                'uid': docAfter.uid,
              }
            })
          });
        });

      await admin.firestore().collection('privateEvents')
        .where('userID', '==', userID)
        .get().then((val) => {
          val.docs.forEach(async (doc) => {
            await admin.firestore().doc('privateEvents/' + doc.id).update({
              'basicData': {
                'profileName': docAfter.profileName,
                'imageRef': docAfter.imageRef,
                'username': docAfter.username,
                'uid': docAfter.uid,
              }
            })
          })
        });

      await admin.firestore().collection('shares')
        .where('from', '==', userID)
        .where('timestamp', '>=', admin.firestore.Timestamp.now())
        .get().then((val) => {
          val.docs.forEach(async (doc) => {
            await admin.firestore().doc('shares/' + doc.id).update({
              'basicData': {
                'profileName': docAfter.profileName,
                'imageRef': docAfter.imageRef,
                'username': docAfter.username,
                'uid': docAfter.uid,
              }
            })
          });
        });
    }
    return null;
  });

// Called upon a feed write, updates the calendar

export const addToCalendar = functions.firestore.document('feed/{docID}')
  .onWrite(async (change, context) => {
    const docID = context.params.docID;
    const docBefore = change.before.data();
    const docAfter = change.after.data();

    if (docAfter) {
      return admin.firestore().collection('users').doc(docAfter.userID).collection('calendar').doc(docID).set({
        'eventID': docAfter.eventID,
        'timestamp': docAfter.timestamp,
        'status': docAfter.status,
        'private': false,
      });
    } else if (docBefore) {
      return admin.firestore().collection('users').doc(docBefore.userID).collection('calendar').doc(docID).delete();
    } else {
      return null;
    }
  });


// Called upon a public event write, adds the event to users feed

export const createPublicEvent = functions.firestore.document('publicEvents/{eventID}')
  .onCreate(async (snapshot, context) => {
    const docData = snapshot.data();

    return admin.firestore().collection('feed').doc(docData.userID + '-' + docData.id).set({
      'basicData': docData.basicData,
      'userID': docData.userID,
      'eventID': docData.id,
      'timestamp': docData.timestamp,
      'status': 'hosting',

    });
  });

// Called upon a public event write, updates the event in the geoevents collection

export const adjustPublicEvent = functions.firestore.document('publicEvents/{eventID}')
  .onUpdate(async (change, context) => {
    const eventID = context.params.eventID;
    const docBefore = change.before.data();
    const docAfter = change.after.data();


    if (docBefore.timestamp !== docAfter.timestamp) {

      await admin.firestore().collection('feed')
        .where('timestamp', '>=', admin.firestore.Timestamp.now())
        .where('eventID', '==', eventID)
        .get().then((val) => {
          val.docs.forEach(async (doc) => {
            await admin.firestore().doc('feed/' + doc.id).update({
              'timestamp': docAfter.timestamp
            })
          })
        });

      await admin.firestore().collection('shares')
        .where('eventID', '==', eventID)
        .where('timestamp', '>=', admin.firestore.Timestamp.now())
        .get().then((val) => {
          val.docs.forEach(async (doc) => {
            await admin.firestore().doc('shares/' + doc.id).update({
              'timestamp': docAfter.timestamp
            })
          });
        });
    }
    return null;
  });

// Called upon a public event delete, deletes the event's shares and feed

export const deletePublicEvent = functions.firestore.document('publicEvents/{eventID}')
  .onDelete(async (snapshot, context) => {
    const eventID = context.params.eventID;

    await admin.firestore().collection('feed')
      .where('timestamp', '>=', admin.firestore.Timestamp.now())
      .where('eventID', '==', eventID)
      .get().then((val) => {
        val.docs.forEach(async (doc) => {
          await admin.firestore().doc('feed/' + doc.id).delete();
        })
      });

    await admin.firestore().collection('shares')
      .where('eventID', '==', eventID)
      .where('timestamp', '>=', admin.firestore.Timestamp.now())
      .get().then((val) => {
        val.docs.forEach(async (doc) => {
          await admin.firestore().doc('shares/' + doc.id).delete();
        });
      });
    return null;

  });




// Called upon a feed creation, adds the users friends to the document

export const feedFriends = functions.firestore.document('feed/{feedID}')
  .onCreate(async (snapshot, context) => {
    const feedID = context.params.feedID;
    const docData = snapshot.data();
    const userID = docData.userID;

    const userFriends = await admin.firestore().collection('userFriends').doc(userID).get().then((value) => {
      const data = value.data();
      if (data !== undefined) return data.friends;
      else return [];
    });
    return admin.firestore().collection('feed').doc(feedID).update({ 'friends': userFriends });


  });


// Called upon a change in friend status, adds friend to feed if appropriate

export const updateFeed = functions.firestore.document('friendships/{docID}')
  .onUpdate(async (change, context) => {
    const docID: string = context.params.docID;
    const docAfter = change.after.data();
    const docBefore = change.before.data();
    const users = docID.split('-');

    if (docAfter.status === 'friends' && docBefore.status === 'request') {
      await admin.firestore().collection('feed').where('timestamp', '>=', admin.firestore.Timestamp.now()).where('userID', '==', users[0]).get().then((val) => {
        val.docs.forEach(async (doc) => {
          await admin.firestore().doc('feed/' + doc.id).update({ 'friends': admin.firestore.FieldValue.arrayUnion(users[1]) })
        })
      });

      await admin.firestore().collection('feed').where('timestamp', '>=', admin.firestore.Timestamp.now()).where('userID', '==', users[1]).get().then((val) => {
        val.docs.forEach(async (doc) => {
          await admin.firestore().doc('feed/' + doc.id).update({ 'friends': admin.firestore.FieldValue.arrayUnion(users[0]) })
        })
      });
    }
    return null;
  });


// Called upon a friend delete, removes friends from feed if appropriate

export const deleteFromFeed = functions.firestore.document('friendships/{docID}')
  .onDelete(async (snapshot, context) => {
    const docID: string = context.params.docID;
    const users = docID.split('-');
    const docData = snapshot.data();

    if (docData.status === 'friends') {
      await admin.firestore().collection('feed').where('timestamp', '>=', admin.firestore.Timestamp.now()).where('userID', '==', users[0]).get().then((val) => {
        val.docs.forEach(async (doc) => {
          await admin.firestore().doc('feed/' + doc.id).update({ 'friends': admin.firestore.FieldValue.arrayRemove(users[1]) })
        })
      });

      await admin.firestore().collection('feed').where('timestamp', '>=', admin.firestore.Timestamp.now()).where('userID', '==', users[1]).get().then((val) => {
        val.docs.forEach(async (doc) => {
          await admin.firestore().doc('feed/' + doc.id).update({ 'friends': admin.firestore.FieldValue.arrayRemove(users[0]) })
        })
      });
    }
    return null
  });


// Called upon a change in friend status, adds friend to friend list if appropriate

export const updateList = functions.firestore.document('friendships/{docID}')
  .onUpdate(async (change, context) => {
    const docID: string = context.params.docID;
    const users = docID.split('-');
    const docAfter = change.after.data();
    const docBefore = change.before.data();

    if (docAfter.status === 'friends' && docBefore.status === 'request') {
      await admin.firestore().collection('userFriends').doc(users[0]).update({ 'friends': admin.firestore.FieldValue.arrayUnion(users[1]) });

      await admin.firestore().collection('userFriends').doc(users[1]).update({ 'friends': admin.firestore.FieldValue.arrayUnion(users[0]) });
    }
    return null;
  });


// Called upon a friend delete, removes friend from friend list if appropriate

export const deleteFromList = functions.firestore.document('friendships/{docID}')
  .onDelete(async (snapshot, context) => {
    const docID: string = context.params.docID;
    const users = docID.split('-');
    const docData = snapshot.data();

    if (docData.status === 'friends') {
      await admin.firestore().collection('userFriends').doc(users[0]).update({ 'friends': admin.firestore.FieldValue.arrayRemove(users[1]) });

      await admin.firestore().collection('userFriends').doc(users[1]).update({ 'friends': admin.firestore.FieldValue.arrayRemove(users[0]) });
    }
    return null;
  });






