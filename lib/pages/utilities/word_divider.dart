import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';

class WordDivider extends StatelessWidget {
  WordDivider({this.word});
  final String word;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            word,
            style: TextStyle(fontSize: 15, fontFamily: font),
          ),
        ),
        Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}
