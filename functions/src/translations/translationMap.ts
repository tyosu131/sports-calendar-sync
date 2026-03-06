// ============================================================================
// 翻訳マッピングテーブル (英語 → 日本語)
// Cloud Functions 内で適用。Firestore に永続化してもよい。
// ============================================================================

export const teamNameMap: Record<string, string> = {
  // J-League
  "Urawa Red Diamonds": "浦和レッズ",
  "Gamba Osaka": "ガンバ大阪",
  "Yokohama F. Marinos": "横浜F・マリノス",
  "Kashima Antlers": "鹿島アントラーズ",
  "FC Tokyo": "FC東京",
  "Vissel Kobe": "ヴィッセル神戸",
  "Nagoya Grampus": "名古屋グランパス",
  "Sanfrecce Hiroshima": "サンフレッチェ広島",
  // Premier League
  "Manchester City": "マンチェスター・シティ",
  "Arsenal": "アーセナル",
  "Liverpool": "リバプール",
  "Chelsea": "チェルシー",
  "Manchester United": "マンチェスター・ユナイテッド",
  "Tottenham Hotspur": "トッテナム・ホットスパー",
  // La Liga
  "Real Madrid": "レアル・マドリード",
  "FC Barcelona": "バルセロナ",
  "Atletico Madrid": "アトレティコ・マドリード",
  // MLB
  "Los Angeles Dodgers": "ロサンゼルス・ドジャース",
  "New York Yankees": "ニューヨーク・ヤンキース",
  // NBA
  "Golden State Warriors": "ゴールデンステイト・ウォリアーズ",
  "Los Angeles Lakers": "ロサンゼルス・レイカーズ",
  // NFL
  "Kansas City Chiefs": "カンザスシティ・チーフス",
  "San Francisco 49ers": "サンフランシスコ・49ers",
};

export const leagueNameMap: Record<string, string> = {
  "J1 League": "Jリーグ J1",
  "J2 League": "Jリーグ J2",
  "J3 League": "Jリーグ J3",
  "Premier League": "プレミアリーグ",
  "La Liga": "ラ・リーガ",
  "Serie A": "セリエA",
  "Bundesliga": "ブンデスリーガ",
  "Ligue 1": "リーグ・アン",
  "UEFA Champions League": "UEFAチャンピオンズリーグ",
  "UEFA Europa League": "UEFAヨーロッパリーグ",
  "MLS": "メジャーリーグサッカー",
  "NPB": "プロ野球 (NPB)",
  "MLB": "メジャーリーグベースボール",
  "NBA": "NBA",
  "B.League": "Bリーグ",
  "NFL": "NFL",
  "NHL": "NHL",
};

export function translateTeamName(enName: string): string {
  return teamNameMap[enName] ?? enName;
}

export function translateLeagueName(enName: string): string {
  return leagueNameMap[enName] ?? enName;
}
