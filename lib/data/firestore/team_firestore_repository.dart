import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../domain/models/team.dart';
import '../../domain/repositories/team_repository.dart';

class TeamFirestoreRepository implements TeamRepository {
  TeamFirestoreRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection(FirestorePaths.teams);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestorePaths.users);

  @override
  Future<List<Team>> fetchTeamsBySport(String sport) async {
    final snap = await _teams.where('sport', isEqualTo: sport).get();
    return snap.docs.map((d) => Team.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<List<Team>> fetchTeamsByLeague(String leagueId) async {
    final snap = await _teams.where('leagueId', isEqualTo: leagueId).get();
    return snap.docs.map((d) => Team.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<List<Team>> fetchTeamsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snap = await _teams.where(FieldPath.documentId, whereIn: ids).get();
    return snap.docs.map((d) => Team.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> followTeam(String uid, String teamId) {
    return _users.doc(uid).update({
      'followedTeams': FieldValue.arrayUnion([teamId]),
    });
  }

  @override
  Future<void> unfollowTeam(String uid, String teamId) {
    return _users.doc(uid).update({
      'followedTeams': FieldValue.arrayRemove([teamId]),
    });
  }
}
