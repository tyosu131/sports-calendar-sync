import 'league.dart';

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.nameJa,
    required this.leagueId,
    required this.sport,
    this.externalId,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String nameJa;
  final String leagueId;
  final Sport sport;
  final String? externalId;
  final String? logoUrl;

  factory Team.fromMap(String id, Map<String, dynamic> map) {
    return Team(
      id: id,
      name: map['name'] as String,
      nameJa: map['nameJa'] as String,
      leagueId: map['leagueId'] as String,
      sport: Sport.values.byName(map['sport'] as String),
      externalId: map['externalId'] as String?,
      logoUrl: map['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameJa': nameJa,
        'leagueId': leagueId,
        'sport': sport.name,
        if (externalId != null) 'externalId': externalId,
        if (logoUrl != null) 'logoUrl': logoUrl,
      };
}
