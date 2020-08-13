import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/database/database_event.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/utilities/event_tile.dart';

class UserEvents extends StatefulWidget {
  @override
  _UserEventsState createState() => _UserEventsState();
}

class _UserEventsState extends State<UserEvents> {
  final DatabaseEvent _dbe = DatabaseEvent();
  bool first = true;
  Map args;
  String uid;

  void _setUp(context) {
    args = ModalRoute.of(context).settings.arguments;
    uid = args['uid'];
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<List<Event>>(
          stream: _dbe.userEvents(uid),
          initialData: [],
          builder: (context, snapshot) {
            var list = snapshot.data ?? [];
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    EventTile(event: list[index]),
                  ],
                );
              },
            );
          }),
    );
  }
}
