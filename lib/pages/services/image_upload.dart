import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class UploadImage {
  UploadImage({this.imageFile});

  File imageFile;
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://crispy-21ad2.appspot.com');
  StorageUploadTask uploadTask;

  Future<String> uploadProfile(String uid) async {
    var path = 'profilePictures/$uid';
    await _storage.ref().child(path).putFile(imageFile).onComplete;
    var ref = FirebaseStorage.instance.ref().child(path);
    return await ref.getDownloadURL();
  }

  Future<String> uploadEvent() async {
    var ret = DateTime.now().toString();
    var path = 'eventHeaders/event-header-$ret';
    await _storage.ref().child(path).putFile(imageFile).onComplete;
    var ref = FirebaseStorage.instance.ref().child(path);
    return await ref.getDownloadURL();
  }
}
