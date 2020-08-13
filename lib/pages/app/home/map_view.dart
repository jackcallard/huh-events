import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/database/database_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  MapPage({
    @required this.icons,
    @required this.toggleRange,
    @required this.openList,
    @required this.setPanel,
    @required this.hidePanel,
  });
  final Function toggleRange;
  final Map<int, BitmapDescriptor> icons;
  final Function openList;
  final Function setPanel;
  final Function hidePanel;
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage>, TickerProviderStateMixin {
  String _mapStyle;
  GoogleMapController mapController;
  Cluster _cl;
  List<Marker> googleMarkers;
  Set<Circle> circles;
  bool first = true;
  List<DateTime> dateRange;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString(map_style).then((string) {
      _mapStyle = string;
    });
    _cl = Cluster(
        icons: widget.icons,
        updateCircles: (c) => setState(() => circles = {c}),
        onPressed: widget.setPanel);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await mapController.setMapStyle(_mapStyle);
    _currentLocation();
  }

  void _setUp(context) async {
    first = false;
    dateRange = Provider.of<List<DateTime>>(context);
  }

  void _refresh() async {
    setState(() => loading = true);
    var markers =
        await _cl.getMarkers(mapController, dateRange.first, dateRange.last);
    setState(() => googleMarkers = markers);
    await Future.delayed(const Duration(seconds: 1), () {});
    setState(() => loading = false);
  }

  void _currentLocation() async {
    LocationData currentLocation;
    var location = Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    await mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 14,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!first && dateRange != Provider.of<List<DateTime>>(context)) {
      dateRange = Provider.of<List<DateTime>>(context);
      _refresh();
    }

    if (first) _setUp(context);
    super.build(context);
    return Stack(
      children: <Widget>[
        GoogleMap(
          minMaxZoomPreference: MinMaxZoomPreference(5, 19),
          rotateGesturesEnabled: false,
          trafficEnabled: false,
          indoorViewEnabled: false,
          tiltGesturesEnabled: false,
          onTap: (e) => widget.hidePanel(),
          onCameraIdle: _refresh,
          myLocationEnabled: true,
          compassEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: const LatLng(42.440498, -76.495697),
            zoom: 4,
          ),
          markers: (googleMarkers ?? []).toSet(),
          circles: circles,
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: CircleButton(
                onPressed: loading ? null : _refresh,
                color: Colors.white,
                child: loading
                    ? Padding(
                        padding: const EdgeInsets.all(9),
                        child: SpinKitRing(
                          lineWidth: 2,
                          color: primary,
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        color: primary,
                      ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 55),
              child: CircleButton(
                onPressed: _currentLocation,
                child: Icon(
                  Icons.my_location,
                  color: primary,
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: CircleButton(
                onPressed: () => widget.openList(),
                color: Colors.white,
                child: Icon(Icons.list, color: primary),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 55.0),
              child: CircleButton(
                  onPressed: widget.toggleRange,
                  child: Icon(
                    Icons.calendar_today,
                    color: primary,
                    size: 22,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CircleButton extends StatelessWidget {
  CircleButton({@required this.child, @required this.onPressed, this.color});
  final Widget child;
  final Function onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          width: 35,
          height: 35,
          child: Material(
            shape: CircleBorder(),
            color: color ?? Colors.white,
            elevation: 12,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onPressed,
              splashColor: Colors.grey[300],
              highlightColor: Colors.grey[200],
              child: child,
            ),
          )),
    );
  }
}
