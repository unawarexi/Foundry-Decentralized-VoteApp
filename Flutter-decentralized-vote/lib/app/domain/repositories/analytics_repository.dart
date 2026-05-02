import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';

class AnalyticsRepository {
  final _api = ApiClient.instance;

  Future<Map<String, dynamic>> getPlatformStats() async {
    final res = await _api.get(ApiEndpoints.platformStats);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getElectionAnalytics(String electionId) async {
    final res = await _api.get(ApiEndpoints.electionAnalytics(electionId));
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTurnoutByRegion(String electionId) async {
    final res = await _api.get(ApiEndpoints.turnoutByRegion(electionId));
    return res.data['data'] as Map<String, dynamic>;
  }
}
