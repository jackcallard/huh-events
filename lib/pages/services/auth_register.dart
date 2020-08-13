import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/services/auth_data.dart';
import 'package:app_v4/pages/database/database_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  final AccountData _acc = AccountData();

  // create user object based on Firebase User

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  //sign in anon
  Future signInAnon() async {
    try {
      var result = await _auth.signInAnonymously();
      var user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }
  //sign in with email & password

  dynamic signInEmailPassword(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      var user = result.user;
      return _userFromFirebaseUser(user);
    } catch (emailError) {
      if (emailError is PlatformException) {
        switch (emailError.code) {
          case 'ERROR_WRONG_PASSWORD':
            return 'Invalid password, try again.';
          case 'ERROR_USER_NOT_FOUND':
            return 'Account not found.';
          case 'ERROR_INVALID_EMAIL':
            return 'Please enter a valid email.';
          case 'ERROR_TOO_MANY_REQUESTS':
            return 'Too many invalid login attempts, try again later.';
          default:
            return emailError.code;
        }
      }
    }
  }

  //register with email & password
  Future regEmailPassword({String email, String password}) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      var user = result.user;
      var db = DatabaseUser(uid: user.uid);

      await db.setLoginData(email: email, method: 'EMAIL');

      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  // RESET PASSWORD

  Future resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign in with google

  Future signInGoogle() async {
    var googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    var method = await _acc.getEmailData(googleUser.email);
    if (!['GOOGLE', 'NO_ACCOUNT'].contains(method)) return method;
    var googleAuth = await googleUser.authentication;
    var credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    var authResult = await _auth.signInWithCredential(credential);
    var user = authResult.user;

    if (authResult.additionalUserInfo.isNewUser) {
      var db = DatabaseUser(uid: user.uid);
      await db.setLoginData(email: googleUser.email, method: 'GOOGLE');
    }
    return _userFromFirebaseUser(user);
  }

  // sign in with facebook

  Future signInFacebook() async {
    var facebookUser = await _facebookLogin.logIn(['email']);
    if (facebookUser.status != FacebookLoginStatus.loggedIn) return;
    try {
      var credential = FacebookAuthProvider.getCredential(
          accessToken: facebookUser.accessToken.token);

      var authResult = await _auth.signInWithCredential(credential);
      var user = authResult.user;

      if (authResult.additionalUserInfo.isNewUser) {
        var db = DatabaseUser(uid: user.uid);
        await db.setLoginData(email: user.email, method: 'FACEBOOK');
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      return 'ALREADY_CREATED';
    }
  }
}
