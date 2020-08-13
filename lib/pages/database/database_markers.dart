import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/map_markers.dart';
import 'package:app_v4/pages/database/database_event.dart';
import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cluster {
  Cluster({
    this.onPressed,
    this.updateCircles,
    this.icons,
  });
  final Function onPressed;
  final Function updateCircles;
  final Map<int, BitmapDescriptor> icons;
  final DatabaseEvent _dbe = DatabaseEvent();

  // Returns the corresponding icon to the point size

  BitmapDescriptor getIcon(int n) {
    if (n >= 10) return icons[10];
    if (n >= 5) return icons[5];
    if (n >= 2) return icons[2];
    return icons[1];
  }

  // Returns a (future) list of markers in the given view port

  Future<List<Marker>> _getMarkers(List<Event> events, mapController) async {
    var markers = <MapMarker>[];
    var zoom = await mapController.getZoomLevel();
    for (final event in events) {
      final marker = MapMarker(
        onTap: () {
          mapController.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(event.geoPoint.latitude - .001, event.geoPoint.longitude),
              16));
          onPressed(event);
        },
        icon: icons[1],
        position: LatLng(event.geoPoint.latitude, event.geoPoint.longitude),
        id: event.name,
      );
      markers.add(marker);
    }
    var fluster = await Fluster<MapMarker>(
      minZoom: 0, // The min zoom at clusters will show
      maxZoom: 15, // The max zoom at clusters will show
      radius: 400, // Cluster radius in pixels
      extent: 2048, // Tile extent. Radius is calculated with it.
      nodeSize: 64, // Size of the KD-tree leaf node.
      points: markers, // The list of markers created before
      createCluster: (
        BaseCluster cluster,
        double lng,
        double lat,
      ) =>
          MapMarker(
        onTap: () => mapController.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom + 2)),
        id: cluster.id.toString(),
        position: LatLng(lat, lng),
        icon: getIcon(cluster.pointsSize),
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
    var gm = await fluster
        .clusters([-180, -85, 180, 85], zoom.toInt())
        .map((cluster) => cluster.toMarker())
        .toList();
    return gm;
  }

  // Updates the markers to ones in the given viewport

  Future<List<Marker>> getMarkers(
      GoogleMapController mapController, DateTime first, DateTime last) async {
    var events = await _eventStream(mapController, first, last);
    return await _getMarkers(events, mapController);
  }

  // Returns a (future) stream of Events inside the given viewport

  Future<List<Event>> _eventStream(
      GoogleMapController mapController, DateTime first, DateTime last) async {
    var latLng = await mapController.getVisibleRegion();
    var lat = (latLng.northeast.latitude + latLng.southwest.latitude) / 2;
    var lng = (latLng.northeast.longitude + latLng.southwest.longitude) / 2;
    var height = (latLng.northeast.latitude - latLng.southwest.latitude) * 60;
    updateCircles(Circle(
        strokeColor: primary,
        visible: true,
        circleId: CircleId('Hey'),
        center: LatLng(lat, lng),
        radius: height * 1000));
    return _dbe.events(lat, lng, height, first, last).first;
  }
}
