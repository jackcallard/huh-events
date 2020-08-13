import 'dart:io';

import 'package:app_v4/pages/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  Event({
    this.name,
    this.imageRef,
    this.venue,
    this.address,
    this.organization,
    this.userID,
    this.summary,
    this.geoPoint,
    this.timestamp,
    this.id,
    this.basicData,
    this.private,
    this.invited,
    this.going,
    this.square,
    this.imageFile,
  });
  String id;
  String venue;
  String address;
  String name;
  String imageRef;
  String organization;
  String summary;
  String userID;
  GeoPoint geoPoint;
  Timestamp timestamp;
  BasicData basicData;
  bool private;
  List<String> invited;
  List<String> going;
  List<String> square;
  File imageFile;

  Event clone() {
    return Event(
        id: id,
        venue: venue,
        address: address,
        name: name,
        imageFile: imageFile,
        imageRef: imageRef,
        organization: organization,
        summary: summary,
        userID: userID,
        geoPoint: geoPoint,
        timestamp: timestamp,
        basicData: basicData,
        private: private,
        invited: invited,
        going: going,
        square: square);
  }
}
