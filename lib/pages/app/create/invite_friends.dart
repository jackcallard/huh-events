import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_relations.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseFriends extends StatefulWidget {
  @override
  _ChooseFriendsState createState() => _ChooseFriendsState();
}

class _ChooseFriendsState extends State<ChooseFriends> {
  Map args;
  Event event;
  DatabaseRelations _dbr;
  User user;
  bool first = true;

  void _setUp(context) {
    first = false;
    args = ModalRoute.of(context).settings.arguments;
    user = Provider.of<User>(context);
    _dbr = DatabaseRelations(uid: user.uid);
    event = args['event'];
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Text(
                  'Select who is invited',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<String>>(
                  future: _dbr.getAllFriends(),
                  initialData: [],
                  builder: (context, snapshot) {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border:
                                Border.all(color: Colors.grey[300], width: 2)),
                        child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return FlatButton(
                                onPressed: () {
                                  var userID = snapshot.data[index];
                                  if (event.invited.contains(userID)) {
                                    setState(
                                        () => event.invited.remove(userID));
                                  } else {
                                    setState(() => event.invited
                                        .add(snapshot.data[index]));
                                  }
                                },
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: SelectTile(
                                        userID: snapshot.data[index],
                                      ),
                                    ),
                                    Checkbox(
                                        value: event.invited
                                            .contains(snapshot.data[index]),
                                        onChanged: null)
                                  ],
                                ),
                              );
                            }),
                      ),
                    );
                  }),
              SizedBox(height: 10),
              RaisedButton(
                textColor: Colors.white,
                color: primary,
                child: Text('Next'),
                onPressed: () {
                  event.going = [];
                  event.square = [];
                  Navigator.pushNamed(context, '/preview',
                      arguments: {'event': event});
                },
              ),
            ],
          ),
        ));
  }
}
