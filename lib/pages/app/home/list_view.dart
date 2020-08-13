import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/google_property/flutter_places.dart';
import 'package:app_v4/pages/database/database_event.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/utilities/event_tile.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:numberpicker/numberpicker.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Widget> eventList;
  List<Event> events = [];
  bool first = true;
  List<DateTime> dateRange;
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: placesKey);
  Location location;
  final DatabaseEvent _dbe = DatabaseEvent();

  Widget _formEvent(Event e) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: EventTile(event: e),
    );
  }

  Future<void> _showPicker() async {
    return showDialog<int>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return NumberPickerDialog.integer(
          title: Text('Choose Radius'),
          step: 5,
          minValue: 5,
          maxValue: 50,
          initialIntegerValue: miles,
        );
      },
    ).then((int value) => setState(() {
          miles = value ?? miles;
          changed = true;
        }));
  }

  void _setUp(context) {
    dateRange = Provider.of<List<DateTime>>(context);
    first = false;
  }

  bool showFilter = true;

  int miles = 5;
  String address = 'Choose Location';
  List<Icon> icons = [
    Icon(Icons.arrow_upward, color: textColor),
    Icon(Icons.arrow_downward, color: textColor)
  ];
  int index = 0;
  bool changed = false;

  @override
  Widget build(BuildContext context) {
    if (location != null &&
        (dateRange != Provider.of<List<DateTime>>(context) || changed)) {
      dateRange = Provider.of<List<DateTime>>(context);
      changed = false;
      _dbe.getListEvents(
          location.lat,
          location.lng,
          miles * 1.5,
          dateRange.first,
          dateRange.last,
          (newEvents) => setState(() => events = newEvents));
    }

    if (first) _setUp(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Visibility(
          visible: showFilter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              runSpacing: 10,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  'Events Within',
                  style: TextStyle(
                      color: textColor, fontSize: 20, fontFamily: font3),
                ),
                InkWell(
                  child: Text(
                    ' $miles miles ',
                    style: TextStyle(
                        color: primary, fontSize: 20, fontFamily: font2),
                  ),
                  onTap: () => _showPicker(),
                ),
                Text(
                  'of',
                  style: TextStyle(
                      color: textColor, fontSize: 20, fontFamily: font3),
                ),
                InkWell(
                  child: Text(
                    '$address',
                    style: TextStyle(
                        color: primary, fontSize: 20, fontFamily: font2),
                  ),
                  onTap: () async {
                    var p = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: placesKey,
                        mode: Mode.overlay,
                        language: 'en');
                    if (p == null) return;
                    var detail = await _places.getDetailsByPlaceId(p.placeId);
                    setState(() {
                      address = detail.result.formattedAddress;
                      changed = true;
                      location = detail.result.geometry.location;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        Row(
          children: <Widget>[
            IconButton(
                icon: icons[index],
                onPressed: () => setState(() {
                      showFilter = !showFilter;
                      index = (index + 1) % 2;
                    })),
            Spacer(),
          ],
        ),
        Divider(height: 1),
        location == null
            ? Center(child: Text('Please specify a Location'))
            : Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _formEvent(events[index]);
                  },
                ),
              ),
      ],
    );
  }
}
