import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/core/db/hive.dart';
import 'package:flutter_frontend_vote/app/domain/models/election_model.dart';

class ElectionRepository {
  final _api = ApiClient.instance;

  Future<List<ElectionModel>> getActiveElections() async {
    final cached = HiveService.getIfFresh(HiveService.electionCache, 'active_elections');
    if (cached != null) {
      final list = cached as List;
      return list.map((e) => ElectionModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    final res = await _api.get(ApiEndpoints.activeElections);
    final list = res.data['data'] as List;
    await HiveService.putWithTTL(HiveService.electionCache, 'active_elections', list, ttlMinutes: 10);
    return list.map((e) => ElectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ElectionModel>> getElections({String? status}) async {
    final res = await _api.get(ApiEndpoints.elections,
        queryParameters: {if (status != null) 'status': status});
    final list = res.data['data'] as List;
    return list.map((e) => ElectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ElectionModel> getElectionById(String id) async {
    final cached = HiveService.getIfFresh(HiveService.electionCache, 'election_$id');
    if (cached != null) {
      return ElectionModel.fromJson(Map<String, dynamic>.from(cached as Map));
    }
    final res = await _api.get(ApiEndpoints.electionById(id));
    final data = res.data['data'] as Map<String, dynamic>;
    await HiveService.putWithTTL(HiveService.electionCache, 'election_$id', data, ttlMinutes: 5);
    return ElectionModel.fromJson(data);
  }

  Future<List<ElectionModel>> getElectionsByRegion(String regionId) async {
    final res = await _api.get(ApiEndpoints.electionsByRegion(regionId));
    final list = res.data['data'] as List;
    return list.map((e) => ElectionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getElectionResults(String id) async {
    final res = await _api.get(ApiEndpoints.electionResults(id));
    return res.data['data'] as Map<String, dynamic>;
  }
}
