import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/match.dart';
import 'firestore_provider.dart';
import 'user_provider.dart';

/// フォロー中チームの試合一覧。
/// appUserProvider → teamIds → Firestore stream という依存チェーン。
/// React の `useEffect` ネストと違い、Riverpod は依存が自動追跡される。
final followedMatchesProvider = StreamProvider<List<Match>>((ref) {
  final userAsync = ref.watch(appUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null || user.followedTeamIds.isEmpty) {
        return Stream.value([]);
      }
      return ref
          .watch(matchRepositoryProvider)
          .watchMatchesByTeamIds(user.followedTeamIds);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// 特定スポーツでフィルタリングした試合一覧
final matchesBySportProvider =
    Provider.family<List<Match>, String>((ref, sport) {
  final matches = ref.watch(followedMatchesProvider).valueOrNull ?? [];
  return matches; // フィルタは League.sport 取得後に追加実装
});
