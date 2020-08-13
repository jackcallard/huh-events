import 'package:app_v4/pages/database/database_event.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/attendance.dart';
import 'package:app_v4/pages/utilities/attending_bar.dart';
import 'package:app_v4/pages/utilities/share_friends.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  EventPage({this.event});
  final Event event;
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Map args = {};
  Event event;
  bool loading = false;

  bool firstTime = true;
  final DatabaseEvent _dbe = DatabaseEvent();
  String eventID;
  User user;
  Size size;

  Future<ProfileData> data;

  List<String> invited;

  void setUp(context) async {
    size = MediaQuery.of(context).size;
    user = Provider.of<User>(context);
    args = ModalRoute.of(context).settings.arguments;
    event = args['event'] ?? widget.event;
    if (event == null) {
      eventID = args['eventID'];
      loading = true;
      event = await _dbe.getEvent(eventID).first;
      setState(() => loading = false);
    }

    firstTime = false;
  }

  @override
  Widget build(BuildContext context) {
    if (firstTime) setUp(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          loading
              ? circleLoading
              : SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: size.width,
                        height: size.width / widthToHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          image: DecorationImage(
                            image: event.imageFile == null
                                ? NetworkImage(event.imageRef)
                                : FileImage(event.imageFile),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.start,
                          children: <Widget>[
                            Text(
                              event.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: font2,
                                fontSize: 26,
                              ),
                            ),
                            SizedBox(width: 10),
                            event.private
                                ? Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 18,
                                    width: 88,
                                    decoration: BoxDecoration(
                                      color: Colors.red[200],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(
                                          'Private',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: font2),
                                        ),
                                        Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          event.organization,
                          style: TextStyle(
                            fontFamily: font3,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      EventBottom(event: event),
                    ],
                  ),
                ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: textColor),
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ),
          Visibility(
            visible: !loading &&
                event.userID == user.uid &&
                event.id != null &&
                event.timestamp.compareTo(Timestamp.now()) > 0,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.edit, color: textColor),
                  onPressed: () => Navigator.of(context).pushNamed(
                      '/event_creation',
                      arguments: {'event': event.clone()}),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventBottom extends StatelessWidget {
  EventBottom({
    Key key,
    @required this.event,
  }) : super(key: key);
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              TabBar(
                labelColor: primary,
                tabs: <Widget>[Text('Details'), Text('Summary')],
                indicatorColor: Colors.transparent,
                unselectedLabelColor: Colors.grey[400],
                unselectedLabelStyle: TextStyle(
                    fontSize: 21,
                    fontFamily: font2,
                    fontWeight: FontWeight.bold),
                labelStyle: TextStyle(
                    fontSize: 21,
                    fontFamily: font2,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 150,
                child: TabBarView(
                  children: <Widget>[
                    DetailSide(event: event),
                    SummarySide(event: event),
                  ],
                ),
              )
            ],
          ),
        ),
        Column(
          children: <Widget>[
            event.private
                ? InvitedBar(event: event)
                : AttendingBar(event: event),
            event.private
                ? Attendance(event: event)
                : ShareFriends(event: event),
          ],
        ),
      ],
    );
  }
}

class DetailSide extends StatelessWidget {
  DetailSide({this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              SizedBox(width: 25),
              Icon(
                Icons.location_on,
                color: Colors.grey[500],
              ),
              SizedBox(width: 25),
              Column(
                children: <Widget>[
                  Container(
                      width: 250,
                      child: Text(
                        event.venue,
                        style: TextStyle(fontSize: 16),
                      )),
                  Container(
                      width: 250,
                      child: Text(
                        event.address,
                        style: TextStyle(color: Colors.grey[600]),
                      )),
                ],
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              SizedBox(width: 25),
              Icon(
                Icons.calendar_today,
                color: Colors.grey[500],
              ),
              SizedBox(width: 25),
              Column(
                children: <Widget>[
                  Container(
                      width: 250,
                      child: Text(
                        dateTimeFormat(event.timestamp.toDate()),
                        style: TextStyle(fontSize: 16),
                      )),
                  Container(
                      width: 250,
                      child: Text(
                        TimeOfDay.fromDateTime(event.timestamp.toDate())
                            .format(context),
                        style: TextStyle(color: Colors.grey[600]),
                      )),
                ],
              )
            ],
          ),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}

class SummarySide extends StatelessWidget {
  SummarySide({this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 3, 10, 0),
          child: Text(
            event.summary,
            style: TextStyle(
              fontFamily: font3,
              fontSize: 15,
              color: textColor,
            ),
          ),
        ),
        Spacer(),
        SizedBox(height: 10),
        BasicDataTile(basicData: event.basicData),
        SizedBox(height: 10),
      ],
    );
  }
}
