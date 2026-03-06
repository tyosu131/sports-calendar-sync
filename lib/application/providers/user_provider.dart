import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_user.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

/// ログイン中ユーザーの Firestore ドキュメントをリアルタイム購読。
/// `StreamProvider` は RxJava/Kotlin Flow の `StateFlow` + `collectAsState` に近い。
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(user.uid);
});

// ---------------------------------------------------------------------------
// Follow/Unfollow Actions
// ---------------------------------------------------------------------------

class UserNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> followTeam(String teamId) async {
    final user = ref.read(appUserProvider).valueOrNull;
    if (user == null) return;

    final updated = [...user.followedTeamIds, teamId];
    await ref
        .read(userRepositoryProvider)
        .updateFollowedTeams(user.uid, updated);
  }

  Future<void> unfollowTeam(String teamId) async {
    final user = ref.read(appUserProvider).valueOrNull;
    if (user == null) return;

    final updated = user.followedTeamIds.where((id) => id != teamId).toList();
    await ref
        .read(userRepositoryProvider)
        .updateFollowedTeams(user.uid, updated);
  }
}

final userNotifierProvider =
    AsyncNotifierProvider<UserNotifier, void>(UserNotifier.new);
