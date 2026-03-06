import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'user_provider.dart';

/// .ics URL を動的に生成するプロバイダ。
/// Cloud Functions エンドポイント + uid + calendarToken で構成。
const _functionsBaseUrl =
    'https://asia-northeast1-YOUR_PROJECT_ID.cloudfunctions.net';

final calendarUrlProvider = Provider<String?>((ref) {
  final user = ref.watch(appUserProvider).valueOrNull;
  final authUser = ref.watch(currentUserProvider);
  if (user == null || authUser == null) return null;

  return '$_functionsBaseUrl/getCalendar?uid=${authUser.uid}&token=${user.calendarToken}';
});
