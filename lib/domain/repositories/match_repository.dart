import '../models/match.dart';

/// Repository インターフェース (Kotlin の interface と同じ概念)。
/// Firestore 実装を差し替えても上位レイヤーが壊れない。
abstract interface class MatchRepository {
  /// フォロー中チームの試合一覧をリアルタイム購読 (Firestore onSnapshot)。
  /// React の `useEffect + subscription` に相当し、Riverpod StreamProvider で消費する。
  Stream<List<Match>> watchMatchesByTeamIds(List<String> teamIds);

  /// 特定試合の詳細取得
  Future<Match?> fetchMatch(String matchId);
}
