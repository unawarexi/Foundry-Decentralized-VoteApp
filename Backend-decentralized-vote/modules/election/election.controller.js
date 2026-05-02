// ============================================================================
// VoteSecure — Election Controller
// ============================================================================

import * as electionService from "./election.service.js";
import { success, created, paginated } from "../../core/utils/api-response.js";
import { createLogger } from "../../logs/logger.js";

const log = createLogger("ElectionController");

export async function list(req, res, next) {
  try {
    const { page, limit, status, type, regionId, search } = req.query;
    const result = await electionService.listElections({ page, limit, status, type, regionId, search });
    paginated(res, result);
  } catch (err) { next(err); }
}

export async function getActive(req, res, next) {
  try {
    const { regionId } = req.query;
    const elections = await electionService.getActiveElections(regionId);
    success(res, elections);
  } catch (err) { next(err); }
}

export async function getById(req, res, next) {
  try {
    const election = await electionService.getElectionById(req.params.id);
    success(res, election);
  } catch (err) { next(err); }
}

export async function create(req, res, next) {
  try {
    const election = await electionService.createElection({
      adminId: req.user.id,
      ...req.body,
    });
    created(res, election, "Election created successfully");
  } catch (err) { next(err); }
}

export async function updatePhase(req, res, next) {
  try {
    const updated = await electionService.updateElectionPhase({
      electionId: req.params.id,
      adminId: req.user.id,
      ...req.body,
    });
    success(res, updated, "Election phase updated");
  } catch (err) { next(err); }
}

export async function getResults(req, res, next) {
  try {
    const results = await electionService.getElectionResults(req.params.id);
    success(res, results);
  } catch (err) { next(err); }
}

export async function getByRegion(req, res, next) {
  try {
    const result = await electionService.getElectionsByRegion(req.params.regionId, req.query);
    paginated(res, result);
  } catch (err) { next(err); }
}
