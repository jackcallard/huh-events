import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/feed_info.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/database/database_feed.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserFeed extends StatefulWidget {
  @override
  _UserFeedState createState() => _UserFeedState();
}

class _UserFeedState extends State<UserFeed> {
  List<Widget> tileList = [];
  DatabaseFeed _dbf;
  bool first = true;
  bool firstTime = true;
  Map args;
  String uid;
  User user;

  String _getText(FeedInfo feedInfo) {
    switch (feedInfo.status) {
      case AttendStatus.going:
        return ' is going to ';
      case AttendStatus.hosting:
        return ' is hosting ';
      case AttendStatus.interested:
        return ' is interested in ';
      default:
        return ' is looking at ';
    }
  }

  Widget _formTile(FeedInfo feedInfo) {
    return Row(
      children: <Widget>[
        Text('${feedInfo.basicData.screenName}${_getText(feedInfo)}'),
        InkWell(
            onTap: () => Navigator.pushNamed(context, '/event_page',
                    arguments: {
                      'eventID': feedInfo.eventID,
                      'dateTime': feedInfo.timestamp.toDate()
                    }),
            child: Text(feedInfo.eventID)),
      ],
    );
  }

  void _setUp(context) {
    user = Provider.of<User>(context);
    _dbf = DatabaseFeed(uid: user.uid);
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
      body: StreamBuilder<List<FeedInfo>>(
          stream: _dbf.getUserFeed(uid),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _formTile(snapshot.data[index]);
                    },
                  )
                : circleLoading;
          }),
    );
  }
}
