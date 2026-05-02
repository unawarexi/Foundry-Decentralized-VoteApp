import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/core/db/hive.dart';
import 'package:flutter_frontend_vote/app/domain/models/region_model.dart';

class RegionRepository {
  final _api = ApiClient.instance;

  Future<List<RegionModel>> getRegions() async {
    final cached = HiveService.getIfFresh(HiveService.settings, 'all_regions');
    if (cached != null) {
      final list = cached as List;
      return list.map((e) => RegionModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    final res = await _api.get(ApiEndpoints.regions);
    final list = res.data['data'] as List;
    await HiveService.putWithTTL(HiveService.settings, 'all_regions', list, ttlMinutes: 60);
    return list.map((e) => RegionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RegionModel> getRegionById(String id) async {
    final res = await _api.get(ApiEndpoints.regionById(id));
    return RegionModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> assignVoterToRegion(String regionId) async {
    await _api.post(ApiEndpoints.assignVoterRegion(regionId));
  }
}
