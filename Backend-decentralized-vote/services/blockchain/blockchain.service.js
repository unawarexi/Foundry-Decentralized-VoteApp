// ============================================================================
// VoteSecure — Blockchain Service
// ethers.js v6 integration with all UUPS proxy contracts
// ============================================================================

import { ethers } from "ethers";
import { env } from "../config/env.config.js";
import { createLogger } from "../logs/logger.js";
import { BlockchainConfig } from "../config/constants.js";

const log = createLogger("Blockchain");

// ============================================================================
// MINIMAL ABIs — only functions called by the backend signer
// ============================================================================

const IDENTITY_REGISTRY_ABI = [
  "function registerVoter(address voter, bytes32 identityHash, bytes32 regionId) external",
  "function banVoter(address voter, string reason) external",
  "function unbanVoter(address voter) external",
  "function isRegistered(address voter) external view returns (bool)",
  "function isBanned(address voter) external view returns (bool)",
  "function getVoterInfo(address voter) external view returns (bytes32 identityHash, bytes32 regionId, bool banned)",
  "event VoterRegistered(address indexed voter, bytes32 indexed regionId, bytes32 identityHash)",
  "event VoterBanned(address indexed voter, string reason)",
];

const ELECTION_FACTORY_ABI = [
  "function createElection(bytes32 electionId, bytes32 regionId, uint256 startTime, uint256 endTime, uint256 voteFee) external returns (address)",
  "function getElectionAddress(bytes32 electionId) external view returns (address)",
  "function getAllElections() external view returns (bytes32[] memory)",
  "event ElectionCreated(bytes32 indexed electionId, address electionContract)",
];

const VOTE_PROTOCOL_ABI = [
  "function castVote(bytes32 electionId, bytes32 candidateId, bytes32 nullifierHash, bytes calldata proof) external payable",
  "function getTallyFor(bytes32 electionId, bytes32 candidateId) external view returns (uint256)",
  "function getElectionStatus(bytes32 electionId) external view returns (uint8)",
  "function getNullifierUsed(bytes32 nullifier) external view returns (bool)",
  "function finalizeElection(bytes32 electionId) external returns (bytes32 resultHash)",
  "event VoteCast(bytes32 indexed electionId, bytes32 nullifierHash)",
  "event ElectionFinalized(bytes32 indexed electionId, bytes32 resultHash)",
];

const VOTE_FEE_ESCROW_ABI = [
  "function depositFee(bytes32 electionId, bytes32 nullifierHash) external payable",
  "function refundFee(bytes32 electionId, bytes32 nullifierHash, address payable voter) external",
  "function releaseFees(bytes32 electionId) external",
  "function getBalance(bytes32 electionId) external view returns (uint256)",
  "function hasPaid(bytes32 electionId, bytes32 nullifierHash) external view returns (bool)",
];

const CANDIDATE_REGISTRY_ABI = [
  "function registerCandidate(bytes32 electionId, bytes32 candidateId, address candidateAddress, bytes32 partyId) external",
  "function approveCandidate(bytes32 electionId, bytes32 candidateId) external",
  "function disqualifyCandidate(bytes32 electionId, bytes32 candidateId, string reason) external",
  "function getCandidateStatus(bytes32 electionId, bytes32 candidateId) external view returns (uint8)",
  "function isApproved(bytes32 electionId, bytes32 candidateId) external view returns (bool)",
];

const PARTY_REGISTRY_ABI = [
  "function registerParty(bytes32 partyId, string name, bytes32 manifestoHash, address partyAdmin) external",
  "function approveParty(bytes32 partyId) external",
  "function suspendParty(bytes32 partyId, string reason) external",
  "function isActive(bytes32 partyId) external view returns (bool)",
];

const FORUM_GOVERNANCE_ABI = [
  "function recordSLABreach(bytes32 electionId, bytes32 candidateId, uint256 questionId) external",
  "function recordAnswer(bytes32 electionId, bytes32 candidateId, uint256 questionId, bytes32 answerHash) external",
  "function getSLABreachCount(bytes32 candidateId) external view returns (uint256)",
];

const FRAUD_DETECTION_ABI = [
  "function submitFraudFlag(address voter, bytes32 evidenceHash, uint8 severity) external",
  "function resolveFraudFlag(uint256 flagId, bool confirmed) external",
  "function getRiskScore(address voter) external view returns (uint256)",
  "function isHighRisk(address voter) external view returns (bool)",
];

const REGION_REGISTRY_ABI = [
  "function registerRegion(bytes32 regionId, string name, bytes32 parentId) external",
  "function getRegion(bytes32 regionId) external view returns (string name, bytes32 parentId, bool active)",
  "function isVoterInRegion(address voter, bytes32 regionId) external view returns (bool)",
];

// ============================================================================
// PROVIDER + SIGNER SETUP
// ============================================================================

let provider = null;
let signer = null;
const contracts = {};

export async function initBlockchain() {
  try {
    if (!env.BLOCKCHAIN_RPC_URL) {
      log.warn("BLOCKCHAIN_RPC_URL not set — blockchain service disabled");
      return;
    }

    provider = new ethers.JsonRpcProvider(env.BLOCKCHAIN_RPC_URL);

    // Verify connectivity
    const network = await provider.getNetwork();
    log.info(`Blockchain connected: chain ${network.chainId} (${network.name})`);

    if (!env.BLOCKCHAIN_PRIVATE_KEY) {
      log.warn("BLOCKCHAIN_PRIVATE_KEY not set — read-only mode");
    } else {
      signer = new ethers.Wallet(env.BLOCKCHAIN_PRIVATE_KEY, provider);
      log.info(`Backend signer: ${signer.address}`);
    }

    // Initialize contract instances
    _initContracts();

    log.success("Blockchain service initialized");
  } catch (err) {
    log.error("Blockchain init failed", { error: err.message });
    // Non-fatal — app continues without blockchain in dev
  }
}

function _initContracts() {
  const signerOrProvider = signer || provider;

  const contractMap = {
    identityRegistry: [env.CONTRACT_IDENTITY_REGISTRY, IDENTITY_REGISTRY_ABI],
    electionFactory: [env.CONTRACT_ELECTION_FACTORY, ELECTION_FACTORY_ABI],
    voteProtocol: [env.CONTRACT_VOTE_PROTOCOL, VOTE_PROTOCOL_ABI],
    voteFeeEscrow: [env.CONTRACT_VOTE_FEE_ESCROW, VOTE_FEE_ESCROW_ABI],
    candidateRegistry: [env.CONTRACT_CANDIDATE_REGISTRY, CANDIDATE_REGISTRY_ABI],
    partyRegistry: [env.CONTRACT_PARTY_REGISTRY, PARTY_REGISTRY_ABI],
    forumGovernance: [env.CONTRACT_FORUM_GOVERNANCE, FORUM_GOVERNANCE_ABI],
    fraudDetection: [env.CONTRACT_FRAUD_DETECTION, FRAUD_DETECTION_ABI],
    regionRegistry: [env.CONTRACT_REGION_REGISTRY, REGION_REGISTRY_ABI],
  };

  for (const [name, [address, abi]] of Object.entries(contractMap)) {
    if (address) {
      contracts[name] = new ethers.Contract(address, abi, signerOrProvider);
    } else {
      log.warn(`Contract address not set: ${name}`);
    }
  }
}

// ============================================================================
// HELPERS
// ============================================================================

function requireContract(name) {
  if (!contracts[name]) {
    throw new Error(`Contract not initialized: ${name}. Check CONTRACT_${name.toUpperCase()} env var.`);
  }
  return contracts[name];
}

async function sendTxWithRetry(fn, retries = BlockchainConfig.RETRY_ATTEMPTS) {
  let lastErr;
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const tx = await fn();
      log.info(`TX sent: ${tx.hash} (attempt ${attempt})`);
      const receipt = await tx.wait(BlockchainConfig.CONFIRMATION_BLOCKS);
      return receipt;
    } catch (err) {
      lastErr = err;
      log.warn(`TX attempt ${attempt} failed: ${err.message}`);
      if (attempt < retries) {
        await new Promise((r) => setTimeout(r, BlockchainConfig.RETRY_DELAY_MS * attempt));
      }
    }
  }
  throw lastErr;
}

function toBytes32(str) {
  return ethers.encodeBytes32String(str.length > 31 ? str.slice(0, 31) : str);
}

function keccak256Str(value) {
  return ethers.keccak256(ethers.toUtf8Bytes(value));
}

// ============================================================================
// IDENTITY REGISTRY — Voter Registration
// ============================================================================

export async function registerVoterOnChain({ walletAddress, identityHash, regionId }) {
  const contract = requireContract("identityRegistry");
  const regionBytes32 = toBytes32(regionId);
  const identityBytes32 = ethers.zeroPadBytes(identityHash, 32);

  return sendTxWithRetry(() =>
    contract.registerVoter(walletAddress, identityBytes32, regionBytes32, {
      gasLimit: BlockchainConfig.GAS_LIMIT_REGISTER,
    })
  );
}

export async function banVoterOnChain({ walletAddress, reason }) {
  const contract = requireContract("identityRegistry");
  return sendTxWithRetry(() =>
    contract.banVoter(walletAddress, reason, {
      gasLimit: BlockchainConfig.GAS_LIMIT_REGISTER,
    })
  );
}

export async function isVoterRegistered(walletAddress) {
  const contract = requireContract("identityRegistry");
  return contract.isRegistered(walletAddress);
}

export async function isVoterBanned(walletAddress) {
  const contract = requireContract("identityRegistry");
  return contract.isBanned(walletAddress);
}

// ============================================================================
// ELECTION FACTORY
// ============================================================================

export async function createElectionOnChain({ electionId, regionId, startTime, endTime, voteFeeWei }) {
  const contract = requireContract("electionFactory");
  return sendTxWithRetry(() =>
    contract.createElection(
      toBytes32(electionId),
      toBytes32(regionId),
      BigInt(Math.floor(startTime / 1000)),
      BigInt(Math.floor(endTime / 1000)),
      BigInt(voteFeeWei),
      { gasLimit: BlockchainConfig.GAS_LIMIT_ELECTION }
    )
  );
}

// ============================================================================
// VOTE PROTOCOL
// ============================================================================

export async function castVoteOnChain({ electionId, candidateId, nullifierHash, proof, voteFeeWei }) {
  const contract = requireContract("voteProtocol");
  return sendTxWithRetry(() =>
    contract.castVote(
      toBytes32(electionId),
      toBytes32(candidateId),
      ethers.zeroPadBytes(nullifierHash, 32),
      proof || "0x",
      {
        value: BigInt(voteFeeWei),
        gasLimit: BlockchainConfig.GAS_LIMIT_VOTE,
      }
    )
  );
}

export async function getVoteTally(electionId, candidateId) {
  const contract = requireContract("voteProtocol");
  const tally = await contract.getTallyFor(toBytes32(electionId), toBytes32(candidateId));
  return Number(tally);
}

export async function isNullifierUsed(nullifierHash) {
  const contract = requireContract("voteProtocol");
  return contract.getNullifierUsed(ethers.zeroPadBytes(nullifierHash, 32));
}

export async function getElectionStatusOnChain(electionId) {
  const contract = requireContract("voteProtocol");
  const status = await contract.getElectionStatus(toBytes32(electionId));
  return Number(status);
}

export async function finalizeElectionOnChain(electionId) {
  const contract = requireContract("voteProtocol");
  return sendTxWithRetry(() =>
    contract.finalizeElection(toBytes32(electionId), {
      gasLimit: BlockchainConfig.GAS_LIMIT_ELECTION,
    })
  );
}

// ============================================================================
// CANDIDATE REGISTRY
// ============================================================================

export async function registerCandidateOnChain({ electionId, candidateId, walletAddress, partyId }) {
  const contract = requireContract("candidateRegistry");
  return sendTxWithRetry(() =>
    contract.registerCandidate(
      toBytes32(electionId),
      toBytes32(candidateId),
      walletAddress,
      partyId ? toBytes32(partyId) : ethers.ZeroHash,
      { gasLimit: BlockchainConfig.GAS_LIMIT_REGISTER }
    )
  );
}

export async function approveCandidateOnChain({ electionId, candidateId }) {
  const contract = requireContract("candidateRegistry");
  return sendTxWithRetry(() =>
    contract.approveCandidate(toBytes32(electionId), toBytes32(candidateId), {
      gasLimit: BlockchainConfig.GAS_LIMIT_REGISTER,
    })
  );
}

export async function disqualifyCandidateOnChain({ electionId, candidateId, reason }) {
  const contract = requireContract("candidateRegistry");
  return sendTxWithRetry(() =>
    contract.disqualifyCandidate(toBytes32(electionId), toBytes32(candidateId), reason, {
      gasLimit: BlockchainConfig.GAS_LIMIT_REGISTER,
    })
  );
}

// ============================================================================
// PARTY REGISTRY
// ============================================================================

export async function registerPartyOnChain({ partyId, name, manifestoHash, adminAddress }) {
  const contract = requireContract("partyRegistry");
  const manifestoBytes32 = manifestoHash ? ethers.zeroPadBytes(manifestoHash, 32) : ethers.ZeroHash;
  return sendTxWithRetry(() =>
    contract.registerParty(toBytes32(partyId), name, manifestoBytes32, adminAddress, {
      gasLimit: BlockchainConfig.GAS_LIMIT_REGISTER,
    })
  );
}

// ============================================================================
// FRAUD DETECTION
// ============================================================================

export async function submitFraudFlagOnChain({ walletAddress, evidenceHash, severity }) {
  const contract = requireContract("fraudDetection");
  const severityMap = { LOW: 1, MEDIUM: 2, HIGH: 3, CRITICAL: 4 };
  return sendTxWithRetry(() =>
    contract.submitFraudFlag(
      walletAddress,
      ethers.zeroPadBytes(evidenceHash, 32),
      severityMap[severity] || 1,
      { gasLimit: BlockchainConfig.GAS_LIMIT_REGISTER }
    )
  );
}

export async function getVoterRiskScore(walletAddress) {
  const contract = requireContract("fraudDetection");
  const score = await contract.getRiskScore(walletAddress);
  return Number(score);
}

// ============================================================================
// FORUM GOVERNANCE
// ============================================================================

export async function recordSLABreachOnChain({ electionId, candidateId, questionId }) {
  const contract = requireContract("forumGovernance");
  return sendTxWithRetry(() =>
    contract.recordSLABreach(toBytes32(electionId), toBytes32(candidateId), BigInt(questionId), {
      gasLimit: BlockchainConfig.GAS_LIMIT_VOTE,
    })
  );
}

// ============================================================================
// UTILITY EXPORTS
// ============================================================================

export { toBytes32, keccak256Str };

export function getProvider() {
  return provider;
}

export function getSigner() {
  return signer;
}

export function isBlockchainReady() {
  return !!provider;
}
