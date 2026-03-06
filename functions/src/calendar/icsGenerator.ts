import ical, { ICalCalendarMethod } from "ical-generator";
import { getFirestore } from "firebase-admin/firestore";
import { MatchDoc, BroadcastPlatform } from "../types";

// ============================================================================
// iCalendar (.ics) 動的生成
// URL: https://[region]-[projectId].cloudfunctions.net/getCalendar?uid=XXX&token=YYY
//
// カレンダーの Description に配信プラットフォーム情報を付与 (要件 C)。
// ============================================================================

export async function generateIcsForUser(uid: string): Promise<string> {
  const db = getFirestore();

  // ユーザーのフォロー中チーム取得
  const userSnap = await db.collection("users").doc(uid).get();
  if (!userSnap.exists) throw new Error("User not found");

  const followedTeams: string[] = userSnap.data()?.followedTeams ?? [];
  if (followedTeams.length === 0) return createEmptyCalendar();

  // フォロー中チームの試合を取得 (直近3ヶ月)
  const threeMonthsLater = new Date();
  threeMonthsLater.setMonth(threeMonthsLater.getMonth() + 3);

  // Firestore の whereIn は10件上限のため、10件ずつ分割クエリ
  const allMatches: (MatchDoc & { id: string })[] = [];
  for (let i = 0; i < followedTeams.length; i += 10) {
    const chunk = followedTeams.slice(i, i + 10);

    const homeSnap = await db
      .collection("matches")
      .where("homeTeamId", "in", chunk)
      .where("startTimeUTC", "<=", threeMonthsLater)
      .orderBy("startTimeUTC")
      .get();

    const awaySnap = await db
      .collection("matches")
      .where("awayTeamId", "in", chunk)
      .where("startTimeUTC", "<=", threeMonthsLater)
      .orderBy("startTimeUTC")
      .get();

    homeSnap.docs.forEach((d) =>
      allMatches.push({ ...(d.data() as MatchDoc), id: d.id })
    );
    awaySnap.docs.forEach((d) =>
      allMatches.push({ ...(d.data() as MatchDoc), id: d.id })
    );
  }

  // 重複排除
  const unique = Array.from(new Map(allMatches.map((m) => [m.id, m])).values());

  return buildIcs(unique);
}

function buildIcs(matches: (MatchDoc & { id: string })[]): string {
  const cal = ical({
    name: "Sports Calendar Sync",
    method: ICalCalendarMethod.PUBLISH,
    prodId: "//SportsCalendarSync//JP",
  });

  for (const match of matches) {
    const start = match.startTimeUTC.toDate();
    const end = new Date(start.getTime() + 2 * 60 * 60 * 1000); // デフォルト2時間

    const description = buildDescription(
      match.homeTeamNameJa,
      match.awayTeamNameJa,
      match.broadcastPlatforms
    );

    cal.createEvent({
      id: match.id,
      start,
      end,
      timezone: match.timezone,
      summary: `${match.homeTeamNameJa} vs ${match.awayTeamNameJa}`,
      description,
      location: match.venue,
    });
  }

  return cal.toString();
}

/**
 * Description 欄の生成。
 * 配信プラットフォーム情報をテキストで付与 (要件 C)。
 */
function buildDescription(
  home: string,
  away: string,
  platforms: BroadcastPlatform[]
): string {
  const lines: string[] = [
    `${home} vs ${away}`,
    "",
  ];

  if (platforms.length > 0) {
    lines.push("【配信・放送】");
    platforms.forEach((p) => {
      const typeLabel = {
        streaming: "配信",
        terrestrial: "地上波",
        bs: "BS",
        cs: "CS",
      }[p.type];
      lines.push(`• ${p.name} (${typeLabel})${p.url ? ` - ${p.url}` : ""}`);
    });
  }

  return lines.join("\n");
}

function createEmptyCalendar(): string {
  return ical({ name: "Sports Calendar Sync" }).toString();
}
