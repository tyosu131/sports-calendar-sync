/// タイムゾーン変換ユーティリティ。
/// メイン変換ロジックは Cloud Functions 側で行うが、
/// 表示フォーマット補助をここで担う。
class TimezoneUtils {
  static const _jstOffset = Duration(hours: 9);

  /// UTC DateTime → JST 表示文字列
  static String toJstDisplayString(DateTime utc) {
    final jst = utc.toUtc().add(_jstOffset);
    final y = jst.year;
    final m = jst.month.toString().padLeft(2, '0');
    final d = jst.day.toString().padLeft(2, '0');
    final hh = jst.hour.toString().padLeft(2, '0');
    final mm = jst.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $hh:$mm JST';
  }

  /// JST 文字列 → DateTime (UTC)
  static DateTime jstStringToUtc(String jstString) {
    final dt = DateTime.parse(jstString);
    return dt.subtract(_jstOffset);
  }
}
