// ============================================================================
// VoteSecure — Forum Service
// Q&A between voters and candidates, with SLA enforcement
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes, ForumConfig, ElectionConfig } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import { recordSLABreachOnChain } from "../../services/blockchain/blockchain.service.js";

const log = createLogger("ForumService");

export async function createPost({ authorId, electionId, candidateId, content }) {
  const election = await prisma.election.findUnique({ where: { id: electionId } });
  if (!election) throw new AppError("Election not found", HttpStatus.NOT_FOUND, ErrorCodes.ELECTION_NOT_FOUND);
  if (!["ACTIVE", "PENDING"].includes(election.status)) {
    throw new AppError("Forum is only open for active elections", HttpStatus.UNPROCESSABLE_ENTITY, ErrorCodes.ELECTION_NOT_ACTIVE);
  }

  if (content.length > ForumConfig.MAX_QUESTION_LENGTH) {
    throw new AppError(`Question too long (max ${ForumConfig.MAX_QUESTION_LENGTH} chars)`, HttpStatus.BAD_REQUEST, ErrorCodes.VALIDATION_ERROR);
  }

  const slaDeadline = new Date(Date.now() + ElectionConfig.SLA_HOURS * 60 * 60 * 1000);
  const contentHash = `0x${Buffer.from(content).toString("hex").padStart(64, "0").slice(0, 64)}`;

  const post = await prisma.forumPost.create({
    data: {
      electionId,
      candidateId,
      authorId,
      content,
      contentHash,
      slaDeadline,
    },
    include: { author: { select: { id: true, displayName: true, avatarUrl: true } } },
  });

  log.info(`Forum post created: ${post.id}`);
  return post;
}

export async function listPosts({ electionId, candidateId, status, page = 1, limit = 20 }) {
  const skip = (page - 1) * limit;
  const where = { electionId };
  if (candidateId) where.candidateId = candidateId;
  if (status) where.status = status;

  const [data, total] = await Promise.all([
    prisma.forumPost.findMany({
      where,
      skip,
      take: limit,
      orderBy: [{ status: "asc" }, { upvotes: "desc" }, { createdAt: "desc" }],
      include: {
        author: { select: { id: true, displayName: true, avatarUrl: true } },
        answers: {
          include: { candidate: { include: { user: { select: { displayName: true, avatarUrl: true } } } } },
        },
        _count: { select: { answers: true, votes: true } },
      },
    }),
    prisma.forumPost.count({ where }),
  ]);

  return { data, total, page, limit };
}

export async function answerPost({ postId, candidateId, candidateUserId, content }) {
  const post = await prisma.forumPost.findUnique({ where: { id: postId } });
  if (!post) throw new AppError("Forum post not found", HttpStatus.NOT_FOUND, ErrorCodes.FORUM_POST_NOT_FOUND);

  if (post.status === "CLOSED" || post.status === "REMOVED") {
    throw new AppError("This post is closed", HttpStatus.UNPROCESSABLE_ENTITY, ErrorCodes.FORUM_POST_EXPIRED);
  }

  // Validate candidate owns this slot
  const candidate = await prisma.candidate.findUnique({ where: { id: candidateId } });
  if (!candidate || candidate.userId !== candidateUserId) {
    throw new AppError("Not authorized to answer as this candidate", HttpStatus.FORBIDDEN, ErrorCodes.FORBIDDEN);
  }

  // Check not already answered
  const existing = await prisma.forumAnswer.findUnique({ where: { postId_candidateId: { postId, candidateId } } });
  if (existing) {
    // Update existing answer
    return prisma.forumAnswer.update({
      where: { postId_candidateId: { postId, candidateId } },
      data: { content },
    });
  }

  const answer = await prisma.forumAnswer.create({
    data: { postId, candidateId, content },
  });

  // Mark post as answered
  await prisma.forumPost.update({
    where: { id: postId },
    data: { status: "ANSWERED" },
  });

  return answer;
}

export async function voteOnPost({ postId, userId, value }) {
  if (value !== 1 && value !== -1) {
    throw new AppError("Vote value must be 1 or -1", HttpStatus.BAD_REQUEST, ErrorCodes.VALIDATION_ERROR);
  }

  // Upsert vote (one vote per user per post)
  await prisma.forumVote.upsert({
    where: { postId_userId: { postId, userId } },
    update: { value },
    create: { postId, userId, value },
  });

  // Recalculate counts
  const [upvotes, downvotes] = await Promise.all([
    prisma.forumVote.count({ where: { postId, value: 1 } }),
    prisma.forumVote.count({ where: { postId, value: -1 } }),
  ]);

  return prisma.forumPost.update({
    where: { id: postId },
    data: { upvotes, downvotes },
  });
}

// Called by a scheduler/worker job
export async function checkSLABreaches() {
  const now = new Date();
  const overduePosts = await prisma.forumPost.findMany({
    where: {
      status: "OPEN",
      slaDeadline: { lte: now },
      slaBreach: false,
    },
    include: { election: true },
  });

  for (const post of overduePosts) {
    await prisma.forumPost.update({
      where: { id: post.id },
      data: { slaBreach: true, status: "EXPIRED_UNANSWERED" },
    });

    // If assigned to a specific candidate, record breach
    if (post.candidateId) {
      await prisma.candidate.update({
        where: { id: post.candidateId },
        data: { slaBreaches: { increment: 1 } },
      });

      // Record on-chain
      recordSLABreachOnChain({
        electionId: post.election.onChainId || post.electionId,
        candidateId: post.candidateId,
        questionId: parseInt(post.id.replace(/-/g, "").slice(0, 8), 16) || 0,
      }).catch((err) => log.warn("On-chain SLA breach record failed", { error: err.message }));
    }

    log.info(`SLA breach recorded: post ${post.id}`);
  }

  return overduePosts.length;
}
