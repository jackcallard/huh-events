import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MyDrawer(
        loc: '/help',
      ),
      body: Center(
        child: Text('You need Help'),
      ),
    );
  }
}
