import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_calendar.dart';
import 'package:app_v4/pages/database/database_event.dart';
import 'package:app_v4/pages/models/calendar_event.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:app_v4/pages/utilities/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  User user;
  DatabaseCalendar _dbc;
  DatabaseEvent _dbe;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    _dbc = DatabaseCalendar(uid: user.uid);
    _dbe = DatabaseEvent();

    return Scaffold(
      appBar: AppBar(),
      drawer: MyDrawer(loc: '/calendar'),
      body: StreamBuilder<List<CalendarEvent>>(
          stream: _dbc.getCalendar(),
          initialData: [],
          builder: (context, snapshot) {
            var lst = snapshot.data ?? [];
            return ListView.builder(
              itemCount: lst.length,
              itemBuilder: (context, index) {
                var cal = lst[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      visible: index == 0 ||
                          dateTimeFormat(cal.timestamp.toDate()) !=
                              dateTimeFormat(
                                  snapshot.data[index - 1].timestamp.toDate()),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          dateTimeFormat(cal.timestamp.toDate()),
                          style: textStyle,
                        ),
                      ),
                    ),
                    StreamBuilder<Event>(
                        stream: cal.private
                            ? _dbe.getPrivateEvent(cal.eventID)
                            : _dbe.getEvent(cal.eventID),
                        builder: (context, snapshot) {
                          return EventTile(event: snapshot.data);
                        }),
                  ],
                );
              },
            );
          }),
    );
  }
}
