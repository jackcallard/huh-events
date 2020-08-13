import 'package:app_v4/pages/app/calendar.dart';
import 'package:app_v4/pages/app/create/event_create.dart';
import 'package:app_v4/pages/app/create/invite_friends.dart';
import 'package:app_v4/pages/app/create/preview.dart';
import 'package:app_v4/pages/app/create/public_private.dart';
import 'package:app_v4/pages/app/create/location.dart';
import 'package:app_v4/pages/app/help.dart';
import 'package:app_v4/pages/app/invite_list.dart';
import 'package:app_v4/pages/app/profile/user_events.dart';
import 'package:app_v4/pages/app/event_page.dart';
import 'package:app_v4/pages/app/profile/friends_list.dart';
import 'package:app_v4/pages/app/home/home.dart';
import 'package:app_v4/pages/app/loading.dart';
import 'package:app_v4/pages/app/profile/profile.dart';
import 'package:app_v4/pages/app/home/requests.dart';
import 'package:app_v4/pages/app/search.dart';
import 'package:app_v4/pages/app/settings.dart';
import 'package:app_v4/pages/app/profile/user_feed.dart';
import 'package:app_v4/pages/authenticate/new_user.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bd = Provider.of<BasicData>(context);
    if (bd == null) {
      return loadingScreen;
    } else if (bd.newUser) {
      return NewUserPage();
    } else {
      return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Loading(),
          '/profile': (context) => MyProfile(),
          '/home': (context) => Home(),
          '/settings': (context) => Settings(),
          '/new_user': (context) => NewUserPage(),
          '/create_event': (context) => PublicPrivate(),
          '/preview': (context) => Preview(),
          '/choose_friends': (context) => ChooseFriends(),
          '/event_page': (context) => EventPage(),
          '/friend_list': (context) => FriendList(),
          '/requests': (context) => RequestList(),
          '/invite_list': (context) => InviteEvents(),
          '/user_events': (context) => UserEvents(),
          '/user_feed': (context) => UserFeed(),
          '/help': (context) => Help(),
          '/search': (context) => Search(),
          '/calendar': (context) => Calendar(),
          '/event_creation': (context) => EventCreate(),
          '/location': (context) => Location(),
        },
      );
    }
  }
}
