import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore/match_firestore_repository.dart';
import '../../data/firestore/team_firestore_repository.dart';
import '../../data/firestore/user_firestore_repository.dart';
import '../../domain/repositories/match_repository.dart';
import '../../domain/repositories/team_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Firestore インスタンスの DI。
/// Kotlin の Hilt/Koin に相当するが Riverpod はコード生成不要で軽量。
final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchFirestoreRepository(ref.watch(firestoreProvider));
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamFirestoreRepository(ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserFirestoreRepository(ref.watch(firestoreProvider));
});
