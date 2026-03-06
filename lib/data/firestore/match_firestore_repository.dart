import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../domain/models/match.dart';
import '../../domain/repositories/match_repository.dart';

class MatchFirestoreRepository implements MatchRepository {
  MatchFirestoreRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.matches);

  @override
  Stream<List<Match>> watchMatchesByTeamIds(List<String> teamIds) {
    if (teamIds.isEmpty) return Stream.value([]);

    // Firestore の `whereIn` は最大10件制限あり。
    // 10件超の場合は複数クエリを merge する必要あり (将来対応)。
    return _col
        .where(
          Filter.or(
            Filter('homeTeamId', whereIn: teamIds.take(10).toList()),
            Filter('awayTeamId', whereIn: teamIds.take(10).toList()),
          ),
        )
        .orderBy('startTimeUTC')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Match.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<Match?> fetchMatch(String matchId) async {
    final doc = await _col.doc(matchId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Match.fromMap(doc.id, doc.data()!);
  }
}
