import * as analyticsService from "./analytics.service.js";
import { success } from "../../core/utils/api-response.js";

export async function electionAnalytics(req, res, next) {
  try { success(res, await analyticsService.getElectionAnalytics(req.params.electionId)); }
  catch (err) { next(err); }
}

export async function platformStats(req, res, next) {
  try { success(res, await analyticsService.getPlatformStats()); }
  catch (err) { next(err); }
}

export async function turnoutByRegion(req, res, next) {
  try { success(res, await analyticsService.getVoterTurnoutByRegion(req.params.electionId)); }
  catch (err) { next(err); }
}
