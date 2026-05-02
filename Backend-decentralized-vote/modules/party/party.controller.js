// ============================================================================
// VoteSecure — Party Controller & Routes
// ============================================================================

import * as partyService from "./party.service.js";
import { success, created } from "../../core/utils/api-response.js";

export async function create(req, res, next) {
  try {
    const party = await partyService.createParty({ createdBy: req.user.id, ...req.body });
    created(res, party);
  } catch (err) { next(err); }
}

export async function list(req, res, next) {
  try {
    const parties = await partyService.listParties(req.query.status);
    success(res, parties);
  } catch (err) { next(err); }
}

export async function getById(req, res, next) {
  try {
    const party = await partyService.getPartyById(req.params.id);
    success(res, party);
  } catch (err) { next(err); }
}

export async function update(req, res, next) {
  try {
    const party = await partyService.updateParty({ partyId: req.params.id, adminId: req.user.id, ...req.body });
    success(res, party);
  } catch (err) { next(err); }
}

export async function approve(req, res, next) {
  try {
    const party = await partyService.approveParty({ adminId: req.user.id, partyId: req.params.id });
    success(res, party, "Party approved");
  } catch (err) { next(err); }
}
