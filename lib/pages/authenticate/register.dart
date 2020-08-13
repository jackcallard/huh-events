import 'package:app_v4/pages/services/auth_register.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  String email = '';
  String password1 = '';
  String password2 = '';
  Icon p1Icon;
  Icon p2Icon;
  bool p1Valid = false;
  bool p2Valid = false;
  bool disabled = true;
  String error = '';
  bool loading = false;

  void checkValues() {
    p1Valid = password1.length >= 6;
    p1Icon = p1Valid ? Icon(Icons.check) : Icon(Icons.close);
    p2Valid = password2.length >= 6 && password1 == password2;
    p2Icon = p2Valid ? Icon(Icons.check) : Icon(Icons.close);
    disabled = !(p1Valid && p2Valid);
  }

  void nextPage() async {
    setState(() {
      disabled = loading = true;
      error = '';
    });
    await _auth.regEmailPassword(email: email, password: password1);
  }

  bool showPassword = false;
  Map args = {};
  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    email = args['email'];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 34, 0, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: Navigator.of(context).pop,
                icon: Icon(Icons.arrow_back),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Welcome to b-side',
                      style: TextStyle(
                        color: primary,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: font,
                      ),
                    ),
                  ),
                  Divider(
                    height: 20,
                    thickness: 1,
                  ),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Create a password',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              suffixIcon: Container(
                                  width: 60,
                                  child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: Navigator.of(context).pop,
                                      child: Text('change',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12))))),
                          initialValue: args['email'],
                          readOnly: true,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Password',
                              suffixIcon: Container(
                                width: 60,
                                child: p1Icon,
                              )),
                          onChanged: (val) => setState(() {
                            password1 = val;
                            checkValues();
                          }),
                          obscureText: true,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              suffixIcon: Container(
                                width: 60,
                                child: p2Icon,
                              )),
                          onChanged: (val) => setState(() {
                            password2 = val;
                            checkValues();
                          }),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            runAlignment: WrapAlignment.center,
                            direction: Axis.horizontal,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                'By clicking submit, I accept the',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Container(
                                width: 70,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/terms'),
                                  child: Text(
                                    'Terms of Use',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontSize: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(0),
                          child: RaisedButton(
                            disabledColor: Colors.grey[300],
                            disabledElevation: 0,
                            disabledTextColor: Colors.grey[200],
                            textColor: Colors.white,
                            color: primary,
                            child: loading ? buttonLoading : Text('Next Page'),
                            onPressed: (disabled ? null : nextPage),
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
