// ============================================================================
// Shared Types — Firestore Document Schemas
// ============================================================================

export type Sport =
  | "soccer"
  | "baseball"
  | "basketball"
  | "americanFootball"
  | "hockey"
  | "tennis"
  | "motorsport"
  | "custom";

export type MatchStatus =
  | "scheduled"
  | "live"
  | "finished"
  | "postponed"
  | "cancelled";

export type BroadcastType = "streaming" | "terrestrial" | "bs" | "cs";

export interface BroadcastPlatform {
  name: string;       // "DAZN" | "U-NEXT" | "ABEMA" | "NHK" | etc.
  type: BroadcastType;
  region: string;     // "JP" | "global"
  url?: string;
}

// ---------------------------------------------------------------------------
// Firestore: matches/{matchId}
// ---------------------------------------------------------------------------
export interface MatchDoc {
  homeTeamId: string;
  awayTeamId: string;
  homeTeamNameJa: string;
  awayTeamNameJa: string;
  leagueId: string;
  leagueNameJa: string;
  startTimeUTC: FirebaseFirestore.Timestamp; // カレンダー連携用
  startTimeJST: string;                      // 日本国内表示 e.g. "2024/04/06 19:00"
  timezone: string;                          // 開催地 e.g. "Asia/Tokyo"
  venue?: string;
  status: MatchStatus;
  broadcastPlatforms: BroadcastPlatform[];
  isCustom: boolean;
  externalMatchId?: string;                  // 外部API の試合ID (冪等処理用)
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

// ---------------------------------------------------------------------------
// Firestore: teams/{teamId}
// ---------------------------------------------------------------------------
export interface TeamDoc {
  name: string;
  nameJa: string;
  leagueId: string;
  sport: Sport;
  externalId?: string;
  logoUrl?: string;
}

// ---------------------------------------------------------------------------
// Firestore: leagues/{leagueId}
// ---------------------------------------------------------------------------
export interface LeagueDoc {
  name: string;
  nameJa: string;
  sport: Sport;
  country: string;
  apiSource: string;   // "api-football" | "api-baseball" | "custom"
  externalId?: string;
  season?: string;
}

// ---------------------------------------------------------------------------
// Firestore: users/{uid}
// ---------------------------------------------------------------------------
export interface UserDoc {
  email: string;
  displayName: string;
  followedTeams: string[];
  calendarToken: string;
  locale: string;
  createdAt: FirebaseFirestore.Timestamp;
}

// ---------------------------------------------------------------------------
// RapidAPI Response (API-Football / api-football.com)
// ---------------------------------------------------------------------------
export interface RapidApiFixture {
  fixture: {
    id: number;
    date: string;    // ISO 8601 UTC
    timezone: string;
    venue: { name: string; city: string } | null;
    status: { short: string };
  };
  league: { id: number; name: string; country: string };
  teams: {
    home: { id: number; name: string; logo: string };
    away: { id: number; name: string; logo: string };
  };
}
