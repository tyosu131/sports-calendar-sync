import 'broadcast_platform.dart';

enum MatchStatus { scheduled, live, finished, postponed, cancelled }

/// 試合エンティティ。
/// Firestore には UTC/JST/timezone の3形式で保存 (要件 A に対応)。
class Match {
  const Match({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamNameJa,
    required this.awayTeamNameJa,
    required this.leagueId,
    required this.leagueNameJa,
    required this.startTimeUTC,
    required this.startTimeJST,
    required this.timezone,
    required this.status,
    this.venue,
    this.broadcastPlatforms = const [],
    this.isCustom = false,
  });

  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamNameJa;
  final String awayTeamNameJa;
  final String leagueId;
  final String leagueNameJa;
  final DateTime startTimeUTC;   // カレンダー連携用
  final String startTimeJST;     // 日本国内表示用 e.g. "2024/04/06 19:00"
  final String timezone;         // 開催地 e.g. "Asia/Tokyo"
  final MatchStatus status;
  final String? venue;
  final List<BroadcastPlatform> broadcastPlatforms;
  final bool isCustom;           // アマチュア/手動登録イベント

  factory Match.fromMap(String id, Map<String, dynamic> map) {
    return Match(
      id: id,
      homeTeamId: map['homeTeamId'] as String,
      awayTeamId: map['awayTeamId'] as String,
      homeTeamNameJa: map['homeTeamNameJa'] as String? ?? '',
      awayTeamNameJa: map['awayTeamNameJa'] as String? ?? '',
      leagueId: map['leagueId'] as String,
      leagueNameJa: map['leagueNameJa'] as String? ?? '',
      startTimeUTC: (map['startTimeUTC'] as dynamic).toDate() as DateTime,
      startTimeJST: map['startTimeJST'] as String,
      timezone: map['timezone'] as String,
      status: MatchStatus.values.byName(
        (map['status'] as String? ?? 'scheduled'),
      ),
      venue: map['venue'] as String?,
      broadcastPlatforms: (map['broadcastPlatforms'] as List<dynamic>? ?? [])
          .map((e) => BroadcastPlatform.fromMap(e as Map<String, dynamic>))
          .toList(),
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'homeTeamId': homeTeamId,
        'awayTeamId': awayTeamId,
        'homeTeamNameJa': homeTeamNameJa,
        'awayTeamNameJa': awayTeamNameJa,
        'leagueId': leagueId,
        'leagueNameJa': leagueNameJa,
        'startTimeUTC': startTimeUTC,
        'startTimeJST': startTimeJST,
        'timezone': timezone,
        'status': status.name,
        if (venue != null) 'venue': venue,
        'broadcastPlatforms':
            broadcastPlatforms.map((b) => b.toMap()).toList(),
        'isCustom': isCustom,
      };
}
