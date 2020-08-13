import 'package:app_v4/pages/app/event_page.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EventPanel extends StatefulWidget {
  EventPanel({this.event});
  final Event event;
  @override
  _EventPanelState createState() => _EventPanelState();
}

class _EventPanelState extends State<EventPanel> {
  Map args = {};
  User user;
  Event event;

  bool firstTime = true;
  Size size;

  void setUp(context) {
    user = Provider.of<User>(context);
    event = widget.event;
    firstTime = false;
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    if (firstTime || widget.event.id != event.id) setUp(context);

    return SlidingUpPanel(
      panelBuilder: (sc) => SingleChildScrollView(
        controller: sc,
        child: DefaultTabController(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 100,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: font2,
                        fontSize: 27,
                      ),
                    ),
                    Text(
                      event.organization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: font3,
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: (size.width - 30),
                  height: (size.width - 30) / widthToHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: event.imageRef == null
                          ? FileImage(event.imageFile)
                          : NetworkImage(event.imageRef),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              EventBottom(event: event),
            ],
          ),
          length: 2,
        ),
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      maxHeight: 575,
    );
  }
}

class DetailSide extends StatelessWidget {
  DetailSide({@required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Spacer(),
            Icon(
              Icons.location_on,
              color: Colors.grey[500],
            ),
            Spacer(),
            Column(
              children: <Widget>[
                Container(
                    width: 200,
                    child: Text(
                      event.venue,
                      style: TextStyle(fontSize: 16),
                    )),
                Container(
                    width: 200,
                    child: Text(
                      event.address,
                      style: TextStyle(color: Colors.grey[600]),
                    )),
              ],
            ),
            Spacer(flex: 2)
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Spacer(),
            Icon(
              Icons.calendar_today,
              color: Colors.grey[500],
            ),
            Spacer(),
            Column(
              children: <Widget>[
                Container(
                    width: 200,
                    child: Text(
                      dateTimeFormat(event.timestamp.toDate()),
                      style: TextStyle(fontSize: 16),
                    )),
                Container(
                    width: 200,
                    child: Text(
                      TimeOfDay.fromDateTime(event.timestamp.toDate())
                          .format(context),
                      style: TextStyle(color: Colors.grey[600]),
                    )),
              ],
            ),
            Spacer(flex: 2),
          ],
        ),
        SizedBox(height: 20)
      ],
    );
  }
}

class SummarySide extends StatelessWidget {
  SummarySide({@required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Text(
          event.summary,
          style: TextStyle(
            fontFamily: font3,
            fontSize: 20,
            color: textColor,
          ),
        ),
        SizedBox(height: 10),
        FlatButton(
          onPressed: () => Navigator.pushNamed(context, '/profile', arguments: {
            'from_drawer': false,
            'uid': event.basicData.uid,
          }),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(flex: 1),
              CircleAvatar(
                  backgroundColor: primary,
                  backgroundImage: event.basicData.imageRef != null
                      ? NetworkImage(event.basicData.imageRef)
                      : null,
                  radius: 20),
              Spacer(flex: 1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.basicData.screenName,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  Text(
                    event.basicData.username,
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                ],
              ),
              Spacer(flex: 10),
            ],
          ),
        ),
      ],
    );
  }
}
