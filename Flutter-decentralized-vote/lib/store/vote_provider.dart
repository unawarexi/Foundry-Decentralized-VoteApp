import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/vote_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/vote_repository.dart';

final voteRepositoryProvider =
    Provider<VoteRepository>((ref) => VoteRepository());

/// Current user's voting history.
final myVotesProvider = FutureProvider<List<VoteModel>>((ref) async {
  return ref.read(voteRepositoryProvider).getMyVotes();
});

/// Whether the user has voted in a specific election.
final hasVotedProvider =
    FutureProvider.family<bool, String>((ref, electionId) async {
  return ref.read(voteRepositoryProvider).hasVoted(electionId);
});

// ── Cast Vote Notifier ───────────────────────────────────────────────────────

enum CastVoteStatus { idle, loading, success, error }

class CastVoteState {
  final CastVoteStatus status;
  final VoteModel? vote;
  final String? error;
  const CastVoteState({
    this.status = CastVoteStatus.idle,
    this.vote,
    this.error,
  });
  CastVoteState copyWith({CastVoteStatus? status, VoteModel? vote, String? error}) =>
      CastVoteState(
          status: status ?? this.status,
          vote: vote ?? this.vote,
          error: error ?? this.error);
}

final castVoteProvider =
    StateNotifierProvider<CastVoteNotifier, CastVoteState>((ref) {
  return CastVoteNotifier(ref);
});

class CastVoteNotifier extends StateNotifier<CastVoteState> {
  final Ref _ref;
  CastVoteNotifier(this._ref) : super(const CastVoteState());

  Future<void> cast({
    required String electionId,
    required String candidateId,
    String? nullifier,
    String? zkProof,
  }) async {
    state = state.copyWith(status: CastVoteStatus.loading);
    try {
      final vote = await _ref.read(voteRepositoryProvider).castVote(
            electionId: electionId,
            candidateId: candidateId,
            nullifier: nullifier,
            zkProof: zkProof,
          );
      state = state.copyWith(status: CastVoteStatus.success, vote: vote);
      // Invalidate cached vote status for this election
      _ref.invalidate(hasVotedProvider(electionId));
      _ref.invalidate(myVotesProvider);
    } catch (e) {
      state = state.copyWith(status: CastVoteStatus.error, error: e.toString());
    }
  }

  void reset() => state = const CastVoteState();
}
