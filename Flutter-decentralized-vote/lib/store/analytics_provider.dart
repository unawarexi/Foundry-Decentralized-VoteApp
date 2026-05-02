import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/analytics_repository.dart';

final analyticsRepositoryProvider =
    Provider<AnalyticsRepository>((ref) => AnalyticsRepository());

final platformStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.read(analyticsRepositoryProvider).getPlatformStats();
});

final electionAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, electionId) async {
  return ref
      .read(analyticsRepositoryProvider)
      .getElectionAnalytics(electionId);
});

final turnoutByRegionProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, electionId) async {
  return ref
      .read(analyticsRepositoryProvider)
      .getTurnoutByRegion(electionId);
});
