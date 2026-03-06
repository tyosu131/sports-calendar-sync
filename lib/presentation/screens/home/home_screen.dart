import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/match_provider.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/models/match.dart';
import '../../widgets/match_card.dart';

/// ホーム画面。
/// フォロー中チームの直近試合一覧 + スポーツタブ + ナビゲーション。
/// React のページコンポーネントに相当。`ConsumerWidget` = FC + hooks。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _sports = ['全て', 'サッカー', '野球', 'バスケ', 'NFL', 'その他'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sports.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(followedMatchesProvider);
    final userAsync = ref.watch(appUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'カレンダーURL',
            onPressed: () => context.go('/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _sports.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _sports.map((sport) {
          return matchesAsync.when(
            data: (matches) => _MatchList(matches: matches, sport: sport),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/teams'),
        icon: const Icon(Icons.add),
        label: const Text('チームを追加'),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches, required this.sport});

  final List<Match> matches;
  final String sport;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('フォロー中のチームがありません'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.go('/teams'),
              child: const Text('チームを選ぶ'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => MatchCard(match: matches[i]),
    );
  }
}
