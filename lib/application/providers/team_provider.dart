import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/team.dart';
import 'firestore_provider.dart';

/// スポーツ種別でチーム一覧を取得。
/// `FutureProvider.family` は React Query の `useQuery(key, fn)` に相当。
final teamsBySportProvider =
    FutureProvider.family<List<Team>, String>((ref, sport) async {
  return ref.watch(teamRepositoryProvider).fetchTeamsBySport(sport);
});

final teamsByLeagueProvider =
    FutureProvider.family<List<Team>, String>((ref, leagueId) async {
  return ref.watch(teamRepositoryProvider).fetchTeamsByLeague(leagueId);
});
