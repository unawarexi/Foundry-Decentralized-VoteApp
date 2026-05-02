import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/forum_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/forum_repository.dart';

final forumRepositoryProvider =
    Provider<ForumRepository>((ref) => ForumRepository());

/// Forum posts for all elections or filtered by [electionId].
final forumPostsProvider =
    FutureProvider.family<List<ForumPostModel>, String?>
        ((ref, electionId) async {
  return ref.read(forumRepositoryProvider).getPosts(electionId: electionId);
});

/// Single post with full answers.
final forumPostProvider =
    FutureProvider.family<ForumPostModel, String>((ref, id) async {
  return ref.read(forumRepositoryProvider).getPost(id);
});

// ── Create post ──────────────────────────────────────────────────────────

enum ForumActionStatus { idle, loading, success, error }

final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, ForumActionStatus>(
        (ref) => CreatePostNotifier(ref));

class CreatePostNotifier extends StateNotifier<ForumActionStatus> {
  final Ref _ref;
  CreatePostNotifier(this._ref) : super(ForumActionStatus.idle);

  Future<ForumPostModel?> create({
    required String title,
    required String body,
    String? electionId,
    List<String>? tags,
  }) async {
    state = ForumActionStatus.loading;
    try {
      final post = await _ref.read(forumRepositoryProvider).createPost(
            title: title,
            body: body,
            electionId: electionId,
            tags: tags,
          );
      state = ForumActionStatus.success;
      _ref.invalidate(forumPostsProvider(electionId));
      return post;
    } catch (_) {
      state = ForumActionStatus.error;
      return null;
    }
  }

  void reset() => state = ForumActionStatus.idle;
}
