/// Firestore users/{uid} ドキュメントに対応するユーザーモデル。
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.followedTeamIds,
    required this.calendarToken,
    this.locale = 'ja',
  });

  final String uid;
  final String email;
  final String displayName;
  final List<String> followedTeamIds;
  final String calendarToken; // .ics URL 発行用のシークレットトークン
  final String locale;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      followedTeamIds:
          List<String>.from(map['followedTeams'] as List<dynamic>? ?? []),
      calendarToken: map['calendarToken'] as String? ?? '',
      locale: map['locale'] as String? ?? 'ja',
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'followedTeams': followedTeamIds,
        'calendarToken': calendarToken,
        'locale': locale,
      };

  AppUser copyWith({List<String>? followedTeamIds}) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      followedTeamIds: followedTeamIds ?? this.followedTeamIds,
      calendarToken: calendarToken,
      locale: locale,
    );
  }
}
