import 'dart:async';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/database/database_user.dart';
import 'package:app_v4/pages/utilities/friend_bar.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Stream<ProfileData> _dataStream;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseUser _dbu;
  Map args = {};
  User user;
  bool fromDrawer;
  bool first = true;
  bool firsttime = true;

  ProfileData data;

  void _setUp(context) async {
    first = false;
    user = Provider.of<User>(context);
    args = ModalRoute.of(context).settings.arguments;
    _dbu = DatabaseUser(uid: user.uid);

    fromDrawer = args['from_drawer'];
    _dataStream = _dbu.profileStream(args['uid']);
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return StreamBuilder<ProfileData>(
        stream: _dataStream,
        builder: (context, snapshot) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.grey[100],
            key: scaffoldKey,
            drawer: fromDrawer
                ? MyDrawer(
                    loc: '/profile',
                  )
                : null,
            body: Stack(
              children: <Widget>[
                ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                    child: Container(
                      height: 240,
                      color: primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: 90),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              snapshot.hasData
                                  ? '@${snapshot.data.username}'
                                  : '',
                              style: TextStyle(
                                fontFamily: font2,
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(height: 180),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[600].withOpacity(0.7),
                                      spreadRadius: 4,
                                      blurRadius: 20,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 30),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    SizedBox(height: 60),
                                    Center(
                                      child: Text(
                                        snapshot.hasData
                                            ? snapshot.data.screenName
                                            : '',
                                        style: TextStyle(
                                          fontFamily: font3,
                                          fontSize: 20,
                                          color: primary,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        snapshot.hasData
                                            ? snapshot.data.type
                                            : '',
                                        style: TextStyle(
                                          fontFamily: font,
                                          fontSize: 15,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      snapshot.hasData ? snapshot.data.bio : '',
                                      style: TextStyle(
                                        fontFamily: font3,
                                        fontSize: 15,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    FlatButton(
                                        onPressed: snapshot.hasData
                                            ? () => Navigator.of(context)
                                                    .pushNamed(
                                                        '/user_events',
                                                        arguments: {
                                                      'uid': snapshot.data.uid
                                                    })
                                            : null,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.calendar_today,
                                              color: textColor,
                                              size: 20,
                                            ),
                                            SizedBox(width: 50),
                                            Text(
                                              'Events',
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontFamily: font3,
                                                  fontSize: 20),
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: textColor,
                                              size: 18,
                                            ),
                                          ],
                                        )),
                                    FlatButton(
                                        onPressed: snapshot.hasData
                                            ? () => Navigator.pushNamed(
                                                    context, '/friend_list',
                                                    arguments: {
                                                      'uid': snapshot.data.uid
                                                    })
                                            : null,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.account_circle,
                                              color: textColor,
                                              size: 22,
                                            ),
                                            SizedBox(width: 50),
                                            Text(
                                              'Friends',
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontFamily: font3,
                                                  fontSize: 20),
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: textColor,
                                              size: 18,
                                            ),
                                          ],
                                        )),
                                    FlatButton(
                                        onPressed: snapshot.hasData
                                            ? () => Navigator.pushNamed(
                                                    context, '/user_feed',
                                                    arguments: {
                                                      'uid': snapshot.data.uid
                                                    })
                                            : null,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.event,
                                              color: textColor,
                                              size: 22,
                                            ),
                                            SizedBox(width: 50),
                                            Text(
                                              'Feed',
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontFamily: font3,
                                                  fontSize: 20),
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: textColor,
                                              size: 18,
                                            ),
                                          ],
                                        )),
                                    SizedBox(height: 10),
                                    snapshot.hasData &&
                                            !snapshot.data.yourAccount
                                        ? FriendBar(profileData: snapshot.data)
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(height: 120),
                              Center(
                                  child: CircleAvatar(
                                radius: 62,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: primary,
                                  backgroundImage: snapshot.hasData &&
                                          snapshot.data.imageRef != null
                                      ? NetworkImage(snapshot.data.imageRef)
                                      : null,
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, top: 4),
                      child: IconButton(
                        icon: Icon(
                          fromDrawer ? Icons.menu : Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => fromDrawer
                            ? scaffoldKey.currentState.openDrawer()
                            : Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5, top: 4),
                      child: fromDrawer && snapshot.hasData
                          ? IconButton(
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                await Navigator.pushNamed(context, '/new_user',
                                    arguments: {
                                      'userData': snapshot.data,
                                      'first': false
                                    });
                              },
                            )
                          : Container(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
