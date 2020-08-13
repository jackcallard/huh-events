import 'dart:math';
import 'package:app_v4/pages/database/database_relations.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShareFriends extends StatefulWidget {
  const ShareFriends({this.event});

  final Event event;

  @override
  _ShareFriendsState createState() => _ShareFriendsState();
}

class _ShareFriendsState extends State<ShareFriends> {
  int numShowing = 6;
  User user;
  DatabaseRelations _dbr;
  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    _dbr = DatabaseRelations(uid: user.uid);
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        Center(
          child: Text(
            'Go with Friends',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        FutureBuilder<List<String>>(
            future: _dbr.getAllFriends(),
            initialData: [],
            builder: (context, snapshot) {
              return Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 250,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300], width: 2)),
                child: ListView.builder(
                    itemCount: min(snapshot.data.length, numShowing),
                    itemBuilder: (context, index) {
                      var userID = snapshot.data[index];
                      if (index == numShowing - 1) {
                        return FlatButton.icon(
                          label: Text('Show More'),
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: () => setState(() => numShowing += 5),
                        );
                      } else {
                        return ShareTile(
                          userID: userID,
                          event: widget.event,
                        );
                      }
                    }),
              );
            }),
      ],
    );
  }
}
