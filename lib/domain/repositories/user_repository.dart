import '../models/app_user.dart';

abstract interface class UserRepository {
  Future<AppUser?> fetchUser(String uid);
  Stream<AppUser?> watchUser(String uid);
  Future<void> createUser(AppUser user);
  Future<void> updateFollowedTeams(String uid, List<String> teamIds);
}
