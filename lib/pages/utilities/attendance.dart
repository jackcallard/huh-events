import 'dart:math';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';

class Attendance extends StatefulWidget {
  const Attendance({this.event});

  final Event event;

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  int numShowing = 6;
  User user;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        Center(
          child: Text(
            "Who's Coming",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DefaultTabController(
          length: 2,
          child: Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300], width: 2)),
            child: Column(
              children: <Widget>[
                TabBar(
                  tabs: <Widget>[
                    Text(
                      'Invited',
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      'Going',
                      style: TextStyle(color: textColor),
                    )
                  ],
                ),
                Container(
                  height: 250,
                  child: TabBarView(children: [
                    ListView.builder(
                        itemCount: min(widget.event.invited.length, numShowing),
                        itemBuilder: (context, index) {
                          var userID = widget.event.invited[index];
                          if (index == numShowing - 1) {
                            return FlatButton.icon(
                              label: Text('Show More'),
                              icon: Icon(Icons.arrow_drop_down),
                              onPressed: () => setState(() => numShowing += 5),
                            );
                          } else {
                            return BasicTile(userID: userID);
                          }
                        }),
                    ListView.builder(
                        itemCount: min(widget.event.going.length, numShowing),
                        itemBuilder: (context, index) {
                          var userID = widget.event.going[index];
                          if (index == numShowing - 1) {
                            return FlatButton.icon(
                              label: Text('Show More'),
                              icon: Icon(Icons.arrow_drop_down),
                              onPressed: () => setState(() => numShowing += 5),
                            );
                          } else {
                            return BasicTile(userID: userID);
                          }
                        }),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
