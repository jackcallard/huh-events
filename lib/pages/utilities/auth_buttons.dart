import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  AuthButton({this.background, this.text, this.company, this.onPressed});
  final Color background;
  final Color text;
  final String company;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      splashColor: background == Colors.black ? Colors.grey[700] : null,
      color: background,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/auth_logos/$company.png',
            height: 17,
            width: 17,
          ),
          SizedBox(width: 10),
          Text(
            'Continue with $company',
            style: TextStyle(color: text, fontSize: 15),
          )
        ],
      ),
    );
  }
}

class GoogleAuthButton extends StatelessWidget {
  GoogleAuthButton({this.onPressed});
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return AuthButton(
      company: 'Google',
      onPressed: onPressed,
      background: Colors.white,
      text: Colors.grey[700],
    );
  }
}

class AppleAuthButton extends StatelessWidget {
  AppleAuthButton({this.onPressed});
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return AuthButton(
      company: 'Apple',
      onPressed: onPressed,
      background: Colors.black,
      text: Colors.white,
    );
  }
}

class FacebookAuthButton extends StatelessWidget {
  FacebookAuthButton({this.onPressed});
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return AuthButton(
      company: 'Facebook',
      onPressed: onPressed,
      background: Colors.blueAccent[700],
      text: Colors.white,
    );
  }
}
