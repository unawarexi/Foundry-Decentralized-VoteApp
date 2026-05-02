import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/app/domain/models/forum_model.dart';

class ForumRepository {
  final _api = ApiClient.instance;

  Future<List<ForumPostModel>> getPosts({String? electionId, int page = 1}) async {
    final res = await _api.get(ApiEndpoints.forumPosts, queryParameters: {
      if (electionId != null) 'electionId': electionId,
      'page': page,
    });
    final list = res.data['data'] as List;
    return list.map((e) => ForumPostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ForumPostModel> getPost(String id) async {
    final res = await _api.get(ApiEndpoints.forumPost(id));
    return ForumPostModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<ForumPostModel> createPost({
    required String title,
    required String body,
    String? electionId,
    List<String>? tags,
  }) async {
    final res = await _api.post(ApiEndpoints.forumPosts, data: {
      'title': title,
      'body': body,
      if (electionId != null) 'electionId': electionId,
      if (tags != null) 'tags': tags,
    });
    return ForumPostModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<ForumAnswerModel> answerPost({
    required String postId,
    required String body,
  }) async {
    final res = await _api.post(ApiEndpoints.answerPost(postId), data: {'body': body});
    return ForumAnswerModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> votePost(String postId, {required String direction}) async {
    await _api.post(ApiEndpoints.votePost(postId), data: {'direction': direction});
  }
}
