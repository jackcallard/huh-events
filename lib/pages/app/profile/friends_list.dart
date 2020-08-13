import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_relations.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  String accID;
  Map args = {};
  bool first = true;
  User user;
  DatabaseRelations _dbr;

  void _setUp(context) {
    first = false;
    user = Provider.of<User>(context);
    _dbr = DatabaseRelations(uid: user.uid);
    args = ModalRoute.of(context).settings.arguments;
    accID = args['uid'];
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return StreamBuilder<List<String>>(
        stream: _dbr.getFriends(accID),
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.grey[200],
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.grey[600]),
              ),
              body: snapshot.hasData
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: snapshot.data.isEmpty
                          ? Center(
                              child: Text(
                              'No friends at the moment.',
                              style: TextStyle(
                                  fontFamily: font2,
                                  color: Colors.grey[600],
                                  fontSize: 20),
                            ))
                          : ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, ind) {
                                return BasicTile(userID: snapshot.data[ind]);
                              },
                            ))
                  : circleLoading);
        });
  }
}
