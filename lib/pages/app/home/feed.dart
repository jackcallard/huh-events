import 'dart:ui';
import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_event.dart';
import 'package:app_v4/pages/database/database_invites.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/feed_info.dart';
import 'package:app_v4/pages/models/share.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/database/database_feed.dart';
import 'package:app_v4/pages/utilities/event_tile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with AutomaticKeepAliveClientMixin<Feed> {
  List<Widget> tileList = [];
  DatabaseFeed _dbf;
  bool first = true;
  bool firstTime = true;
  Map args;
  String uid;
  BasicData basicData;
  DatabaseInvites _dbi;
  List<Event> events;
  List<Share> invites;
  List<FeedInfo> feed;

  void _setUp(context) {
    basicData = Provider.of<BasicData>(context);
    _dbf = DatabaseFeed(uid: basicData.uid);
    _dbi = DatabaseInvites(basicData: basicData);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (first) _setUp(context);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(height: 40),
          StreamBuilder<List<Event>>(
              stream: _dbi.getInvites(),
              initialData: [],
              builder: (context, snapshot) {
                events = snapshot.data;
                return Visibility(
                  visible: events.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Invites',
                          style: TextStyle(
                            color: primary,
                            fontSize: 30,
                            fontFamily: font2,
                          ),
                        ),
                      ),
                      Container(
                        height: 400,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InviteTile(event: events[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
          StreamBuilder<List<Share>>(
              stream: _dbi.getShares(),
              initialData: [],
              builder: (context, snapshot) {
                invites = snapshot.data;
                return Visibility(
                  visible: invites.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Shared Events',
                          style: TextStyle(
                            color: primary,
                            fontSize: 30,
                            fontFamily: font2,
                          ),
                        ),
                      ),
                      Container(
                        height: 400,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: invites.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SharedTile(invite: invites[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
          StreamBuilder<List<FeedInfo>>(
            stream: _dbf.getFeed(),
            initialData: [],
            builder: (context, snapshot) {
              feed = snapshot.data;

              return Visibility(
                visible: feed.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Your Feed',
                        style: TextStyle(
                          color: primary,
                          fontSize: 30,
                          fontFamily: font2,
                        ),
                      ),
                    ),
                    Container(
                      height: 400,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FeedTile(feedInfo: feed[index]);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class InviteTile extends StatelessWidget {
  InviteTile({this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: <Widget>[
        Container(
          width: width - 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 10),
              InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, '/profile', arguments: {
                  'from_drawer': false,
                  'uid': event.basicData.uid,
                }),
                child: CircleAvatar(
                    backgroundColor: primary,
                    backgroundImage: NetworkImage(event.basicData.imageRef),
                    radius: 22),
              ),
              SizedBox(width: 10),
              Expanded(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                        TextSpan(
                          text: event.basicData.screenName,
                          style: textStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pushNamed(
                                    context, '/profile',
                                    arguments: {
                                      'from_drawer': false,
                                      'uid': event.basicData.uid,
                                    }),
                        ),
                        TextSpan(text: ' invited you to '),
                        TextSpan(
                          text: event.name,
                          style: linkStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pushNamed(
                                    context, '/event_page',
                                    arguments: {
                                      'event': event,
                                    }),
                        ),
                      ]),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        EventTile(event: event),
      ],
    );
  }
}

class SharedTile extends StatelessWidget {
  SharedTile({this.invite});

  final Share invite;
  final DatabaseEvent _dbe = DatabaseEvent();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return StreamBuilder<Event>(
        stream: _dbe.getEvent(invite.eventID),
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              Container(
                width: width - 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/profile', arguments: {
                        'from_drawer': false,
                        'uid': invite.basicData.uid,
                      }),
                      child: CircleAvatar(
                          backgroundColor: primary,
                          backgroundImage:
                              NetworkImage(invite.basicData.imageRef),
                          radius: 22),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            children: [
                              TextSpan(
                                text: invite.basicData.screenName,
                                style: textStyle,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pushNamed(
                                          context, '/profile',
                                          arguments: {
                                            'from_drawer': false,
                                            'uid': invite.basicData.uid,
                                          }),
                              ),
                              TextSpan(text: ' shared '),
                              TextSpan(
                                text:
                                    snapshot.hasData ? snapshot.data.name : '',
                                style: linkStyle,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = snapshot.hasData
                                      ? () => Navigator.pushNamed(
                                              context, '/event_page',
                                              arguments: {
                                                'event': snapshot.data,
                                              })
                                      : null,
                              ),
                            ]),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              EventTile(event: snapshot.data),
            ],
          );
        });
  }
}

class FeedTile extends StatelessWidget {
  FeedTile({this.feedInfo});
  final FeedInfo feedInfo;
  final DatabaseEvent _dbe = DatabaseEvent();

  String _getText() {
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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return StreamBuilder<Event>(
        stream: _dbe.getEvent(feedInfo.eventID),
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              Container(
                width: width - 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/profile', arguments: {
                        'from_drawer': false,
                        'uid': feedInfo.basicData.uid,
                      }),
                      child: CircleAvatar(
                          backgroundColor: primary,
                          backgroundImage:
                              NetworkImage(feedInfo.basicData.imageRef),
                          radius: 22),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            children: [
                              TextSpan(
                                text: feedInfo.basicData.screenName,
                                style: textStyle,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pushNamed(
                                          context, '/profile',
                                          arguments: {
                                            'from_drawer': false,
                                            'uid': feedInfo.basicData.uid,
                                          }),
                              ),
                              TextSpan(text: _getText()),
                              TextSpan(
                                text:
                                    snapshot.hasData ? snapshot.data.name : '',
                                style: linkStyle,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = snapshot.hasData
                                      ? () => Navigator.pushNamed(
                                              context, '/event_page',
                                              arguments: {
                                                'event': snapshot.data,
                                              })
                                      : null,
                              ),
                            ]),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              EventTile(event: snapshot.data),
            ],
          );
        });
  }
}
