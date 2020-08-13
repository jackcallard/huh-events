import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_invites.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/database/database_feed.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AttendingBar extends StatefulWidget {
  const AttendingBar({@required this.event});
  final Event event;

  @override
  _AttendingBarState createState() => _AttendingBarState();
}

class _AttendingBarState extends State<AttendingBar> {
  bool first = true;
  BasicData bd;

  Future<AttendStatus> _attendStatus;
  DatabaseFeed _dbf;
  AttendStatus _attending;
  Tuple3<Color, Color, BorderSide> _goColors;
  Tuple3<Color, Color, BorderSide> _intColors;
  User user;

  void _setUp(context) {
    user = Provider.of<User>(context);
    _dbf = DatabaseFeed(uid: user.uid);
    _attendStatus =
        widget.event == null ? null : _dbf.getStatus(widget.event.id);
    _goColors = _getGoColors();
    _intColors = _getIntColors();
    first = false;
  }

  bool firstTime = true;

  Tuple3<Color, Color, BorderSide> _getGoColors() {
    if (_attending == AttendStatus.going) {
      return Tuple3(
          Colors.white, primary, BorderSide(color: primary, width: 2));
    } else {
      return Tuple3(primary, Colors.white, BorderSide.none);
    }
  }

  Tuple3<Color, Color, BorderSide> _getIntColors() {
    if (_attending == AttendStatus.interested) {
      return Tuple3(
          Colors.white, primary, BorderSide(color: primary, width: 2));
    } else {
      return Tuple3(Colors.white, Colors.grey[600],
          BorderSide(color: Colors.grey[400], width: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    bd = Provider.of<BasicData>(context);
    if (first) _setUp(context);
    return FutureBuilder<AttendStatus>(
        future: _attendStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData && firstTime) {
            firstTime = false;
            _attending = snapshot.data;
            _goColors = _getGoColors();
            _intColors = _getIntColors();
          }
          return Row(
            children: <Widget>[
              SizedBox(width: 30),
              Expanded(
                child: FlatButton(
                  child: Text('Going'),
                  color: _goColors.item1,
                  textColor: _goColors.item2,
                  onPressed:
                      snapshot.hasData && _attending != AttendStatus.hosting
                          ? () {
                              if (_attending != AttendStatus.going) {
                                setState(() {
                                  _attending = AttendStatus.going;
                                  _goColors = _getGoColors();
                                  _intColors = _getIntColors();
                                });
                                _dbf.setStatus(widget.event, 'going', bd);
                              } else {
                                setState(() {
                                  _attending = AttendStatus.none;
                                  _goColors = _getGoColors();
                                  _intColors = _getIntColors();
                                });
                                _dbf.removeStatus(widget.event.id);
                              }
                            }
                          : null,
                  splashColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                      side: _goColors.item3,
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: FlatButton(
                  color: _intColors.item1,
                  textColor: _intColors.item2,
                  child: Text('Interested'),
                  onPressed:
                      snapshot.hasData && _attending != AttendStatus.hosting
                          ? () {
                              if (_attending != AttendStatus.interested) {
                                setState(() {
                                  _attending = AttendStatus.interested;
                                  _intColors = _getIntColors();
                                  _goColors = _getGoColors();
                                });
                                _dbf.setStatus(widget.event, 'interested', bd);
                              } else {
                                setState(() {
                                  _attending = AttendStatus.none;
                                  _intColors = _getIntColors();
                                  _goColors = _getGoColors();
                                });
                                _dbf.removeStatus(widget.event.id);
                              }
                            }
                          : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: _intColors.item3,
                  ),
                ),
              ),
              SizedBox(width: 30),
            ],
          );
        });
  }
}

class InvitedBar extends StatefulWidget {
  const InvitedBar({@required this.event});
  final Event event;

  @override
  _InvitedBarState createState() => _InvitedBarState();
}

class _InvitedBarState extends State<InvitedBar> {
  bool first = true;
  BasicData bd;

  DatabaseInvites _dbi;
  PrivateStatus _attending;
  Tuple3<Color, Color, BorderSide> _thereColors;
  Tuple3<Color, Color, BorderSide> _squareColors;
  BasicData basicData;
  List<String> going;
  List<String> square;

  void _setUp(context) {
    basicData = Provider.of<BasicData>(context);
    _dbi = DatabaseInvites(basicData: basicData);
    going = widget.event.going;
    square = widget.event.square;
    if (going.contains(basicData.uid)) {
      _attending = PrivateStatus.going;
    } else if (square.contains(basicData.uid)) {
      _attending = PrivateStatus.square;
    } else {
      _attending = PrivateStatus.none;
    }
    _thereColors = _getThereColors();
    _squareColors = _getSquareColors();
    first = false;
  }

  bool firstTime = true;

  Tuple3<Color, Color, BorderSide> _getThereColors() {
    if (_attending == PrivateStatus.going) {
      return Tuple3(
          Colors.white, primary, BorderSide(color: primary, width: 2));
    } else {
      return Tuple3(primary, Colors.white, BorderSide.none);
    }
  }

  Tuple3<Color, Color, BorderSide> _getSquareColors() {
    if (_attending == PrivateStatus.square) {
      return Tuple3(
          Colors.white, primary, BorderSide(color: primary, width: 2));
    } else {
      return Tuple3(Colors.white, Colors.grey[600],
          BorderSide(color: Colors.grey[400], width: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    bd = Provider.of<BasicData>(context);
    if (first) _setUp(context);
    return Row(
      children: <Widget>[
        SizedBox(width: 30),
        Expanded(
          child: FlatButton(
            child: Text("I'm There!"),
            color: _thereColors.item1,
            textColor: _thereColors.item2,
            onPressed: () {
              if (_attending == PrivateStatus.going) {
                setState(() {
                  _attending = PrivateStatus.none;
                  _thereColors = _getThereColors();
                  _squareColors = _getSquareColors();
                });
                _dbi.removeGoing(widget.event);
              } else {
                setState(() {
                  _attending = PrivateStatus.going;
                  _thereColors = _getThereColors();
                  _squareColors = _getSquareColors();
                });
                _dbi.setGoing(widget.event);
              }
            },
            splashColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
                side: _thereColors.item3,
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: FlatButton(
            color: _squareColors.item1,
            textColor: _squareColors.item2,
            child: Text("I'm Square :("),
            onPressed: () {
              if (_attending == PrivateStatus.square) {
                setState(() {
                  _attending = PrivateStatus.none;
                  _thereColors = _getThereColors();
                  _squareColors = _getSquareColors();
                });
                _dbi.removeSquare(widget.event);
              } else {
                setState(() {
                  _attending = PrivateStatus.square;
                  _thereColors = _getThereColors();
                  _squareColors = _getSquareColors();
                });
                _dbi.setSquare(widget.event);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: _squareColors.item3,
            ),
          ),
        ),
        SizedBox(width: 30),
      ],
    );
  }
}
