// ============================================================================
// VoteSecure — Region Controller
// ============================================================================

import * as regionService from "./region.service.js";
import { success, created } from "../../core/utils/api-response.js";

export async function list(req, res, next) {
  try { success(res, await regionService.listRegions(req.query.countryCode)); }
  catch (err) { next(err); }
}

export async function getById(req, res, next) {
  try { success(res, await regionService.getRegionById(req.params.id)); }
  catch (err) { next(err); }
}

export async function create(req, res, next) {
  try { created(res, await regionService.createRegion(req.body)); }
  catch (err) { next(err); }
}

export async function update(req, res, next) {
  try { success(res, await regionService.updateRegion({ regionId: req.params.id, ...req.body })); }
  catch (err) { next(err); }
}

export async function assignVoter(req, res, next) {
  try { success(res, await regionService.assignVoterToRegion({ regionId: req.params.id, ...req.body })); }
  catch (err) { next(err); }
}

export async function getElections(req, res, next) {
  try { success(res, await regionService.getElectionsByRegion(req.params.id)); }
  catch (err) { next(err); }
}
