import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/team_provider.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/models/team.dart';

/// チーム選択画面。
/// スポーツ別タブ → チーム一覧 → フォロー/アンフォロー。
/// ウィジェットツリー:
///   Scaffold
///   └── DefaultTabController (スポーツタブ)
///       └── TabBarView
///           └── _TeamList (FutureProvider)
///               └── ListView > _TeamTile (フォロー状態管理)
class TeamSelectScreen extends ConsumerWidget {
  const TeamSelectScreen({super.key, required this.sport});

  final String sport;

  static const _sportTabs = [
    ('soccer', 'サッカー'),
    ('baseball', '野球'),
    ('basketball', 'バスケ'),
    ('americanFootball', 'NFL'),
    ('hockey', 'NHL'),
    ('tennis', 'テニス'),
    ('motorsport', 'F1'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initIndex =
        _sportTabs.indexWhere((t) => t.$1 == sport).clamp(0, _sportTabs.length - 1);

    return DefaultTabController(
      length: _sportTabs.length,
      initialIndex: initIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チームを選ぶ'),
          leading: BackButton(onPressed: () => context.go('/')),
          bottom: TabBar(
            isScrollable: true,
            tabs: _sportTabs.map((t) => Tab(text: t.$2)).toList(),
          ),
        ),
        body: TabBarView(
          children: _sportTabs
              .map((t) => _TeamListTab(sport: t.$1))
              .toList(),
        ),
      ),
    );
  }
}

class _TeamListTab extends ConsumerWidget {
  const _TeamListTab({required this.sport});

  final String sport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsBySportProvider(sport));
    final userAsync = ref.watch(appUserProvider);
    final followedIds = userAsync.valueOrNull?.followedTeamIds ?? [];

    return teamsAsync.when(
      data: (teams) {
        if (teams.isEmpty) {
          return const Center(child: Text('チームデータなし'));
        }
        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, i) => _TeamTile(
            team: teams[i],
            isFollowed: followedIds.contains(teams[i].id),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
    );
  }
}

class _TeamTile extends ConsumerWidget {
  const _TeamTile({required this.team, required this.isFollowed});

  final Team team;
  final bool isFollowed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: team.logoUrl != null
          ? Image.network(team.logoUrl!, width: 36, height: 36)
          : const Icon(Icons.sports),
      title: Text(team.nameJa),
      subtitle: Text(team.name),
      trailing: IconButton(
        icon: Icon(
          isFollowed ? Icons.favorite : Icons.favorite_border,
          color: isFollowed ? Colors.red : null,
        ),
        onPressed: () {
          if (isFollowed) {
            ref.read(userNotifierProvider.notifier).unfollowTeam(team.id);
          } else {
            ref.read(userNotifierProvider.notifier).followTeam(team.id);
          }
        },
      ),
    );
  }
}
