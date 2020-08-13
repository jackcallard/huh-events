import 'package:app_v4/pages/app_wrapper.dart';
import 'package:app_v4/pages/authenticate/authenticate.dart';
import 'package:app_v4/pages/database/database_user.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) return Authenticate();
    return StreamProvider<BasicData>.value(
      value: DatabaseUser(uid: user.uid).basicData,
      child: AppWrapper(),
    );
  }
}
