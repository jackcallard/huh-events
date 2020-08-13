import 'package:app_v4/pages/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool first = true;
  User user;
  void setUp(context) async {
    first = false;
    user = Provider.of<User>(context);
    var icon = await getBytesFromAsset('assets/app_logos/pin3.png', 135);
    var myIcon = BitmapDescriptor.fromBytes(icon);
    var icon2 = await getBytesFromAsset('assets/app_logos/pin2plus.png', 135);
    var myIcon2 = BitmapDescriptor.fromBytes(icon2);
    var icon5 = await getBytesFromAsset('assets/app_logos/pin5plus.png', 135);
    var myIcon5 = BitmapDescriptor.fromBytes(icon5);
    var icon10 = await getBytesFromAsset('assets/app_logos/pin10plus.png', 135);
    var myIcon10 = BitmapDescriptor.fromBytes(icon10);
    await Navigator.pushReplacementNamed(context, '/home', arguments: {
      'icons': {
        1: myIcon,
        2: myIcon2,
        5: myIcon5,
        10: myIcon10,
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (first) setUp(context);
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: SpinKitSquareCircle(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}
