import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSearch {
  DatabaseSearch({this.uid});
  String uid;
  final CollectionReference userCollection =
      Firestore.instance.collection('users');
  final CollectionReference publicCollection =
      Firestore.instance.collection('publicEvents');

  Stream<List<BasicData>> getUsersFromSub(String sub) {
    return userCollection
        .where('subNames', arrayContains: sub.toLowerCase())
        .snapshots()
        .map((e) => e.documents.map(_basicData).toList());
  }

  Stream<List<Event>> getEventsFromSub(String sub) {
    return publicCollection
        .where('subNames', arrayContains: sub.toLowerCase())
        .snapshots()
        .map((e) => e.documents.map(_getEvent).toList());
  }

  BasicData _basicData(DocumentSnapshot e) {
    if (e.data == null) return null;
    return BasicData(
        screenName: e.data['profileName'] ?? '',
        username: e.data['username'] ?? '',
        uid: e.data['uid'],
        imageRef: e.data['imageRef']);
  }

  BasicData _mapToBasicData(Map map) {
    return BasicData(
      uid: map['uid'],
      screenName: map['profileName'],
      username: map['username'],
      imageRef: map['imageRef'],
    );
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
      private: map['private'],
    );
  }
}
