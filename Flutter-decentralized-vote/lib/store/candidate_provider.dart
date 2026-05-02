import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/candidate_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/candidate_repository.dart';

final candidateRepositoryProvider =
    Provider<CandidateRepository>((ref) => CandidateRepository());

/// Candidates for a given election ID.
final candidatesByElectionProvider =
    FutureProvider.family<List<CandidateModel>, String>(
        (ref, electionId) async {
  return ref
      .read(candidateRepositoryProvider)
      .getCandidatesByElection(electionId);
});

/// Single candidate profile.
final candidateByIdProvider =
    FutureProvider.family<CandidateModel, String>((ref, id) async {
  return ref.read(candidateRepositoryProvider).getCandidateById(id);
});

/// Currently viewed candidate (set before navigating to detail screen).
final selectedCandidateProvider =
    StateProvider<CandidateModel?>((ref) => null);

// ── Registration notifier ────────────────────────────────────────────────────

enum RegisterCandidateStatus { idle, loading, success, error }

class RegisterCandidateState {
  final RegisterCandidateStatus status;
  final CandidateModel? candidate;
  final String? error;
  const RegisterCandidateState({
    this.status = RegisterCandidateStatus.idle,
    this.candidate,
    this.error,
  });
  RegisterCandidateState copyWith({
    RegisterCandidateStatus? status,
    CandidateModel? candidate,
    String? error,
  }) =>
      RegisterCandidateState(
          status: status ?? this.status,
          candidate: candidate ?? this.candidate,
          error: error ?? this.error);
}

final registerCandidateProvider =
    StateNotifierProvider<RegisterCandidateNotifier, RegisterCandidateState>(
        (ref) => RegisterCandidateNotifier(ref));

class RegisterCandidateNotifier
    extends StateNotifier<RegisterCandidateState> {
  final Ref _ref;
  RegisterCandidateNotifier(this._ref) : super(const RegisterCandidateState());

  Future<void> register(Map<String, dynamic> fields) async {
    state = state.copyWith(status: RegisterCandidateStatus.loading);
    try {
      final candidate =
          await _ref.read(candidateRepositoryProvider).registerCandidate(
                electionId: fields['electionId'] as String,
                roleName: fields['roleName'] as String,
                partyName: fields['partyName'] as String,
                roleCategory: fields['roleCategory'] as String?,
                biography: fields['biography'] as String?,
                achievements: fields['achievements'] as String?,
                careerJourney: fields['careerJourney'] as String?,
                logoUrl: fields['logoUrl'] as String?,
                slogan: fields['slogan'] as String?,
                payoutAddress: fields['payoutAddress'] as String?,
              );
      state = state.copyWith(
          status: RegisterCandidateStatus.success, candidate: candidate);
    } catch (e) {
      state = state.copyWith(
          status: RegisterCandidateStatus.error, error: e.toString());
    }
  }

  void reset() => state = const RegisterCandidateState();
}
