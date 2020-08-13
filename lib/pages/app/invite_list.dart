import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_invites.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/utilities/event_tile.dart';
import 'package:provider/provider.dart';

class InviteEvents extends StatefulWidget {
  @override
  _InviteEventsState createState() => _InviteEventsState();
}

class _InviteEventsState extends State<InviteEvents> {
  DatabaseInvites _dbi;
  BasicData basicData;
  @override
  Widget build(BuildContext context) {
    basicData = Provider.of<BasicData>(context);
    _dbi = DatabaseInvites(basicData: basicData);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: background,
          iconTheme: IconThemeData(color: textColor),
        ),
        drawer: MyDrawer(
          loc: '/invite_list',
        ),
        body: StreamBuilder<List<List<Event>>>(
            stream: _dbi.getSortedInvites(),
            initialData: [[], [], []],
            builder: (context, snapshot) {
              return DefaultTabController(
                length: 3,
                child: Column(
                  children: <Widget>[
                    TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.transparent,
                      labelStyle: TextStyle(
                        fontFamily: font2,
                        fontSize: 25,
                      ),
                      labelColor: primary,
                      unselectedLabelColor: Colors.grey[500],
                      tabs: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text('Declined'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 5.0,
                          ),
                          child: Text('Accepted'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text('Active'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          Invites(events: snapshot.data[0], loc: 'Declined'),
                          Invites(
                            events: snapshot.data[1],
                            loc: 'Accepted',
                          ),
                          Invites(events: snapshot.data[2], loc: 'Active'),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }));
  }
}

class Invites extends StatefulWidget {
  Invites({@required this.events, @required this.loc});
  final List<Event> events;
  final String loc;

  @override
  _InvitesState createState() => _InvitesState();
}

class _InvitesState extends State<Invites> {
  BasicData basicData;
  List<Event> events;
  @override
  Widget build(BuildContext context) {
    events = widget.events;
    return events.isEmpty
        ? Center(
            child: Text('No ${widget.loc} Invites'),
          )
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/profile',
                              arguments: {
                                'from_drawer': false,
                                'uid': events[index].basicData.uid,
                              }),
                          child: CircleAvatar(
                              backgroundColor: primary,
                              backgroundImage: NetworkImage(
                                  events[index].basicData.imageRef),
                              radius: 22),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () => Navigator.pushNamed(
                                    context, '/profile',
                                    arguments: {
                                      'from_drawer': false,
                                      'uid': events[index].basicData.uid,
                                    }),
                                child: Text(
                                  events[index].basicData.screenName,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                ' invited you to ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                              InkWell(
                                onTap: () => Navigator.pushNamed(
                                    context, '/event_page',
                                    arguments: {
                                      'event': events[index],
                                    }),
                                child: Text(
                                  events[index].name,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  EventTile(event: events[index]),
                ],
              );
            },
          );
  }
}
