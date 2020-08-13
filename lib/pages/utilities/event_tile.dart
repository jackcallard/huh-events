import 'package:flutter/material.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/constants.dart';

class EventTile extends StatelessWidget {
  EventTile({this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width - 50,
      height: (width - 50),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          onTap: event == null
              ? null
              : () => Navigator.of(context)
                  .pushNamed('/event_page', arguments: {'event': event}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: width - 50,
                height: (width - 50) / widthToHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: event == null
                      ? null
                      : DecorationImage(
                          image: NetworkImage(event.imageRef),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    Text(
                      event == null
                          ? ''
                          : dateTimeFormat(event.timestamp.toDate()),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: primary,
                        fontFamily: font3,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      event == null
                          ? ''
                          : TimeOfDay.fromDateTime(event.timestamp.toDate())
                              .format(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: primary,
                        fontFamily: font3,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  event == null ? '' : event.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: font2,
                    fontSize: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  event == null ? '' : event.organization,
                  style: TextStyle(
                    fontFamily: font3,
                    fontSize: 17,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
