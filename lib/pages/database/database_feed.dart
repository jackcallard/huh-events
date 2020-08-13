import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/feed_info.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseFeed {
  DatabaseFeed({this.uid});
  final String uid;
  CollectionReference feedCollection = Firestore.instance.collection('feed');

  Future<void> setStatus(
      Event event, String status, BasicData basicData) async {
    assert(uid != null && event != null);
    var doc = feedCollection.document('$uid-${event.id}');
    return doc.setData({
      'basicData': _basicDataToMap(basicData),
      'userID': uid,
      'eventID': event.id,
      'timestamp': event.timestamp,
      'status': status,
    }, merge: true);
  }

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

  void removeStatus(String eventID) {
    assert(uid != null && eventID != null);
    feedCollection.document('$uid-$eventID').delete();
  }

  FeedInfo _getFeedInfo(DocumentSnapshot e) {
    var status;
    if (e['status'] == 'going') {
      status = AttendStatus.going;
    } else if (e['status'] == 'interested') {
      status = AttendStatus.interested;
    } else {
      status = AttendStatus.hosting;
    }
    return FeedInfo(
      eventID: e['eventID'],
      userID: e['userID'],
      status: status,
      timestamp: e['timestamp'],
      basicData: _mapToBasicData(e['basicData']),
    );
  }

  Stream<List<FeedInfo>> getUserFeed(String userID) {
    return feedCollection
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map((event) => event.documents.map(_getFeedInfo).toList());
  }

  Stream<List<FeedInfo>> getFeed() {
    return feedCollection
        .where('friends', arrayContains: uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .snapshots()
        .map((event) => event.documents.map(_getFeedInfo).toList());
  }

  Future<AttendStatus> getStatus(String eventID) async {
    assert(eventID != null);
    var ds = await feedCollection.document('$uid-$eventID').get();
    if (ds.data == null) return AttendStatus.none;
    if (ds.data['status'] == 'going') return AttendStatus.going;
    if (ds.data['status'] == 'hosting') return AttendStatus.hosting;
    return AttendStatus.interested;
  }
}
