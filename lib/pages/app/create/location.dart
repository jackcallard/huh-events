import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/google_property/google_property.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  TextEditingController _controller;
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: placesKey);

  Event event;
  Map args;
  bool disabled = true;
  String entry = '';
  bool first = true;

  void clearBox() {
    _controller.clear();
    setState(() {
      entry = '';
      event.geoPoint = null;
    });
  }

  void _setUp(context) {
    first = false;
    args = ModalRoute.of(context).settings.arguments;
    event = args['event'];
    _controller = TextEditingController(text: event.address);
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    disabled = event.address == '' || event.geoPoint == null;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              minLines: 1,
              maxLines: 3,
              controller: _controller,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  hintText: 'Address',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 1)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: clearBox,
                  )),
              onChanged: (value) => setState(() {
                entry = value;
                event.geoPoint = null;
              }),
            ),
            SizedBox(height: 10),
            FutureBuilder<PlacesAutocompleteResponse>(
                future: _places.autocomplete(entry),
                builder: (context, snapshot) {
                  var predictions =
                      snapshot.hasData ? snapshot.data.predictions : [];
                  return Expanded(
                    child: ListView.builder(
                        itemCount: predictions.length + 1,
                        itemBuilder: (context, index) {
                          if (!snapshot.hasData) {
                            return Loader();
                          }
                          if (index == predictions.length) {
                            return PoweredByGoogleImage();
                          }
                          return PredictionTile(
                            prediction: predictions[index],
                            onTap: (p) async {
                              if (p == null) return;
                              var detail =
                                  await _places.getDetailsByPlaceId(p.placeId);
                              event.address = detail.result.formattedAddress;
                              var loc = detail.result.geometry.location;
                              event.geoPoint = GeoPoint(loc.lat, loc.lng);
                              Navigator.of(context).pop(event);
                            },
                          );
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
