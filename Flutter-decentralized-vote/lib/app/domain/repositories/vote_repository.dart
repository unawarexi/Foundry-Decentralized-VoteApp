import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/app/domain/models/vote_model.dart';

class VoteRepository {
  final _api = ApiClient.instance;

  Future<VoteModel> castVote({
    required String electionId,
    required String candidateId,
    String? nullifier,
    String? zkProof,
  }) async {
    final res = await _api.post(ApiEndpoints.castVote, data: {
      'electionId': electionId,
      'candidateId': candidateId,
      if (nullifier != null) 'nullifier': nullifier,
      if (zkProof != null) 'zkProof': zkProof,
    });
    return VoteModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<VoteModel>> getMyVotes() async {
    final res = await _api.get(ApiEndpoints.myVotes);
    final list = res.data['data'] as List;
    return list.map((e) => VoteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<bool> hasVoted(String electionId) async {
    final res = await _api.get(ApiEndpoints.voteStatus(electionId));
    return res.data['data']['hasVoted'] as bool? ?? false;
  }
}
