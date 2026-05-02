import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/election_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/election_repository.dart';

final electionRepositoryProvider =
    Provider<ElectionRepository>((ref) => ElectionRepository());

/// All currently active elections.
final activeElectionsProvider =
    FutureProvider<List<ElectionModel>>((ref) async {
  return ref.read(electionRepositoryProvider).getActiveElections();
});

/// All elections, optionally filtered by [status].
final allElectionsProvider =
    FutureProvider.family<List<ElectionModel>, String?>((ref, status) async {
  return ref.read(electionRepositoryProvider).getElections(status: status);
});

/// Elections for the current user's region.
final regionElectionsProvider =
    FutureProvider.family<List<ElectionModel>, String>((ref, regionId) async {
  return ref.read(electionRepositoryProvider).getElectionsByRegion(regionId);
});

/// Single election by ID.
final electionByIdProvider =
    FutureProvider.family<ElectionModel, String>((ref, id) async {
  return ref.read(electionRepositoryProvider).getElectionById(id);
});

/// Election results (raw JSON map — keyed by candidateId).
final electionResultsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  return ref.read(electionRepositoryProvider).getElectionResults(id);
});

/// Tracks the election the user is currently viewing.
final selectedElectionProvider =
    StateProvider<ElectionModel?>((ref) => null);

/// WebSocket-driven live vote count updates for the selected election.
/// Backend emits 'election:vote_cast' with { electionId, candidateId, totalVotes }.
final liveVoteCountProvider =
    StateProvider.family<int, String>((ref, candidateId) => 0);
