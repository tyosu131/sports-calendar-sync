import axios from "axios";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

import { translateLeagueName, translateTeamName } from "../translations/translationMap";
import { RapidApiFixture, MatchDoc, MatchStatus } from "../types";
import { normalizeMatchTime } from "../utils/timezoneUtils";

// ============================================================================
// Match Sync Pipeline
// 処理フロー: 外部API取得 → 時差変換 → 翻訳マップ適用 → Firestore 保存
// Next.js API Route の感覚で書いているが、これは Cloud Function から呼ぶユーティリティ関数。
// ============================================================================

const RAPIDAPI_HOST = "api-football-v1.p.rapidapi.com";

interface SyncOptions {
  leagueId: number;
  leagueFirestoreId: string;
  season: number;
  rapidApiKey: string;
}

/**
 * 指定リーグの試合日程を RapidAPI から取得し Firestore に upsert する。
 * 冪等性担保: externalMatchId でドキュメントを特定し上書き。
 */
export async function syncLeagueMatches(options: SyncOptions): Promise<number> {
  const { leagueId, leagueFirestoreId, season, rapidApiKey } = options;
  const db = getFirestore();

  // --- Step 1: 外部 API からデータ取得 ---
  const response = await axios.get<{ response: RapidApiFixture[] }>(
    `https://${RAPIDAPI_HOST}/fixtures`,
    {
      params: { league: leagueId, season },
      headers: {
        "x-rapidapi-host": RAPIDAPI_HOST,
        "x-rapidapi-key": rapidApiKey,
      },
    }
  );

  const fixtures = response.data.response;
  if (!fixtures || fixtures.length === 0) return 0;

  // --- Step 2: バッチ処理で Firestore に保存 ---
  const batch = db.batch();
  let count = 0;

  for (const fixture of fixtures) {
    const { fixture: f, teams, league } = fixture;

    // Step 2a: 時差変換 (UTC → JST + UTC Timestamp)
    const venueTimezone = f.timezone ?? "UTC";
    const normalizedTime = normalizeMatchTime(f.date, venueTimezone);

    // Step 2b: 翻訳マップ適用
    const homeTeamNameJa = translateTeamName(teams.home.name);
    const awayTeamNameJa = translateTeamName(teams.away.name);
    const leagueNameJa = translateLeagueName(league.name);

    // Step 2c: ステータス正規化
    const status = normalizeStatus(f.status.short);

    // Step 2d: Firestore ドキュメント ID = "leagueId_externalMatchId" で冪等
    const docId = `${leagueFirestoreId}_${f.id}`;
    const ref = db.collection("matches").doc(docId);

    const matchDoc: MatchDoc = {
      homeTeamId: `team_${teams.home.id}`,
      awayTeamId: `team_${teams.away.id}`,
      homeTeamNameJa,
      awayTeamNameJa,
      leagueId: leagueFirestoreId,
      leagueNameJa,
      ...normalizedTime,
      venue: f.venue?.name,
      status,
      broadcastPlatforms: [], // 配信情報は別途 broadcastsコレクション or 手動マスタで管理
      isCustom: false,
      externalMatchId: String(f.id),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    };

    batch.set(ref, matchDoc, { merge: true });
    count++;

    // Firestore batch は500件上限
    if (count % 499 === 0) {
      await batch.commit();
    }
  }

  await batch.commit();
  return count;
}

function normalizeStatus(apiStatus: string): MatchStatus {
  // API-Football の status.short → 内部 MatchStatus
  const map: Record<string, MatchStatus> = {
    NS: "scheduled",
    TBD: "scheduled",
    "1H": "live",
    HT: "live",
    "2H": "live",
    ET: "live",
    P: "live",
    FT: "finished",
    AET: "finished",
    PEN: "finished",
    PST: "postponed",
    CANC: "cancelled",
    SUSP: "postponed",
  };
  return map[apiStatus] ?? "scheduled";
}
