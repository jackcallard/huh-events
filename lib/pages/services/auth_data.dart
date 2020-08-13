import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class AccountData {
  // collection reference

  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  Future<String> getEmailData(String email) async {
    if (!EmailValidator.validate(email)) return 'MALFORMED';
    return userCollection
        .where('email', isEqualTo: email.toLowerCase())
        .getDocuments()
        .then((value) => value.documents.isEmpty
            ? 'NO_ACCOUNT'
            : value.documents[0]['loginMethod']);
  }

  Future<bool> uniqueUsername(String username) {
    return userCollection
        .where('username', isEqualTo: username.toLowerCase())
        .getDocuments()
        .then((value) => value.documents.isEmpty);
  }

  Future<bool> newUser(String uid) async {
    return userCollection
        .document(uid)
        .get()
        .then((DocumentSnapshot ds) => ds.data['newUser']);
  }
}
