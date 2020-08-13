import 'dart:io';

import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/services/auth_data.dart';
import 'package:app_v4/pages/database/database_user.dart';
import 'package:app_v4/pages/utilities/image_capture.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewUserPage extends StatefulWidget {
  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final AccountData _acc = AccountData();
  User user;

  Map args = {};

  void register() async {
    setState(() => loading = disabled = true);
    if (!validUsername(username)) {
      setState(() {
        nameError = 'The username can only be letters and numbers';
        loading = false;
      });
    } else if (await _acc.uniqueUsername(username)) {
      await DatabaseUser(uid: user.uid).createUserData(
          type: type,
          imageFile: imageFile,
          screenName: screenName,
          username: username,
          bio: bio);
    } else {
      setState(() => nameError =
          'Unfortunately, the username $username is already taken.');
      loading = false;
    }
  }

  void update() async {
    setState(() => loading = disabled = true);
    await DatabaseUser(uid: user.uid).updateUserData(
        type: type, imageFile: imageFile, screenName: screenName, bio: bio);
    await Navigator.of(context).pop();
  }

  String username = '';
  String screenName = '';
  String type;
  File imageFile;
  bool loading = false;
  bool disabled;
  String error = '';
  String nameError = '';
  bool first;
  ProfileData data;
  bool firstTime = true;
  String bio = '';

  void checkValues() {
    disabled = username == '' ||
        (imageFile == null && first) ||
        screenName == '' ||
        type == null;
    error = nameError = '';
  }

  void setUp(context) {
    args = ModalRoute.of(context).settings.arguments ?? {};
    first = args['first'] ?? true;
    data = args['userData'];
    disabled = first;
    firstTime = false;
    if (data == null) return;
    username = data.username;
    screenName = data.screenName;
    type = data.type;
    bio = data.bio;
  }

  @override
  Widget build(BuildContext context) {
    if (firstTime) setUp(context);
    user = Provider.of<User>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 34, 0, 0),
            child: first
                ? Container()
                : Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: Icon(Icons.arrow_back),
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'About you',
                      style: TextStyle(
                        color: primary,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: font,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        ImageCapture(
                            initial: first || data.imageRef == null
                                ? null
                                : NetworkImage(data.imageRef),
                            text: 'Choose Profile Photo',
                            circle: true,
                            update: (val) => setState(() {
                                  imageFile = val;
                                  checkValues();
                                })),
                        SizedBox(height: 10),
                        Text(
                          'Screen Name',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          onChanged: (val) => setState(
                            () {
                              screenName = val;
                              checkValues();
                            },
                          ),
                          initialValue: screenName,
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Username',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextFormField(
                          enabled: first,
                          decoration: InputDecoration(
                              suffixIcon: first ? null : Icon(Icons.lock)),
                          onChanged: (val) => setState(() {
                            username = val;
                            checkValues();
                          }),
                          initialValue: username,
                        ),
                        SizedBox(height: 10),
                        Text(nameError,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            )),
                        SizedBox(height: 10),
                        Text(
                          'Short Bio',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 2,
                          maxLines: 3,
                          onChanged: (val) => setState(() {
                            bio = val;
                            checkValues();
                          }),
                          initialValue: bio,
                        ),
                        SizedBox(height: 30),
                        Text(
                          'What best describes you?',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        DropdownButton(
                            value: type,
                            hint: Text('Choose item'),
                            items: [
                              DropdownMenuItem(
                                  value: 'Venue', child: Text('Venue')),
                              DropdownMenuItem(
                                  value: 'Performer', child: Text('Performer')),
                              DropdownMenuItem(
                                  value: 'Attendee', child: Text('Attendee')),
                            ],
                            onChanged: (value) => setState(() {
                                  type = value;
                                  checkValues();
                                })),
                        first
                            ? Center(
                                child: Wrap(
                                  runAlignment: WrapAlignment.center,
                                  direction: Axis.horizontal,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'By clicking Get Started, I accept the',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    Container(
                                      width: 70,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () => Navigator.pushNamed(
                                            context, '/terms'),
                                        child: Text(
                                          'Terms of Use',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        Container(
                          padding: EdgeInsets.all(0),
                          child: RaisedButton(
                            disabledColor: Colors.grey[300],
                            disabledElevation: 0,
                            disabledTextColor: Colors.grey[200],
                            textColor: Colors.white,
                            color: primary,
                            child: loading
                                ? buttonLoading
                                : Text(first ? 'Get Started' : 'Update'),
                            onPressed:
                                (disabled ? null : first ? register : update),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(error,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
