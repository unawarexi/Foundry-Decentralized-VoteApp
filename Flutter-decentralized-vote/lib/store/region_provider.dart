import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/region_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/region_repository.dart';

final regionRepositoryProvider =
    Provider<RegionRepository>((ref) => RegionRepository());

/// All available regions (cached for 60 min).
final regionsProvider = FutureProvider<List<RegionModel>>((ref) async {
  return ref.read(regionRepositoryProvider).getRegions();
});

/// Single region by ID.
final regionByIdProvider =
    FutureProvider.family<RegionModel, String>((ref, id) async {
  return ref.read(regionRepositoryProvider).getRegionById(id);
});

/// User-selected region during onboarding / registration.
final selectedRegionProvider = StateProvider<RegionModel?>((ref) => null);
