import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/services/auth_register.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: primary,
            colorScheme: ColorScheme(
                primary: primary,
                primaryVariant: primary,
                secondary: primary,
                secondaryVariant: primary,
                surface: primary,
                background: primary,
                error: primary,
                onPrimary: primary,
                onSecondary: primary,
                onSurface: primary,
                onBackground: primary,
                onError: primary,
                brightness: Brightness.light),
            accentColor: Colors.red[200],
            cardColor: primary,
            primarySwatch: Colors.red),
        home: Wrapper(),
      ),
    );
  }
}
