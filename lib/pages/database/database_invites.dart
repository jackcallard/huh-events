import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/share.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseInvites {
  DatabaseInvites({this.basicData});
  BasicData basicData;

  final CollectionReference shareCollection =
      Firestore.instance.collection('shares');

  final CollectionReference privateCollection =
      Firestore.instance.collection('privateEvents');

  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  BasicData _mapToBasicData(Map map) {
    return BasicData(
      uid: map['uid'],
      screenName: map['profileName'],
      username: map['username'],
      imageRef: map['imageRef'],
    );
  }

  Map _basicDataToMap(BasicData bd) {
    return {
      'username': bd.username,
      'profileName': bd.screenName,
      'imageRef': bd.imageRef,
      'uid': bd.uid,
    };
  }

  Future<void> share(String userID, Event event) {
    return shareCollection
        .document('${basicData.uid}-$userID-${event.id}')
        .setData({
      'eventID': event.id,
      'from': basicData.uid,
      'to': userID,
      'basicData': _basicDataToMap(basicData),
      'timestamp': event.timestamp,
    });
  }

  Future<void> unshare(String userID, Event event) {
    return shareCollection
        .document('${basicData.uid}-$userID-${event.id}')
        .delete();
  }

  Share _getShare(DocumentSnapshot e) {
    var map = e.data;
    return Share(
      basicData: _mapToBasicData(map['basicData']),
      eventID: map['eventID'],
    );
  }

  Stream<List<Share>> getShares() {
    return shareCollection
        .where('to', isEqualTo: basicData.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .snapshots()
        .map((event) => event.documents.map(_getShare).toList());
  }

  Future<bool> shared(String userID, Event event) {
    return shareCollection
        .document('${basicData.uid}-$userID-${event.id}')
        .get()
        .then((value) => value.data != null);
  }

  List<String> _getList(Map<String, dynamic> map, String field) {
    List lst = map[field];
    if (lst == null) return [];
    return lst.map((e) => e.toString()).toList();
  }

  Event _getEvent(DocumentSnapshot e) {
    var map = e.data;
    assert(e.data != null);
    return Event(
      id: map['id'],
      venue: map['venueName'],
      address: map['address'],
      organization: map['organization'],
      name: map['eventName'],
      userID: map['userID'],
      geoPoint: map['location']['geopoint'],
      imageRef: map['imageRef'],
      summary: map['eventSummary'],
      timestamp: map['timestamp'],
      basicData: _mapToBasicData(map['basicData']),
      invited: _getList(map, 'invited'),
      going: _getList(map, 'going'),
      square: _getList(map, 'square'),
      private: map['private'],
    );
  }

  Stream<List<Event>> getInvites() {
    return privateCollection
        .where('invited', arrayContains: basicData.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .snapshots()
        .map((event) => event.documents.map(_getEvent).toList());
  }

  Stream<List<List<Event>>> getSortedInvites() {
    return privateCollection
        .where('invited', arrayContains: basicData.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .snapshots()
        .map((event) {
      // ignore: omit_local_variable_types
      List<Event> declined = [];
      // ignore: omit_local_variable_types
      List<Event> accepted = [];
      // ignore: omit_local_variable_types
      List<Event> active = [];
      event.documents.forEach((element) {
        // ignore: omit_local_variable_types
        Event e = _getEvent(element);
        if (e.going.contains(basicData.uid)) {
          accepted.add(e);
        } else if (e.square.contains(basicData.uid)) {
          declined.add(e);
        } else {
          active.add(e);
        }
      });
      return [declined, accepted, active];
    });
  }

  Stream<List<Event>> getSquaredInvites() {
    return privateCollection
        .where('invited', arrayContains: basicData.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .snapshots()
        .map((event) => event.documents.map(_getEvent).toList());
  }

  Future<void> setGoing(Event event) async {
    await privateCollection.document(event.id).updateData({
      'square': FieldValue.arrayRemove([basicData.uid]),
      'going': FieldValue.arrayUnion([basicData.uid])
    });
    return userCollection
        .document(basicData.uid)
        .collection('calendar')
        .document('${basicData.uid}--${event.id}')
        .setData({
      'status': 'private',
      'timestamp': event.timestamp,
      'eventID': event.id,
      'private': true,
    });
  }

  Future<void> removeGoing(Event event) async {
    await privateCollection.document(event.id).updateData({
      'going': FieldValue.arrayRemove([basicData.uid])
    });
    return userCollection
        .document(basicData.uid)
        .collection('calendar')
        .document('${basicData.uid}--${event.id}')
        .delete();
  }

  Future<void> setSquare(Event event) async {
    await privateCollection.document(event.id).updateData({
      'going': FieldValue.arrayRemove([basicData.uid]),
      'square': FieldValue.arrayUnion([basicData.uid])
    });
    return userCollection
        .document(basicData.uid)
        .collection('calendar')
        .document('${basicData.uid}--${event.id}')
        .delete();
  }

  Future<void> removeSquare(Event event) {
    return privateCollection.document(event.id).updateData({
      'square': FieldValue.arrayRemove([basicData.uid])
    });
  }
}
