import 'package:app_v4/pages/services/auth_data.dart';
import 'package:app_v4/pages/services/auth_register.dart';
import 'package:app_v4/pages/utilities/auth_buttons.dart';
import 'package:app_v4/pages/utilities/word_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/constants.dart';

class SignIn extends StatefulWidget {
  SignIn({this.toggle});
  final Function toggle;
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AccountData _acc = AccountData();
  final AuthService _auth = AuthService();
  String email = '';
  bool disabled = true;
  Icon emailIcon;
  String error = '';
  bool loading = false;

  Future<void> _showAlert(String method) async {
    return showDialog<void>(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Continue with $method'),
          content: SingleChildScrollView(
            child: Text(
                'You already have an account set up with $method, sign in there.'),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void checkDisabled() {
    disabled = !email.contains('@');
    emailIcon = disabled ? Icon(Icons.close) : Icon(Icons.check);
  }

  void nextPage() async {
    setState(() {
      disabled = true;
      error = '';
      loading = true;
    });
    switch (await _acc.getEmailData(email)) {
      case 'NO_ACCOUNT':
        await Navigator.pushNamed(context, '/register',
            arguments: {'email': email});
        break;
      case 'EMAIL':
        await Navigator.pushNamed(context, '/signin',
            arguments: {'email': email});
        break;
      case 'GOOGLE':
        await _showAlert('Google');
        break;
      case 'APPLE':
        await _showAlert('Apple');
        break;
      case 'FACEBOOK':
        await _showAlert('Facebook');
        break;
      default:
        setState(() => error = 'Enter valid Email Address');
    }
    setState(() {
      loading = false;
      disabled = !(error == '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Register / Sign in',
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
                        'Enter your email to continue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Email',
                          suffixIcon: Container(
                            width: 60,
                            child: emailIcon,
                          )),
                      onChanged: (val) => setState(() {
                        email = val;
                        checkDisabled();
                      }),
                      obscureText: false,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        runAlignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            'By clicking continue, I accept the',
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
                        child: loading ? buttonLoading : Text('Continue'),
                        onPressed: disabled ? null : nextPage,
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                        child: Text(error,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ))),
                    WordDivider(word: 'or'),
                    SizedBox(height: 20),
                    Column(
                      children: <Widget>[
                        GoogleAuthButton(onPressed: () async {
                          switch (await _auth.signInGoogle()) {
                            case 'EMAIL':
                              await _showAlert('email');
                              return;
                            case 'FACEBOOK':
                              await _showAlert('Facebook');
                              return;
                            default:
                              return;
                          }
                        }),
                        FacebookAuthButton(onPressed: () async {
                          switch (await _auth.signInFacebook()) {
                            case 'ALREADY_CREATED':
                              await _showAlert('a different sign in method');
                              return;
                            default:
                              return;
                          }
                        }),
                      ],
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
