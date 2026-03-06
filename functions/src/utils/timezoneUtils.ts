import { DateTime } from "luxon";
import { Timestamp } from "firebase-admin/firestore";

export interface NormalizedTime {
  startTimeUTC: Timestamp;
  startTimeJST: string;
  timezone: string;
}

/**
 * 外部 API の UTC ISO 文字列を3形式に正規化する。
 * 要件 A: UTC → JST / User Local Time 変換はすべて Cloud Functions 側で処理。
 *
 * @param utcIso - 外部 API から取得した UTC 日時文字列 e.g. "2024-04-06T10:00:00Z"
 * @param venueTimezone - 開催地タイムゾーン e.g. "Asia/Tokyo" (API から取得)
 */
export function normalizeMatchTime(
  utcIso: string,
  venueTimezone: string
): NormalizedTime {
  const utcDt = DateTime.fromISO(utcIso, { zone: "UTC" });

  if (!utcDt.isValid) {
    throw new Error(`Invalid UTC datetime string: ${utcIso}`);
  }

  const jstDt = utcDt.setZone("Asia/Tokyo");
  const startTimeJST = jstDt.toFormat("yyyy/MM/dd HH:mm");

  return {
    startTimeUTC: Timestamp.fromDate(utcDt.toJSDate()),
    startTimeJST,
    timezone: venueTimezone,
  };
}
