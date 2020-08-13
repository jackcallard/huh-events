import 'dart:io';
import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/services/image_upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseUser {
  DatabaseUser({this.uid});
  final String uid;

  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  final CollectionReference userFriendCollection =
      Firestore.instance.collection('userFriends');

  // Method to update the users Data

  Future updateUserData(
      {String screenName, String type, File imageFile, String bio}) async {
    if (imageFile != null) {
      var imageRef = await UploadImage(imageFile: imageFile).uploadProfile(uid);
      await userCollection.document(uid).updateData({
        'imageRef': imageRef,
        'profileName': screenName,
        'type': type,
        'bio': bio,
        'uid': uid,
      });
    } else {
      await userCollection.document(uid).updateData({
        'profileName': screenName,
        'type': type,
        'bio': bio,
        'uid': uid,
      });
    }
  }

  void createUserData(
      {String screenName,
      String username,
      String type,
      File imageFile,
      String bio}) async {
    var imageRef = await UploadImage(imageFile: imageFile).uploadProfile(uid);
    var subNames = listify(username.toLowerCase());
    await userCollection.document(uid).setData({
      'profileName': screenName,
      'username': username.toLowerCase(),
      'subNames': subNames,
      'type': type,
      'bio': bio,
      'uid': uid,
      'imageRef': imageRef,
      'newUser': false,
    }, merge: true);
  }

  // Methods to load a users profile.

  Stream<ProfileData> profileStream(String accID) {
    return userCollection
        .document(accID)
        .snapshots()
        .map((event) => _loadProfile(accID, event));
  }

  ProfileData _loadProfile(String accID, map) {
    assert(accID != null);
    assert(map != null);
    var yourAccount = uid == accID;
    return ProfileData(
      uid: accID,
      screenName: map['profileName'],
      username: map['username'],
      type: map['type'],
      email: map['email'],
      bio: map['bio'],
      yourAccount: yourAccount,
      imageRef: map['imageRef'],
    );
  }

  // Method to set the method of login

  Future setLoginData({String email, String method}) async {
    return await userCollection.document(uid).setData({
      'loginMethod': method,
      'email': email.toLowerCase(),
      'newUser': true,
      'username': '',
      'imageRef': null,
      'profileName': '',
      'uid': uid,
    });
  }

  // Methods to retrieve the basic data of a user

  Stream<BasicData> getData(String accID) {
    return userCollection.document(accID).snapshots().map(_basicData);
  }

  Stream<BasicData> get basicData {
    return userCollection.document(uid).snapshots().map(_basicData);
  }

  BasicData _basicData(DocumentSnapshot e) {
    if (e.data == null) return null;
    return BasicData(
      screenName: e.data['profileName'] ?? '',
      username: e.data['username'] ?? '',
      uid: e.data['uid'],
      imageRef: e.data['imageRef'],
      newUser: e.data['newUser'],
    );
  }
}
