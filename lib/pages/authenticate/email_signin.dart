import 'package:app_v4/pages/services/auth_register.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';

class EmailSignIn extends StatefulWidget {
  EmailSignIn({this.toggle});
  final Function toggle;
  @override
  _EmailSignInState createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  final AuthService _auth = AuthService();
  String email = '';
  String password = '';
  bool disabled = true;
  String error = '';
  bool loading = false;

  Future<void> _resetAlert() async {
    return showDialog<void>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset password'),
          content: SingleChildScrollView(
            child: Text('Tap confirm to reset your password.'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                _auth.resetPassword(email);
                Navigator.of(context).pop();
                setState(() {
                  error = 'An email to reset your password was sent to $email';
                });
              },
            ),
          ],
        );
      },
    );
  }

  void nextPage() async {
    setState(() {
      disabled = true;
      error = '';
      loading = true;
    });
    var result = await _auth.signInEmailPassword(email, password);
    if (String == result.runtimeType) {
      setState(() {
        error = result;
        loading = false;
      });
    }
  }

  void checkValue() {
    disabled = password.length < 6;
  }

  final _formKey = GlobalKey<FormState>();
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Welcome back',
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
                            'Enter your password',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Email',
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
                          decoration: InputDecoration(hintText: 'Password'),
                          obscureText: true,
                          onChanged: (val) => setState(() {
                            password = val;
                            checkValue();
                          }),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Forgot password?',
                                style: TextStyle(fontSize: 10)),
                            Container(
                              width: 60,
                              child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: _resetAlert,
                                  child: Text(
                                    'Reset here',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontSize: 10,
                                    ),
                                  )),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(0),
                          child: RaisedButton(
                              disabledColor: Colors.grey[300],
                              disabledElevation: 0,
                              disabledTextColor: Colors.grey[200],
                              textColor: Colors.white,
                              color: primary,
                              child: loading ? buttonLoading : Text('Sign in'),
                              onPressed: (disabled ? null : nextPage)),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(error,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              )),
                        ),
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
