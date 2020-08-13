import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  MyDrawer({@required this.loc});
  final String loc;

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  BasicData basicData;

  @override
  Widget build(BuildContext context) {
    basicData = Provider.of<BasicData>(context);
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
      child: Drawer(
        child: Container(
          color: background,
          child: Column(
            children: <Widget>[
              Container(
                height: 100,
                padding: EdgeInsets.only(top: 30),
                child: FlatButton(
                  onPressed: () {
                    if (widget.loc == '/home') {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/profile', arguments: {
                        'from_drawer': true,
                        'uid': basicData.uid,
                      });
                    } else if (widget.loc == '/profile') {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/profile',
                          arguments: {
                            'from_drawer': true,
                            'uid': basicData.uid,
                          });
                    }
                  },
                  child: UserTile(basicData: basicData),
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(0),
                  children: [
                    MyListTile(
                      title: 'Profile',
                      icon: Icons.account_circle,
                      route: '/profile',
                      loc: widget.loc,
                    ),
                    MyListTile(
                      title: 'Home',
                      icon: Icons.map,
                      route: '/home',
                      loc: widget.loc,
                    ),
                    // MyListTile(
                    //   title: 'Create Event',
                    //   icon: Icons.add_circle,
                    //   route: '/create_event',
                    //   loc: widget.loc,
                    // ),
                    MyListTile(
                      title: 'Search',
                      icon: Icons.search,
                      route: '/search',
                      loc: widget.loc,
                    ),
                    MyListTile(
                      title: 'Calendar',
                      icon: Icons.calendar_today,
                      route: '/calendar',
                      loc: widget.loc,
                    ),
                    MyListTile(
                      title: 'Invitations',
                      icon: Icons.send,
                      route: '/invite_list',
                      loc: widget.loc,
                    ),
                    MyListTile(
                      title: 'Settings',
                      icon: Icons.settings,
                      route: '/settings',
                      loc: widget.loc,
                    ),
                    MyListTile(
                      title: 'Help',
                      icon: Icons.help,
                      route: '/help',
                      loc: widget.loc,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyListTile extends StatelessWidget {
  MyListTile({this.title, this.route, this.icon, this.loc});
  final String title;
  final String route;
  final IconData icon;
  final String loc;
  final Color textColor = Colors.grey[800];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return FlatButton(
      color: (route == loc) ? Colors.red[50] : background,
      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
      onPressed: () {
        if (loc == route) {
          Navigator.of(context).pop();
        } else if (route == '/home') {
          Navigator.popUntil(context, ModalRoute.withName('/home'));
        } else if (loc == '/home') {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(route,
              arguments: {'uid': user.uid, 'from_drawer': true});
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(route,
              arguments: {'uid': user.uid, 'from_drawer': true});
        }
      },
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: (route == loc) ? primary : textColor,
        ),
        dense: true,
        contentPadding: EdgeInsets.all(0),
        title: Text(
          title,
          style: TextStyle(
              fontFamily: (route == loc) ? font2 : font3,
              fontSize: 18,
              color: (route == loc) ? primary : textColor),
        ),
      ),
    );
  }
}
