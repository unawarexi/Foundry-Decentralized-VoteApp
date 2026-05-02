import * as userService from "./user.service.js";
import { success, paginated } from "../../core/utils/api-response.js";
import { HttpStatus } from "../../config/constants.js";

export async function me(req, res, next) {
  try { success(res, await userService.getProfile(req.user.id)); }
  catch (err) { next(err); }
}

export async function updateMe(req, res, next) {
  try { success(res, await userService.updateProfile({ userId: req.user.id, ...req.body })); }
  catch (err) { next(err); }
}

export async function devices(req, res, next) {
  try { success(res, await userService.getDevices(req.user.id)); }
  catch (err) { next(err); }
}

export async function removeDevice(req, res, next) {
  try {
    await userService.removeDevice({ userId: req.user.id, deviceId: req.params.deviceId });
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) { next(err); }
}

export async function votingHistory(req, res, next) {
  try { paginated(res, await userService.getVotingHistory({ userId: req.user.id, ...req.query })); }
  catch (err) { next(err); }
}

export async function getUser(req, res, next) {
  try { success(res, await userService.getUserById(req.params.userId)); }
  catch (err) { next(err); }
}
