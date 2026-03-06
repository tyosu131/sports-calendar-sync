/// リーグ/大会マスタ。
/// 将来の高校野球・ユース等のカスタムリーグも `apiSource: 'custom'` で収容する。
enum Sport {
  soccer,
  baseball,
  basketball,
  americanFootball,
  hockey,
  tennis,
  motorsport,
  custom,
}

class League {
  const League({
    required this.id,
    required this.name,
    required this.nameJa,
    required this.sport,
    required this.country,
    required this.apiSource,
    this.externalId,
    this.season,
  });

  final String id;
  final String name;       // "J-League J1" (API から取得した英語名)
  final String nameJa;     // "Jリーグ J1" (翻訳マップ適用後)
  final Sport sport;
  final String country;    // "JP" | "EN" | "global"
  final String apiSource;  // "api-football" | "api-baseball" | "custom"
  final String? externalId;
  final String? season;

  factory League.fromMap(String id, Map<String, dynamic> map) {
    return League(
      id: id,
      name: map['name'] as String,
      nameJa: map['nameJa'] as String,
      sport: Sport.values.byName(map['sport'] as String),
      country: map['country'] as String,
      apiSource: map['apiSource'] as String,
      externalId: map['externalId'] as String?,
      season: map['season'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameJa': nameJa,
        'sport': sport.name,
        'country': country,
        'apiSource': apiSource,
        if (externalId != null) 'externalId': externalId,
        if (season != null) 'season': season,
      };
}
