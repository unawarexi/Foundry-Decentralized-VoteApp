import * as fraudService from "./fraud.service.js";
import { success, created, paginated } from "../../core/utils/api-response.js";

export async function report(req, res, next) {
  try {
    const r = await fraudService.reportFraud({ reporterId: req.user.id, ...req.body });
    created(res, r, "Fraud report submitted");
  } catch (err) { next(err); }
}

export async function list(req, res, next) {
  try {
    const result = await fraudService.listReports(req.query);
    paginated(res, result);
  } catch (err) { next(err); }
}

export async function resolve(req, res, next) {
  try {
    const r = await fraudService.resolveReport({ adminId: req.user.id, reportId: req.params.id, ...req.body });
    success(res, r, "Report resolved");
  } catch (err) { next(err); }
}

export async function getRiskScore(req, res, next) {
  try {
    const score = await fraudService.getUserRiskScore(req.params.userId);
    success(res, score);
  } catch (err) { next(err); }
}
