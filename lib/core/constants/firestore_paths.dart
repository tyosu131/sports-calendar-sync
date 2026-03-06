/// Firestore コレクションパスの定数管理。
/// Supabase でいうテーブル名に相当。
class FirestorePaths {
  static const users = 'users';
  static const leagues = 'leagues';
  static const teams = 'teams';
  static const matches = 'matches';
  static const broadcasts = 'broadcasts';

  static String userDoc(String uid) => '$users/$uid';
  static String matchDoc(String matchId) => '$matches/$matchId';
  static String teamDoc(String teamId) => '$teams/$teamId';
}
