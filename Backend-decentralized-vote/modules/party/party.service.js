// ============================================================================
// VoteSecure — Party Service
// ============================================================================

import { ethers } from "ethers";
import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import { registerPartyOnChain } from "../../services/blockchain/blockchain.service.js";

const log = createLogger("PartyService");

export async function createParty({ createdBy, name, ideology, manifestoUrl, foundedYear, logoUrl }) {
  const slug = name.toLowerCase().replace(/\s+/g, "-").replace(/[^a-z0-9-]/g, "");

  const existing = await prisma.party.findUnique({ where: { slug } });
  if (existing) throw new AppError("A party with this name already exists", HttpStatus.CONFLICT, ErrorCodes.USER_ALREADY_EXISTS);

  // Compute manifesto hash if URL provided
  let manifestoHash = null;
  if (manifestoUrl) {
    manifestoHash = ethers.keccak256(ethers.toUtf8Bytes(manifestoUrl));
  }

  const party = await prisma.party.create({
    data: { name, slug, ideology, manifestoUrl, manifestoHash, foundedYear, logoUrl, createdBy, status: "PENDING" },
  });

  log.info(`Party created: ${party.id}`);
  return party;
}

export async function listParties(status) {
  const where = status ? { status } : { status: "ACTIVE" };
  return prisma.party.findMany({ where, orderBy: { name: "asc" } });
}

export async function getPartyById(partyId) {
  const party = await prisma.party.findUnique({
    where: { id: partyId },
    include: { _count: { select: { candidates: true } } },
  });
  if (!party) throw new AppError("Party not found", HttpStatus.NOT_FOUND, ErrorCodes.PARTY_NOT_FOUND);
  return party;
}

export async function approveParty({ adminId, partyId }) {
  const party = await prisma.party.findUnique({ where: { id: partyId } });
  if (!party) throw new AppError("Party not found", HttpStatus.NOT_FOUND, ErrorCodes.PARTY_NOT_FOUND);

  const updated = await prisma.party.update({
    where: { id: partyId },
    data: { status: "ACTIVE", approvedBy: adminId, approvedAt: new Date() },
  });

  // Register on-chain
  registerPartyOnChain({
    partyId,
    name: party.name,
    manifestoHash: party.manifestoHash || ethers.ZeroHash,
    adminAddress: "0x0000000000000000000000000000000000000000",
  }).catch((err) => log.warn("On-chain party registration failed", { error: err.message }));

  return updated;
}

export async function updateParty({ partyId, adminId, ...updates }) {
  const party = await prisma.party.findUnique({ where: { id: partyId } });
  if (!party) throw new AppError("Party not found", HttpStatus.NOT_FOUND, ErrorCodes.PARTY_NOT_FOUND);
  if (party.createdBy !== adminId) throw new AppError("Not authorized", HttpStatus.FORBIDDEN, ErrorCodes.FORBIDDEN);

  return prisma.party.update({ where: { id: partyId }, data: updates });
}
