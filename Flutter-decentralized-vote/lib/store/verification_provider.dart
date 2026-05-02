import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/verification_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/verification_repository.dart';

final verificationRepositoryProvider =
    Provider<VerificationRepository>((ref) => VerificationRepository());

enum VerificationStep { idle, loading, passed, failed }

class VerificationState {
  final VerificationStep faceStep;
  final VerificationStep livenessStep;
  final VerificationStep idStep;
  final String? failReason;
  final VerificationModel? lastResult;

  const VerificationState({
    this.faceStep = VerificationStep.idle,
    this.livenessStep = VerificationStep.idle,
    this.idStep = VerificationStep.idle,
    this.failReason,
    this.lastResult,
  });

  bool get allPassed =>
      faceStep == VerificationStep.passed &&
      livenessStep == VerificationStep.passed &&
      idStep == VerificationStep.passed;

  VerificationState copyWith({
    VerificationStep? faceStep,
    VerificationStep? livenessStep,
    VerificationStep? idStep,
    String? failReason,
    VerificationModel? lastResult,
  }) =>
      VerificationState(
        faceStep: faceStep ?? this.faceStep,
        livenessStep: livenessStep ?? this.livenessStep,
        idStep: idStep ?? this.idStep,
        failReason: failReason ?? this.failReason,
        lastResult: lastResult ?? this.lastResult,
      );
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>(
        (ref) => VerificationNotifier(ref));

class VerificationNotifier extends StateNotifier<VerificationState> {
  final Ref _ref;
  VerificationNotifier(this._ref) : super(const VerificationState());

  Future<void> runFaceVerification(String imagePath) async {
    state = state.copyWith(faceStep: VerificationStep.loading);
    try {
      final result = await _ref
          .read(verificationRepositoryProvider)
          .verifyFace(imagePath);
      state = state.copyWith(
        faceStep:
            result.isPassed ? VerificationStep.passed : VerificationStep.failed,
        lastResult: result,
        failReason: result.failReason,
      );
    } catch (e) {
      state = state.copyWith(
          faceStep: VerificationStep.failed, failReason: e.toString());
    }
  }

  Future<void> runLivenessCheck(String videoPath) async {
    state = state.copyWith(livenessStep: VerificationStep.loading);
    try {
      final result = await _ref
          .read(verificationRepositoryProvider)
          .livenessCheck(videoPath);
      state = state.copyWith(
        livenessStep:
            result.isPassed ? VerificationStep.passed : VerificationStep.failed,
        lastResult: result,
        failReason: result.failReason,
      );
    } catch (e) {
      state = state.copyWith(
          livenessStep: VerificationStep.failed, failReason: e.toString());
    }
  }

  Future<void> runIdScan(String imagePath) async {
    state = state.copyWith(idStep: VerificationStep.loading);
    try {
      final result =
          await _ref.read(verificationRepositoryProvider).scanId(imagePath);
      state = state.copyWith(
        idStep:
            result.isPassed ? VerificationStep.passed : VerificationStep.failed,
        lastResult: result,
        failReason: result.failReason,
      );
    } catch (e) {
      state = state.copyWith(
          idStep: VerificationStep.failed, failReason: e.toString());
    }
  }

  void reset() => state = const VerificationState();
}
