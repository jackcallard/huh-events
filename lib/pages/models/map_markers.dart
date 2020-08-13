import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class MapMarker extends Clusterable {
  MapMarker({
    @required this.id,
    @required this.position,
    @required this.icon,
    @required this.onTap,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );
  final String id;
  final LatLng position;
  final BitmapDescriptor icon;
  final Function onTap;

  Marker toMarker() => Marker(
        markerId: MarkerId(id),
        position: LatLng(
          position.latitude,
          position.longitude,
        ),
        icon: icon,
        onTap: onTap,
      );
}
