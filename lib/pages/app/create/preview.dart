import 'package:app_v4/pages/app/event_page.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_event.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:flutter/material.dart';

class Preview extends StatefulWidget {
  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  Map args;
  Event event;
  bool loading = false;
  Function pop;
  final DatabaseEvent _dbe = DatabaseEvent();

  void submit() async {
    setState(() => loading = true);
    if (event.id != null && event.private) {
      await _dbe.updatePrivateEvent(event);
    } else if (event.id != null && !event.private) {
      await _dbe.updatePublicEvent(event);
    } else if (event.private) {
      await _dbe.setPrivateEventData(event);
    } else {
      await _dbe.setPublicEventData(event);
    }
    setState(() {
      loading = false;
    });
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success!'),
            content: SingleChildScrollView(
              child: Text(
                  'Your event has been ${event.id != null ? 'updated!' : 'submitted!'}'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                  pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    event = args['event'];
    pop = () => Navigator.of(context).popUntil(ModalRoute.withName('/home'));
    return Scaffold(
      body: Stack(
        children: <Widget>[
          EventPage(event: event),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 175,
                padding: const EdgeInsets.all(15),
                child: FloatingActionButton.extended(
                  backgroundColor: loading ? Colors.grey[200] : Colors.white,
                  disabledElevation: 0,
                  onPressed: loading ? null : submit,
                  label: loading
                      ? buttonLoading
                      : Text(
                          event.id == null ? 'Submit' : 'Update',
                          style: TextStyle(color: primary),
                        ),
                  icon: loading ? null : Icon(Icons.send, color: primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
