import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:string_validator/string_validator.dart';
import 'dart:ui' as ui;

Color primary = Colors.redAccent;
String font = 'RobotoMono';
String font2 = 'Ubuntu';
String font3 = 'Ubuntu2';
Color background = Colors.grey[100];
Color textColor = Colors.grey[700];
SpinKitWave buttonLoading = SpinKitWave(size: 20, color: Colors.white);
SpinKitCircle circleLoading = SpinKitCircle(size: 20, color: Colors.black);
SpinKitCircle centerLoading = SpinKitCircle(size: 40, color: primary);
String map_style = 'assets/map_style/map_style.txt';
List<String> defaultIcons = [
  'Alien',
  'Angel',
  'Baby',
  'Boxer',
  'Chef',
  'Clown',
  'Dad',
  'Devil',
  'Doctor',
  'Dragon'
];
bool validUsername(String name) {
  for (var i = 0; i < name.length; i++) {
    if (!(isAlphanumeric(name[i]) || name[i] == '-' || name[i] == '_')) {
      return false;
    }
  }
  return true;
}

enum FriendStatus { none, requested, friends, request }

enum AttendStatus { none, going, interested, hosting }

enum FavoriteStatus { none, favorite }

enum PrivateStatus { none, going, square }

List<String> months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

String placesKey = 'API_KEY';

String googleKey = '';

Widget loadingScreen = Scaffold(
  backgroundColor: primary,
  body: Center(
    child: SpinKitSquareCircle(
      color: Colors.white,
      size: 50.0,
    ),
  ),
);

String dateTimeFormat(DateTime dt) {
  var year = dt.year;
  var month = months[dt.month - 1];
  var day = dt.day;
  return '$month $day, $year';
}

String timeFormat(DateTime dt, TimeOfDay t, BuildContext context) {
  var year = dt.year;
  var month = months[dt.month - 1];
  var day = dt.day;
  return '$month $day, $year at ${t.format(context)}';
}

String timestampFormat(Timestamp timestamp, context) {
  return timeFormat(
      timestamp.toDate(), TimeOfDay.fromDateTime(timestamp.toDate()), context);
}

String monthDayFormat(DateTime dt) {
  var month = months[dt.month - 1];
  var day = dt.day;
  return '$month $day';
}

int dateTimeInt(DateTime dt) {
  var year = dt.year;
  var month = dt.month;
  var day = dt.day;
  return year * 10000 + month * 100 + day;
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  var data = await rootBundle.load(path);
  var codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  var fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}

List<String> listify(String username) {
  // ignore: omit_local_variable_types
  List<String> list = [];
  for (var i = 1; i < username.length + 1; i++) {
    list.add(username.substring(0, i));
  }
  return list;
}

List<String> listifyEvent(String eventName) {
  if (eventName == '') return [];
  eventName = eventName.toLowerCase();
  // ignore: omit_local_variable_types
  List<String> list = [];
  for (var i = 1; i < eventName.length + 1; i++) {
    if (eventName[i - 1] == ' ' && i != eventName.length) {
      list.addAll(listify(eventName.substring(i)));
    }
    list.add(eventName.substring(0, i));
  }
  return list;
}

String getFriendDocID(List<String> users) {
  users.sort((a, b) => a.compareTo(b));
  return '${users.first}-${users.last}';
}

double widthToHeight = 5 / 3;

TextStyle linkStyle =
    TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);

TextStyle textStyle =
    TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
