import '../models/team.dart';

abstract interface class TeamRepository {
  Future<List<Team>> fetchTeamsBySport(String sport);
  Future<List<Team>> fetchTeamsByLeague(String leagueId);
  Future<List<Team>> fetchTeamsByIds(List<String> ids);
  Future<void> followTeam(String uid, String teamId);
  Future<void> unfollowTeam(String uid, String teamId);
}
