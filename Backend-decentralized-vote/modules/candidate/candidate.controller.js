// ============================================================================
// VoteSecure — Candidate Controller
// ============================================================================

import * as candidateService from "./candidate.service.js";
import { success, created } from "../../core/utils/api-response.js";

export async function register(req, res, next) {
  try {
    const candidate = await candidateService.registerCandidate({ userId: req.user.id, ...req.body });
    created(res, candidate, "Candidate registered");
  } catch (err) { next(err); }
}

export async function listByElection(req, res, next) {
  try {
    const { status } = req.query;
    const candidates = await candidateService.getCandidatesByElection(req.params.electionId, status);
    success(res, candidates);
  } catch (err) { next(err); }
}

export async function getById(req, res, next) {
  try {
    const candidate = await candidateService.getCandidateById(req.params.id);
    success(res, candidate);
  } catch (err) { next(err); }
}

export async function updateProfile(req, res, next) {
  try {
    const updated = await candidateService.updateCandidateProfile({
      candidateId: req.params.id,
      userId: req.user.id,
      ...req.body,
    });
    success(res, updated, "Profile updated");
  } catch (err) { next(err); }
}

export async function handleApproval(req, res, next) {
  try {
    const updated = await candidateService.approveCandidate({
      adminId: req.user.id,
      candidateId: req.params.id,
      ...req.body,
    });
    success(res, updated, `Candidate ${req.body.action}d`);
  } catch (err) { next(err); }
}
