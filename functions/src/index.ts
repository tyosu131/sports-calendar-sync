import { initializeApp } from "firebase-admin/app";
import * as functions from "firebase-functions/v2";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

import { syncLeagueMatches } from "./pipelines/matchSyncPipeline";
import { generateIcsForUser } from "./calendar/icsGenerator";

initializeApp();

const RAPIDAPI_KEY = defineSecret("RAPIDAPI_KEY");

// ============================================================================
// 1. 定期同期: 毎日 JST 06:00 (= UTC 21:00 前日) に実行
//    Cloud Scheduler = Next.js の cron job (Vercel Cron) に相当
// ============================================================================
export const syncMatches = onSchedule(
  {
    schedule: "0 21 * * *",
    timeZone: "UTC",
    secrets: [RAPIDAPI_KEY],
    region: "asia-northeast1",
  },
  async () => {
    const apiKey = RAPIDAPI_KEY.value();

    const leagues = [
      { leagueId: 98,  firestoreId: "j1",  season: 2024 }, // J1
      { leagueId: 39,  firestoreId: "pl",  season: 2024 }, // Premier League
      { leagueId: 140, firestoreId: "lla", season: 2024 }, // La Liga
      { leagueId: 135, firestoreId: "sa",  season: 2024 }, // Serie A
      { leagueId: 78,  firestoreId: "bun", season: 2024 }, // Bundesliga
      { leagueId: 61,  firestoreId: "l1",  season: 2024 }, // Ligue 1
      { leagueId: 2,   firestoreId: "ucl", season: 2024 }, // UEFA CL
    ];

    for (const league of leagues) {
      const count = await syncLeagueMatches({
        leagueId: league.leagueId,
        leagueFirestoreId: league.firestoreId,
        season: league.season,
        rapidApiKey: apiKey,
      });
      functions.logger.info(`Synced ${count} matches for league: ${league.firestoreId}`);
    }
  }
);

// ============================================================================
// 2. iCalendar (.ics) 配信エンドポイント
//    GET /getCalendar?uid=XXX&token=YYY
//    Next.js の Route Handler に相当
// ============================================================================
export const getCalendar = onRequest(
  { region: "asia-northeast1", cors: false },
  async (req, res) => {
    const uid = req.query.uid as string | undefined;
    const token = req.query.token as string | undefined;

    if (!uid || !token) {
      res.status(400).send("Missing uid or token");
      return;
    }

    try {
      // TODO: token 検証 (users/{uid}.calendarToken と照合)
      const icsContent = await generateIcsForUser(uid);

      res.setHeader("Content-Type", "text/calendar; charset=utf-8");
      res.setHeader(
        "Content-Disposition",
        'attachment; filename="sports-calendar.ics"'
      );
      res.status(200).send(icsContent);
    } catch (err) {
      functions.logger.error("getCalendar error", err);
      res.status(500).send("Internal Server Error");
    }
  }
);

// ============================================================================
// 3. 手動トリガー: 特定リーグを即時同期 (開発/管理用)
//    POST /triggerSync { leagueId, firestoreId, season }
// ============================================================================
export const triggerSync = onRequest(
  {
    region: "asia-northeast1",
    secrets: [RAPIDAPI_KEY],
    invoker: "private", // Firebase Auth で保護
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const { leagueId, firestoreId, season } = req.body;
    const count = await syncLeagueMatches({
      leagueId,
      leagueFirestoreId: firestoreId,
      season,
      rapidApiKey: RAPIDAPI_KEY.value(),
    });

    res.json({ synced: count });
  }
);
