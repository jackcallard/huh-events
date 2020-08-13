class User {
  User({this.uid});
  String uid;
}

class ProfileData {
  ProfileData({
    this.uid,
    this.screenName,
    this.username,
    this.type,
    this.email,
    this.bio,
    this.friends,
    this.yourAccount,
    this.imageRef,
  });
  String uid;
  String screenName;
  String username;
  String type;
  String email;
  String bio;
  List<String> friends;
  bool yourAccount;
  String imageRef;
}

class BasicData {
  BasicData({
    this.uid,
    this.username,
    this.screenName,
    this.imageRef,
    this.newUser,
  });
  String uid;
  String username;
  String screenName;
  String imageRef;
  bool newUser;
}
