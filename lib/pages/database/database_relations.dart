import 'package:app_v4/pages/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

class DatabaseRelations {
  DatabaseRelations({this.uid});
  String uid;

  final CollectionReference friendCollection =
      Firestore.instance.collection('friendships');

  final CollectionReference favoriteCollection =
      Firestore.instance.collection('favorites');

  final CollectionReference userFriendCollection =
      Firestore.instance.collection('userFriends');

  Future<Tuple2<FriendStatus, FavoriteStatus>> getStatus(String userID) async {
    var users = [uid, userID];
    var mapFriend = await friendCollection
        .document(getFriendDocID(users))
        .get()
        .then((value) => value.data);
    var statusFriend = _getFriendStatus(mapFriend, userID);

    var mapFavorite = await favoriteCollection
        .document('$uid-$userID')
        .get()
        .then((value) => value.data);
    var statusFavorite = _getFavoriteStatus(mapFavorite, userID);

    return Tuple2(statusFriend, statusFavorite);
  }

  FriendStatus _getFriendStatus(Map map, String userID) {
    if (map == null) return FriendStatus.none;
    switch (map['status']) {
      case 'friends':
        return FriendStatus.friends;
      case 'request':
        if (map['from'] == userID) return FriendStatus.requested;
        return FriendStatus.request;
      default:
        return FriendStatus.none;
    }
  }

  FavoriteStatus _getFavoriteStatus(Map map, String userID) {
    if (map == null) return FavoriteStatus.none;
    return FavoriteStatus.favorite;
  }

  Future<void> requestFriend(String userID) {
    var users = [userID, uid];
    return friendCollection.document(getFriendDocID(users)).setData({
      'users': users,
      'status': 'request',
      'to': userID,
      'from': uid,
    });
  }

  Future<void> addFriend(String userID) {
    var users = [userID, uid];
    return friendCollection.document(getFriendDocID(users)).setData({
      'users': users,
      'status': 'friends',
    });
  }

  Future<void> removeFriend(String userID) {
    var users = [userID, uid];
    return friendCollection.document(getFriendDocID(users)).delete();
  }

  String _getReqID(DocumentSnapshot e) => e.data['from'];

  Stream<List<String>> getRequests() {
    return friendCollection
        .where('status', isEqualTo: 'request')
        .where('to', isEqualTo: uid)
        .snapshots()
        .map((event) => event.documents.map(_getReqID).toList());
  }

  String _getFriendID(DocumentSnapshot e, String userID) {
    List list = e.data['users'];
    String first = list.first;
    String last = list.last;
    if (first == userID) return last;
    return first;
  }

  Stream<List<String>> getFriends(String userID) {
    return friendCollection
        .where('users', arrayContains: userID)
        .where('status', isEqualTo: 'friends')
        .snapshots()
        .map((event) =>
            event.documents.map((e) => _getFriendID(e, userID)).toList());
  }

  Future<List<String>> getAllFriends() {
    assert(uid != null);
    return userFriendCollection.document(uid).get().then((e) {
      // ignore: omit_local_variable_types
      Map map = e.data ?? {};
      List<dynamic> list = map['friends'] ?? [];
      // ignore: omit_local_variable_types
      List<String> newList = list.map((e) => e.toString()).toList();
      return newList;
    });
  }

  Future<void> addFavorite(String userID) {
    return favoriteCollection
        .document('$uid-$userID')
        .setData({'userID': uid, 'favorite': userID});
  }

  Future<void> removeFavorite(String userID) {
    return favoriteCollection.document('$uid-$userID').delete();
  }
}
