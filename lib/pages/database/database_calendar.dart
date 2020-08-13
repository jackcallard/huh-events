import 'package:app_v4/pages/models/calendar_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseCalendar {
  DatabaseCalendar({String uid}) {
    this.uid = uid;
    calendarCollection = Firestore.instance.collection('users/$uid/calendar');
  }
  String uid;
  CollectionReference calendarCollection;

  CalendarEvent _getCal(DocumentSnapshot e) {
    Map map = e.data;
    String eventID = map['eventID'];
    Timestamp timestamp = map['timestamp'];
    bool private = map['private'];
    return CalendarEvent(
        eventID: eventID, timestamp: timestamp, private: private);
  }

  Stream<List<CalendarEvent>> getCalendar() {
    return calendarCollection
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('timestamp')
        .snapshots()
        .map((event) => event.documents.map(_getCal).toList());
  }
}
