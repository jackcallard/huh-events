import 'dart:async';
import 'package:app_v4/pages/database/database_relations.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class FriendBar extends StatefulWidget {
  FriendBar({this.profileData});
  final ProfileData profileData;

  @override
  _FriendBarState createState() => _FriendBarState();
}

class _FriendBarState extends State<FriendBar> {
  FriendStatus friendStatus;
  FavoriteStatus favoriteStatus;
  Tuple4<Color, Color, BorderSide, String> friendButtonData;
  Tuple4<Color, Color, BorderSide, String> favoriteButtonData;
  bool first = true;
  DatabaseRelations _dbr;
  User user;

  Tuple4<Color, Color, BorderSide, String> getFriendButtonData() {
    switch (friendStatus) {
      case FriendStatus.requested:
        return Tuple4(Colors.white, Colors.blue,
            BorderSide(color: Colors.blue, width: 2), 'Requested');
      case FriendStatus.friends:
        return Tuple4(Colors.white, primary,
            BorderSide(color: primary, width: 2), 'Friends');
      default:
        return Tuple4(primary, Colors.white, BorderSide.none, 'Request');
    }
  }

  Tuple4<Color, Color, BorderSide, String> getFavoriteButtonData() {
    switch (favoriteStatus) {
      case FavoriteStatus.favorite:
        return Tuple4(Colors.white, primary,
            BorderSide(color: primary, width: 2), 'Favorited');
      default:
        return Tuple4(Colors.white, Colors.grey[600],
            BorderSide(color: Colors.grey[400], width: 1), 'Favorite');
    }
  }

  void pressFriendButton(ProfileData friendData) async {
    switch (friendStatus) {
      case FriendStatus.none:
        setState(() {
          friendStatus = FriendStatus.requested;
          friendButtonData = getFriendButtonData();
        });
        await _dbr.requestFriend(friendData.uid);
        break;
      case FriendStatus.friends:
        await _showAlert(friendData.screenName, friendData.uid);
        break;
      case FriendStatus.requested:
        setState(() {
          friendStatus = FriendStatus.none;
          friendButtonData = getFriendButtonData();
        });
        await _dbr.removeFriend(friendData.uid);
        break;
      case FriendStatus.request:
        break;
    }
  }

  void pressFavoriteButton(ProfileData friendData) async {
    switch (favoriteStatus) {
      case FavoriteStatus.none:
        setState(() {
          favoriteStatus = FavoriteStatus.favorite;
          favoriteButtonData = getFavoriteButtonData();
        });
        await _dbr.addFavorite(friendData.uid);
        break;
      case FavoriteStatus.favorite:
        setState(() {
          favoriteStatus = FavoriteStatus.none;
          favoriteButtonData = getFavoriteButtonData();
        });
        await _dbr.removeFavorite(friendData.uid);
        break;
    }
  }

  Future<void> _showAlert(String screenName, String uid) async {
    return showDialog<void>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unfriend $screenName'),
          content: SingleChildScrollView(
            child: Text(
                'Are you sure you want to unfriend $screenName? You will no longer be notified of events they are going to.'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  friendStatus = FriendStatus.none;
                  friendButtonData = getFriendButtonData();
                });
                _dbr.removeFriend(uid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setUp(context) {
    first = false;
    user = Provider.of<User>(context);
    _dbr = DatabaseRelations(uid: user.uid);
    favoriteButtonData = getFriendButtonData();
    friendButtonData = getFriendButtonData();
  }

  bool firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return FutureBuilder<Tuple2>(
        future: _dbr.getStatus(widget.profileData.uid),
        builder: (context, statusSnap) {
          if (statusSnap.hasData && firstTime) {
            friendStatus = statusSnap.data.item1;
            favoriteStatus = statusSnap.data.item2;
            friendButtonData = getFriendButtonData();
            favoriteButtonData = getFavoriteButtonData();
            firstTime = false;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 20),
              Expanded(
                child: FlatButton(
                  child: Text(friendButtonData.item4),
                  color: friendButtonData.item1,
                  disabledColor: Colors.grey[200],
                  textColor: friendButtonData.item2,
                  onPressed: statusSnap.hasData
                      ? () => pressFriendButton(widget.profileData)
                      : null,
                  splashColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                      side: friendButtonData.item3,
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: FlatButton(
                  textColor: favoriteButtonData.item2,
                  child: Text(favoriteButtonData.item4),
                  color: favoriteButtonData.item1,
                  onPressed: statusSnap.hasData
                      ? () => pressFavoriteButton(widget.profileData)
                      : null,
                  shape: RoundedRectangleBorder(
                      side: favoriteButtonData.item3,
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
              SizedBox(width: 20),
            ],
          );
        });
  }
}
