import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedInfo {
  FeedInfo({
    this.userID,
    this.eventID,
    this.status,
    this.timestamp,
    this.basicData,
  });
  String userID;
  String eventID;
  AttendStatus status;
  Timestamp timestamp;
  BasicData basicData;
}
