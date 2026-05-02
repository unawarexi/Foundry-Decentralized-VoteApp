// ============================================================================
// VoteSecure — Vote Controller
// ============================================================================

import * as voteService from "./vote.service.js";
import { success, created } from "../../core/utils/api-response.js";

export async function castVote(req, res, next) {
  try {
    const result = await voteService.castVote({ voterId: req.user.id, ...req.body });
    created(res, result, "Vote cast successfully");
  } catch (err) { next(err); }
}

export async function hasVoted(req, res, next) {
  try {
    const vote = await voteService.hasVoted(req.user.id, req.params.electionId);
    success(res, { voted: !!vote, vote: vote || null });
  } catch (err) { next(err); }
}

export async function getMyVotes(req, res, next) {
  try {
    const votes = await voteService.getMyVotes(req.user.id);
    success(res, votes);
  } catch (err) { next(err); }
}
