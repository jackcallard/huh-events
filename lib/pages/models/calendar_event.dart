import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  CalendarEvent({this.eventID, this.timestamp, this.private});
  String eventID;
  Timestamp timestamp;
  bool private;
}
