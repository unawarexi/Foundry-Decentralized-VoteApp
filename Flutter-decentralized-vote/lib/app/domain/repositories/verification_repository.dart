import 'package:dio/dio.dart';
import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/app/domain/models/verification_model.dart';

class VerificationRepository {
  final _api = ApiClient.instance;

  Future<VerificationModel> verifyFace(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    final res = await _api.upload(ApiEndpoints.aiFaceVerify, formData: formData);
    return VerificationModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<VerificationModel> livenessCheck(String videoPath) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(videoPath),
    });
    final res = await _api.upload(ApiEndpoints.aiLivenessCheck, formData: formData);
    return VerificationModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<VerificationModel> scanId(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    final res = await _api.upload(ApiEndpoints.aiIdScan, formData: formData);
    return VerificationModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<VerificationModel> verifyAge(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    final res = await _api.upload(ApiEndpoints.aiAgeVerify, formData: formData);
    return VerificationModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
