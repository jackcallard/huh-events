import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PublicPrivate extends StatefulWidget {
  @override
  _PublicPrivateState createState() => _PublicPrivateState();
}

class _PublicPrivateState extends State<PublicPrivate> {
  Map args;
  BasicData basicData;
  bool fromDrawer;
  Event event = Event(invited: []);
  @override
  Widget build(BuildContext context) {
    basicData = Provider.of<BasicData>(context);
    args = ModalRoute.of(context).settings.arguments;
    fromDrawer = args['from_drawer'];
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
      ),
      drawer: fromDrawer
          ? MyDrawer(
              loc: '/create_event',
            )
          : null,
      body: Column(
        children: <Widget>[
          FlatButton(
            onPressed: () async {
              event.private = true;
              event.basicData = basicData;
              event.userID = basicData.uid;
              var e = await Navigator.pushNamed(context, '/event_creation',
                  arguments: {'event': event});
              event = e ?? event;
            },
            child: ListTile(
              leading: Icon(Icons.lock),
              isThreeLine: true,
              title: Text('Private Event'),
              subtitle: Text(
                  'Only friends you invite will be able to see the event.'),
            ),
          ),
          FlatButton(
            onPressed: () async {
              event.private = false;
              event.basicData = basicData;
              event.userID = basicData.uid;
              var e = await Navigator.pushNamed(context, '/event_creation',
                  arguments: {'event': event});
              event = e ?? event;
            },
            child: ListTile(
              leading: Icon(Icons.map),
              isThreeLine: true,
              title: Text('Public Event'),
              subtitle: Text('Your event will be open to the public'),
            ),
          )
        ],
      ),
    );
  }
}
