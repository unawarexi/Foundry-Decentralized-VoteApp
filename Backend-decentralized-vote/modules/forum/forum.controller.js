// ============================================================================
// VoteSecure — Forum Controller & Routes
// ============================================================================

import * as forumService from "./forum.service.js";
import { success, created, paginated } from "../../core/utils/api-response.js";
import { z } from "zod";

export async function createPost(req, res, next) {
  try {
    const post = await forumService.createPost({ authorId: req.user.id, ...req.body });
    created(res, post);
  } catch (err) { next(err); }
}

export async function listPosts(req, res, next) {
  try {
    const result = await forumService.listPosts({ ...req.query, electionId: req.params.electionId });
    paginated(res, result);
  } catch (err) { next(err); }
}

export async function answerPost(req, res, next) {
  try {
    const answer = await forumService.answerPost({
      postId: req.params.postId,
      candidateId: req.body.candidateId,
      candidateUserId: req.user.id,
      content: req.body.content,
    });
    success(res, answer, "Answer submitted");
  } catch (err) { next(err); }
}

export async function voteOnPost(req, res, next) {
  try {
    const post = await forumService.voteOnPost({ postId: req.params.postId, userId: req.user.id, value: req.body.value });
    success(res, { upvotes: post.upvotes, downvotes: post.downvotes });
  } catch (err) { next(err); }
}
