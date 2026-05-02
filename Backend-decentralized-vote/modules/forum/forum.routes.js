import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import { createPost, listPosts, answerPost, voteOnPost } from "./forum.controller.js";
import { createPostSchema, answerPostSchema, voteOnPostSchema } from "./forum.validators.js";

const router = Router();

router.get("/election/:electionId", listPosts);
router.post("/", authenticate, validate(createPostSchema), createPost);
router.post("/:postId/answer", authenticate, validate(answerPostSchema), answerPost);
router.post("/:postId/vote", authenticate, validate(voteOnPostSchema), voteOnPost);

export default router;
