import 'package:app_v4/pages/services/auth_register.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:app_v4/pages/constants.dart';

class Settings extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        title: Text(
          'Settings',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 23,
            fontFamily: font,
          ),
        ),
      ),
      drawer: MyDrawer(
        loc: '/settings',
      ),
      backgroundColor: background,
      body: ListView(
        children: <Widget>[
          SettingsLabel(title: 'THEME'),
          Divider(height: 1),
          SettingsTile(title: 'Option 1'),
          Divider(height: 1),
          SettingsTile(title: 'Option 1'),
          Divider(height: 1),
          SettingsTile(title: 'Option 1'),
          Divider(height: 1),
          SettingsTile(title: 'Option 1'),
          SettingsLabel(title: 'THEME'),
          Divider(height: 1),
          SettingsTile(title: 'Option 1'),
          Divider(height: 1),
          SettingsTile(title: 'Option 1'),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: IconButton(
                onPressed: () async {
                  await _auth.signOut();
                },
                icon: Text(
                  'Sign Out',
                  style:
                      TextStyle(fontFamily: font, fontSize: 18, color: primary),
                )),
          ),
        ],
      ),
    );
  }
}

class SettingsLabel extends StatelessWidget {
  SettingsLabel({this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 20, 0, 4),
      child: Text(
        'THEME',
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  SettingsTile({this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: font,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
        trailing: Icon(Icons.arrow_right),
      ),
    );
  }
}
