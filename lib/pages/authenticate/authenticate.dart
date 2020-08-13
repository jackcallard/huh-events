import 'package:app_v4/pages/authenticate/email_signin.dart';
import 'package:app_v4/pages/authenticate/register.dart';
import 'package:app_v4/pages/authenticate/choose_signin.dart';
import 'package:app_v4/pages/utilities/terms_use.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SignIn(),
        '/register': (context) => Register(),
        '/terms': (context) => TermsUse(),
        '/signin': (context) => EmailSignIn(),
      },
    );
  }
}
