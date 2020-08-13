/// THIS CODE IS NOT MINE- ALL BELONGS TO GOOGLE

import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class PredictionTile extends StatelessWidget {
  PredictionTile({@required this.prediction, this.onTap});

  final Prediction prediction;
  final ValueChanged<Prediction> onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(prediction.description),
      onTap: () {
        if (onTap != null) {
          onTap(prediction);
        }
      },
    );
  }
}

class PoweredByGoogleImage extends StatelessWidget {
  final _poweredByGoogleWhite =
      'packages/flutter_google_places/assets/google_white.png';
  final _poweredByGoogleBlack =
      'packages/flutter_google_places/assets/google_black.png';

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Padding(
          padding: EdgeInsets.all(16.0),
          child: Image.asset(
            Theme.of(context).brightness == Brightness.light
                ? _poweredByGoogleWhite
                : _poweredByGoogleBlack,
            scale: 2.5,
          ))
    ]);
  }
}

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxHeight: 2.0),
        child: LinearProgressIndicator());
  }
}
