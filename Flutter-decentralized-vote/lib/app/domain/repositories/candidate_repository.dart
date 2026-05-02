import 'package:dio/dio.dart';
import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/app/domain/models/candidate_model.dart';

class CandidateRepository {
  final _api = ApiClient.instance;

  Future<List<CandidateModel>> getCandidatesByElection(String electionId) async {
    final res = await _api.get(ApiEndpoints.candidatesByElection(electionId));
    final list = res.data['data'] as List;
    return list.map((e) => CandidateModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CandidateModel> getCandidateById(String id) async {
    final res = await _api.get(ApiEndpoints.candidateById(id));
    return CandidateModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<CandidateModel> registerCandidate({
    required String electionId,
    required String roleName,
    required String partyName,
    String? roleCategory,
    String? biography,
    String? achievements,
    String? careerJourney,
    String? manifestoUrl,
    String? videoUrl,
    String? logoUrl,
    String? slogan,
    String? payoutAddress,
  }) async {
    final res = await _api.post(ApiEndpoints.registerCandidate, data: {
      'electionId': electionId,
      'roleName': roleName,
      'partyName': partyName,
      if (roleCategory != null) 'roleCategory': roleCategory,
      if (biography != null) 'biography': biography,
      if (achievements != null) 'achievements': achievements,
      if (careerJourney != null) 'careerJourney': careerJourney,
      if (manifestoUrl != null) 'manifestoUrl': manifestoUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (slogan != null) 'slogan': slogan,
      if (payoutAddress != null) 'payoutAddress': payoutAddress,
    });
    return CandidateModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<CandidateModel> uploadManifesto(String candidateId, String filePath) async {
    final formData = FormData.fromMap({
      'manifesto': await MultipartFile.fromFile(filePath),
    });
    final res = await _api.upload(
      ApiEndpoints.updateCandidate(candidateId),
      formData: formData,
    );
    return CandidateModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
