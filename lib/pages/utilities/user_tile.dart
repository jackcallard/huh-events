import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_invites.dart';
import 'package:app_v4/pages/database/database_relations.dart';
import 'package:app_v4/pages/database/database_user.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  const UserTile({@required this.basicData});
  final BasicData basicData;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
            backgroundColor: primary,
            backgroundImage:
                basicData == null ? null : NetworkImage(basicData.imageRef),
            radius: 20),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              basicData == null ? '' : basicData.screenName,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Text(
              basicData == null ? '' : basicData.username,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
        Spacer(),
      ],
    );
  }
}

class SelectTile extends StatefulWidget {
  const SelectTile({this.userID});
  final String userID;

  @override
  _SelectTileState createState() => _SelectTileState();
}

class _SelectTileState extends State<SelectTile> {
  bool first = true;
  DatabaseUser _dbu;
  User user;
  Future<BasicData> basicData;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    _dbu = DatabaseUser(uid: user.uid);
    return FutureBuilder<BasicData>(
        future: _dbu.getData(widget.userID).first,
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: UserTile(basicData: snapshot.data),
              ),
            ],
          );
        });
  }
}

class BasicTile extends StatefulWidget {
  const BasicTile({this.userID});
  final String userID;

  @override
  _BasicTileState createState() => _BasicTileState();
}

class _BasicTileState extends State<BasicTile> {
  bool first = true;
  DatabaseUser _dbu;
  User user;
  Future<BasicData> basicData;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    _dbu = DatabaseUser(uid: user.uid);
    return FutureBuilder<BasicData>(
        future: _dbu.getData(widget.userID).first,
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              FlatButton(
                  onPressed: !snapshot.hasData
                      ? null
                      : () =>
                          Navigator.pushNamed(context, '/profile', arguments: {
                            'from_drawer': false,
                            'uid': snapshot.data.uid,
                          }),
                  child: UserTile(basicData: snapshot.data)),
            ],
          );
        });
  }
}

class BasicDataTile extends StatelessWidget {
  BasicDataTile({this.basicData});
  final BasicData basicData;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
            onPressed: basicData == null
                ? null
                : () => Navigator.pushNamed(context, '/profile', arguments: {
                      'from_drawer': false,
                      'uid': basicData.uid,
                    }),
            child: UserTile(basicData: basicData)),
      ],
    );
  }
}

class RequestTile extends StatefulWidget {
  const RequestTile({this.userID, this.basicData});

  final String userID;
  final BasicData basicData;

  @override
  _RequestTileState createState() => _RequestTileState();
}

class _RequestTileState extends State<RequestTile> {
  bool accepted = false;
  bool declined = false;
  bool first = true;
  DatabaseUser _dbu;
  User user;
  BasicData basicData;
  DatabaseRelations _dbr;

  void _setUp(context) async {
    first = false;
    user = Provider.of<User>(context);
    _dbu = DatabaseUser(uid: user.uid);
    _dbr = DatabaseRelations(uid: user.uid);
    if (widget.basicData == null) {
      var bd = await _dbu.getData(widget.userID).first;
      setState(() => basicData = bd);
    } else {
      basicData = widget.basicData;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: FlatButton(
              onPressed: basicData == null
                  ? null
                  : () => Navigator.pushNamed(context, '/profile',
                      arguments: {'from_drawer': false, 'uid': basicData.uid}),
              child: UserTile(basicData: basicData)),
        ),
        Row(
          children: <Widget>[
            SizedBox(width: 50),
            Expanded(
              child: FlatButton(
                child: Text(
                  accepted ? 'Accepted' : 'Accept',
                  style: TextStyle(fontSize: 12),
                ),
                color: primary,
                disabledColor: Colors.grey[200],
                textColor: Colors.white,
                onPressed: !accepted && !declined && basicData != null
                    ? () {
                        _dbr.addFriend(basicData.uid);
                        setState(() => accepted = true);
                      }
                    : null,
                splashColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: OutlineButton(
                child: Text(
                  declined ? 'Declined' : 'Decline',
                  style: TextStyle(fontSize: 12),
                ),
                onPressed: !accepted && !declined && basicData != null
                    ? () {
                        _dbr.removeFriend(basicData.uid);
                        setState(() => declined = true);
                      }
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
            SizedBox(width: 50),
          ],
        ),
      ],
    );
  }
}

class ShareTile extends StatefulWidget {
  const ShareTile({@required this.userID, @required this.event});
  final Event event;
  final String userID;

  @override
  _ShareTileState createState() => _ShareTileState();
}

class _ShareTileState extends State<ShareTile> {
  bool invited = false;
  bool first = true;
  bool loading = true;
  DatabaseInvites _dbi;
  BasicData basicData;

  void _setUp(context) async {
    basicData = Provider.of<BasicData>(context);
    _dbi = DatabaseInvites(basicData: basicData);
    invited = await _dbi.shared(widget.userID, widget.event);
    setState(() => loading = false);
    first = false;
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return Row(
      children: <Widget>[
        Expanded(
            child: BasicTile(
          userID: widget.userID,
        )),
        Container(
          width: 100,
          child: FlatButton.icon(
            color: invited ? Colors.white : Colors.red[200],
            onPressed: loading || widget.event.id == null
                ? null
                : invited
                    ? () {
                        setState(() => invited = false);
                        _dbi.unshare(widget.userID, widget.event);
                      }
                    : () {
                        setState(() => invited = true);
                        _dbi.share(widget.userID, widget.event);
                      },
            icon: Icon(
              Icons.send,
              color: invited ? Colors.red[200] : Colors.white,
              size: 16,
            ),
            disabledColor: Colors.grey[200],
            label: Text(
              invited ? 'Shared' : 'Share',
              style: TextStyle(color: invited ? Colors.red[200] : Colors.white),
            ),
            shape: RoundedRectangleBorder(
              side: invited
                  ? BorderSide(width: 1, color: Colors.red[200])
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        )
      ],
    );
  }
}
