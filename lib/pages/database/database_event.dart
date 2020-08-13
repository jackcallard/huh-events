import 'dart:async';
import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/services/image_upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseEvent {
  final Geoflutterfire _geo = Geoflutterfire();
  final CollectionReference publicCollection =
      Firestore.instance.collection('publicEvents');
  final CollectionReference privateCollection =
      Firestore.instance.collection('privateEvents');
  int count = 0;

  // Methods to update event data

  void setPublicEventData(Event event) async {
    var imageRef = await UploadImage(imageFile: event.imageFile).uploadEvent();

    var ref = publicCollection.document();
    var id = ref.documentID;
    var location = _geo
        .point(
            latitude: event.geoPoint.latitude,
            longitude: event.geoPoint.longitude)
        .data;

    return ref.setData({
      'basicData': _basicDataToMap(event.basicData),
      'id': id,
      'eventName': event.name,
      'subNames': listifyEvent(event.name),
      'venueName': event.venue,
      'imageRef': imageRef,
      'address': event.address,
      'date': dateTimeFormat(event.timestamp.toDate()),
      'organization': event.organization,
      'userID': event.userID,
      'eventSummary': event.summary,
      'location': location,
      'timestamp': event.timestamp,
      'private': event.private,
    });
  }

  void setPrivateEventData(Event event) async {
    var imageRef = await UploadImage(imageFile: event.imageFile).uploadEvent();

    var ref = privateCollection.document();
    var id = ref.documentID;
    var location = _geo
        .point(
            latitude: event.geoPoint.latitude,
            longitude: event.geoPoint.longitude)
        .data;

    return ref.setData({
      'basicData': _basicDataToMap(event.basicData),
      'id': id,
      'eventName': event.name,
      'venueName': event.venue,
      'imageRef': imageRef,
      'address': event.address,
      'organization': event.organization,
      'userID': event.userID,
      'eventSummary': event.summary,
      'location': location,
      'timestamp': event.timestamp,
      'private': event.private,
      'invited': event.invited,
      'going': [],
    });
  }

  void updatePrivateEvent(Event event) async {
    var ref = (event.private ? privateCollection : publicCollection)
        .document(event.id);
    var location = _geo
        .point(
            latitude: event.geoPoint.latitude,
            longitude: event.geoPoint.longitude)
        .data;
    if (event.imageFile != null) {
      var imageRef =
          await UploadImage(imageFile: event.imageFile).uploadEvent();
      return ref.updateData({
        'eventName': event.name,
        'venueName': event.venue,
        'imageRef': imageRef,
        'address': event.address,
        'organization': event.organization,
        'eventSummary': event.summary,
        'location': location,
        'timestamp': event.timestamp,
      });
    } else {
      return ref.updateData({
        'eventName': event.name,
        'venueName': event.venue,
        'address': event.address,
        'organization': event.organization,
        'eventSummary': event.summary,
        'location': location,
        'timestamp': event.timestamp,
      });
    }
  }

  void updatePublicEvent(Event event) async {
    var ref = publicCollection.document(event.id);
    var location = _geo
        .point(
            latitude: event.geoPoint.latitude,
            longitude: event.geoPoint.longitude)
        .data;
    if (event.imageFile != null) {
      var imageRef =
          await UploadImage(imageFile: event.imageFile).uploadEvent();
      return ref.updateData({
        'eventName': event.name,
        'venueName': event.venue,
        'imageRef': imageRef,
        'subNames': listifyEvent(event.name),
        'address': event.address,
        'organization': event.organization,
        'eventSummary': event.summary,
        'location': location,
        'date': dateTimeFormat(event.timestamp.toDate()),
        'timestamp': event.timestamp,
      });
    } else {
      return ref.updateData({
        'eventName': event.name,
        'venueName': event.venue,
        'address': event.address,
        'subNames': listifyEvent(event.name),
        'organization': event.organization,
        'eventSummary': event.summary,
        'date': dateTimeFormat(event.timestamp.toDate()),
        'location': location,
        'timestamp': event.timestamp,
      });
    }
  }

  // Methods to retrieve Events

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

  Stream<List<Event>> events(
      double lat, double lng, double height, DateTime first, DateTime last) {
    count++;
    if (count % 10 == 0) print('sent $count times');
    Stream<List<Event>> stream;
    var f = first;
    var streamList = <Stream<List<Event>>>[];
    while (f.isAtSameMomentAs(last) || f.isBefore(last)) {
      var eventDate =
          publicCollection.where('date', isEqualTo: dateTimeFormat(f));
      var ds = _geo
          .collection(collectionRef: eventDate)
          .within(
              radius: height,
              strictMode: true,
              field: 'location',
              center: _geo.point(latitude: lat, longitude: lng))
          .map((event) => event.map(_getEvent).toList());

      streamList.add(ds);
      f = f.add(Duration(days: 1));
    }
    stream = Rx.combineLatest(
        streamList, (List<List<Event>> list) => list.expand((i) => i).toList());

    return stream;
  }

  Stream<Event> getEvent(String eventID) {
    return publicCollection
        .document('$eventID')
        .snapshots()
        .map((value) => _getEvent(value));
  }

  Stream<Event> getPrivateEvent(String eventID) {
    return privateCollection
        .document('$eventID')
        .snapshots()
        .map((value) => _getEvent(value));
  }

  void getListEvents(double lat, double lng, double height, DateTime first,
      DateTime last, Function updateList) async {
    var stream = events(lat, lng, height, first, last);
    stream.listen((events) async {
      updateList(events);
    });
  }

  Stream<List<Event>> userEvents(String uid) {
    assert(uid != null);
    return publicCollection
        .where('userID', isEqualTo: uid)
        .snapshots()
        .map((event) => event.documents.map(_getEvent).toList());
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
}
