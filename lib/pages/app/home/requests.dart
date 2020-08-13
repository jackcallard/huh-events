import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestList extends StatefulWidget {
  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  List<String> requests;
  Map args = {};
  List<int> accepted = [];
  List<int> declined = [];
  bool first = true;
  User user;

  void _setUp(context) {
    first = false;
    user = Provider.of<User>(context);
    args = ModalRoute.of(context).settings.arguments;
    requests = args['requests'];
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[600]),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: requests.isEmpty
                ? Center(
                    child: Text(
                    'No requests at the moment.',
                    style: TextStyle(
                        fontFamily: font2,
                        color: Colors.grey[600],
                        fontSize: 20),
                  ))
                : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, ind) {
                      return RequestTile(userID: requests[ind]);
                    },
                  )));
  }
}
