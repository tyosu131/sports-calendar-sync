import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/user_repository.dart';

class UserFirestoreRepository implements UserRepository {
  UserFirestoreRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  @override
  Future<AppUser?> fetchUser(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUser.fromMap(uid, snap.data()!);
  }

  @override
  Stream<AppUser?> watchUser(String uid) {
    return _doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AppUser.fromMap(uid, snap.data()!);
    });
  }

  @override
  Future<void> createUser(AppUser user) {
    return _doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateFollowedTeams(String uid, List<String> teamIds) {
    return _doc(uid).update({'followedTeams': teamIds});
  }
}
