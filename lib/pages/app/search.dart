import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_search.dart';
import 'package:app_v4/pages/google_property/google_property.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool first = true;
  User user;
  int index;
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: placesKey);

  final TextEditingController _controller = TextEditingController();
  final DatabaseSearch _dbs = DatabaseSearch();
  void _setUp(context) {
    first = false;
    user = Provider.of<User>(context);
    index = 0;
  }

  bool rebuild = true;
  String search = '';

  bool show = false;
  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      drawer: MyDrawer(
        loc: '/search',
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1)),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() => search = '');
                            },
                          )),
                      onChanged: (value) => setState(() => search = value),
                    ),
                  ),
                  TabBar(tabs: [
                    Text('Users', style: TextStyle(color: textColor)),
                    Text('Events', style: TextStyle(color: textColor)),
                    Text('Places', style: TextStyle(color: textColor)),
                  ])
                ],
              ),
            ),
            Expanded(
              child: TabBarView(children: [
                StreamBuilder<List<BasicData>>(
                    stream: _dbs.getUsersFromSub(search),
                    builder: (context, snapshot) {
                      return snapshot.hasData && snapshot.data.isNotEmpty
                          ? ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return BasicDataTile(
                                  basicData: snapshot.data[index],
                                );
                              })
                          : Center(
                              child: Text('No users found'),
                            );
                    }),
                StreamBuilder<List<Event>>(
                    stream: _dbs.getEventsFromSub(search),
                    builder: (context, snapshot) {
                      return snapshot.hasData && snapshot.data.isNotEmpty
                          ? ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return FlatButton(
                                  padding: EdgeInsets.only(top: 2),
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed('/event_page', arguments: {
                                    'event': snapshot.data[index]
                                  }),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 60,
                                        width: 60 * widthToHeight,
                                        decoration: BoxDecoration(
                                          color: primary,
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                snapshot.data[index].imageRef),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              snapshot.data[index].name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              snapshot.data[index].organization,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        monthDayFormat(snapshot
                                            .data[index].timestamp
                                            .toDate()),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(width: 10)
                                    ],
                                  ),
                                );
                              })
                          : Center(
                              child: Text('No events found'),
                            );
                    }),
                FutureBuilder<PlacesAutocompleteResponse>(
                    future: _places.autocomplete(search),
                    builder: (context, snapshot) {
                      var predictions =
                          snapshot.hasData ? snapshot.data.predictions : [];
                      return ListView.builder(
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
                                var detail = await _places
                                    .getDetailsByPlaceId(p.placeId);
                                var address = detail.result.formattedAddress;
                                var loc = detail.result.geometry.location;
                              },
                            );
                          });
                    }),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
