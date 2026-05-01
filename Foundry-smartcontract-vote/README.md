# VoteSecure Smart Contracts — Project Reference

> **Protocol**: VoteSecure — Decentralized civic voting infrastructure  
> **Language**: Solidity ^0.8.24  
> **Toolchain**: Foundry (Forge · Cast · Anvil · Chisel)  
> **Standards**: UUPS Upgradeable · EIP-712 · ERC-2771 (meta-tx ready)  
> **Access Control**: OpenZeppelin AccessControl v5  
> **Security**: ReentrancyGuard · Pausable · pull-payment pattern  
> **ZK**: Groth16 stub verifier (drop-in for circom/snarkjs)  
> **Targets**: Ethereum Mainnet · Sepolia · Polygon · zkSync Era  

---

## Table of Contents

1. [Directory Structure](#1-directory-structure)
2. [Architecture Overview](#2-architecture-overview)
3. [Shared Type Library](#3-shared-type-library)
4. [Core Contracts](#4-core-contracts)
5. [Interfaces](#5-interfaces)
6. [Deployment Scripts](#6-deployment-scripts)
7. [Tests](#7-tests)
8. [Access Control Roles](#8-access-control-roles)
9. [EIP-712 Signed Operations](#9-eip-712-signed-operations)
10. [Key Constants](#10-key-constants)
11. [Dependencies](#11-dependencies)
12. [Makefile Commands](#12-makefile-commands)
13. [Environment Variables](#13-environment-variables)
14. [Build Status](#14-build-status)

---

## 1. Directory Structure

```
Foundry-smartcontract-vote/
├── foundry.toml              # Foundry config — remappings, optimizer, fuzz, gas reports
├── Makefile                  # build / test / lint / deploy / upgrade shortcuts
├── .gitignore                # excludes cache/, out/, lib/, .env*, broadcast dry-runs
├── .env.example              # template: RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY
├── foundry.lock              # dependency lockfile for reproducible installs
│
├── src/
│   ├── types/
│   │   ├── DataTypes.sol     # All enums and structs used across the protocol
│   │   ├── Errors.sol        # 54 namespaced custom errors (zero-cost reverts)
│   │   ├── Events.sol        # Protocol-wide event declarations (free-floating)
│   │   └── Constants.sol     # Role hashes, time bounds, fee limits, forum SLA
│   │
│   ├── identity/
│   │   ├── IdentityRegistry.sol   # UUPS — voter KYC registration, ban, tier upgrade
│   │   ├── RegionRegistry.sol     # UUPS — region CRUD, voter→region mapping
│   │   └── ZKVerifier.sol         # UUPS — Groth16 stub verifier (circom drop-in)
│   │
│   ├── core/
│   │   ├── ElectionFactory.sol    # UUPS — election lifecycle & phase state machine
│   │   ├── VoteProtocol.sol       # UUPS — 8-step validated vote engine + revote
│   │   └── ElectionManager.sol    # Adapter — delegates to ElectionFactory
│   │
│   ├── payments/
│   │   └── VoteFeeEscrow.sol      # UUPS — fee deposit, release, pull-pattern refund
│   │
│   ├── utils/
│   │   ├── Errors.sol             # Utility-layer error aliases
│   │   ├── Events.sol             # Utility-layer event aliases
│   │   └── MathUtils.sol          # Safe percentage and BPS math helpers
│   │
│   ├── CandidateRegistry.sol      # UUPS — nomination, approval, popularity scoring
│   ├── PoliticalPartyRegistry.sol # UUPS — party registration, manifesto hash
│   ├── ForumGovernance.sol        # UUPS — Q&A forum, 24 hr SLA, moderator scoring
│   ├── FraudDetection.sol         # UUPS — flag submission, auto-ban on HIGH/CRITICAL
│   ├── DonationDistributor.sol    # UUPS — weight-based ETH donation splits
│   │
│   └── (legacy aliases)
│       ├── VoterRegistry.sol      # Thin proxy → IdentityRegistry
│       ├── ElectionManager.sol    # Thin proxy → ElectionFactory
│       ├── Vote.sol               # Thin proxy → VoteProtocol
│       └── Moderator.sol          # Thin proxy → ForumGovernance
│
├── interfaces/
│   ├── IIdentityRegistry.sol
│   ├── IRegionRegistry.sol
│   ├── ICandidateRegistry.sol
│   ├── IPoliticalPartyRegistry.sol
│   ├── IElectionFactory.sol
│   ├── IVoteFeeEscrow.sol
│   ├── IVoteProtocol.sol          # Contains CastVoteParams struct
│   ├── IForumGovernance.sol
│   ├── IFraudDetection.sol
│   ├── IDonationDistributor.sol
│   ├── IElectionManager.sol       # Legacy alias interface
│   ├── IModerator.sol             # Legacy alias interface
│   └── IVoterRegistry.sol         # Legacy alias interface
│
├── script/
│   ├── DeploySystem.s.sol         # Full 10-contract UUPS proxy deploy + role wiring
│   ├── UpgradeContracts.s.sol     # Conditional upgrade via NEW_IMPL_* env vars
│   ├── DeployElection.s.sol       # One-off single-election deploy
│   ├── RegisterParties.s.sol      # Batch party registration from JSON
│   └── SetupSystem.s.sol          # Post-deploy role assignment helper
│
└── test/
    ├── VoteSecureTestBase.t.sol   # Shared setUp, EIP-712 helpers, _createActiveElection()
    ├── unit/
    │   ├── IdentityRegistry.t.sol # 10 unit tests
    │   └── VoteProtocol.t.sol     # 10 unit tests (all 8 validation gates)
    ├── integration/
    │   └── FullElection.t.sol     # End-to-end lifecycle + revote + cancel/refund
    └── (stubs — next sprint)
        ├── ElectionManager.t.sol
        ├── FraudDetection.t.sol
        ├── Moderator.t.sol
        ├── PoliticalPartyRegistry.t.sol
        ├── VoterRegistry.t.sol
        └── DonationDistributor.t.sol
```

---

## 2. Architecture Overview

All production contracts are deployed as **UUPS proxies** via `DeploySystem.s.sol`. The deployment order follows the dependency graph:

```
ZKVerifier
    └── IdentityRegistry  ←── RegionRegistry
            └── CandidateRegistry  ←── PoliticalPartyRegistry
                    └── ElectionFactory
                            └── VoteFeeEscrow
                                    └── VoteProtocol  ←── ForumGovernance
                                                              └── FraudDetection
```

**Cross-contract calls (runtime):**

| Caller | Calls | Purpose |
|---|---|---|
| `VoteProtocol` | `IdentityRegistry` | Check voter registered + not banned |
| `VoteProtocol` | `RegionRegistry` | Validate voter region matches election |
| `VoteProtocol` | `CandidateRegistry` | Confirm candidate approved |
| `VoteProtocol` | `ZKVerifier` | Optional ZK proof check |
| `VoteProtocol` | `VoteFeeEscrow` | Confirm fee deposit; trigger release |
| `FraudDetection` | `IdentityRegistry` | Auto-ban on HIGH/CRITICAL flag |
| `ForumGovernance` | `CandidateRegistry` | Write back forum score to popularity |

---

## 3. Shared Type Library

**`src/types/DataTypes.sol`** — all enums and structs, imported by every module.

### Enums

| Enum | Values |
|---|---|
| `VerificationLevel` | `NONE`, `EMAIL`, `PHONE`, `BIOMETRIC`, `ZK_PROOF` |
| `ElectionStatus` | `PENDING`, `ACTIVE`, `PAUSED`, `TALLYING`, `FINALIZED`, `CANCELLED` |
| `ElectionType` | `SCHOOL`, `UNIVERSITY`, `COMPANY`, `LOCAL_GOVERNMENT`, `MAYORAL`, `GUBERNATORIAL`, `NATIONAL`, `UNION`, `COOPERATIVE`, `CUSTOM` |
| `PaymentToken` | `USDT`, `USDC`, `ETH` |
| `CandidateStatus` | `PENDING`, `ACTIVE`, `DISQUALIFIED`, `WITHDRAWN` |
| `QuestionStatus` | `OPEN`, `ANSWERED`, `UNANSWERED_EXPIRED`, `CLOSED` |
| `FraudSeverity` | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |

### Key Structs

| Struct | Fields |
|---|---|
| `Voter` | `identityHash`, `region`, `verificationLevel`, `nonce`, `bannedAt` |
| `Election` | `id`, `type`, `regionId`, `startTime`, `endTime`, `status`, `feeToken`, `feeCents` |
| `Candidate` | `id`, `electionId`, `partyId`, `walletAddress`, `status`, `popularityScore` |
| `Party` | `id`, `nameHash`, `manifestoHash`, `logoURI`, `approved` |
| `ForumPost` | `id`, `electionId`, `candidateId`, `contentHash`, `deadline`, `status` |
| `FraudFlag` | `flaggedAddress`, `severity`, `evidenceHash`, `reporter`, `timestamp` |

**`src/types/Errors.sol`** — 54 custom errors, namespaced by domain (identity, election, vote, payment, forum, fraud).

**`src/types/Events.sol`** — all protocol events declared as free-floating `event` statements, imported by contracts that emit them.

**`src/types/Constants.sol`** — see [§10 Key Constants](#10-key-constants).

---

## 4. Core Contracts

### Identity Cluster — `src/identity/`

#### `IdentityRegistry.sol`
- **Pattern**: UUPS · AccessControl · Pausable
- **Purpose**: Voter KYC registration with off-chain identity proof (no PII stored on-chain — only a `keccak256` identity hash)
- **Key functions**:

| Function | Auth | Description |
|---|---|---|
| `registerVoter(addr, identityHash, level, sig)` | EIP-712 sig from `BACKEND_SIGNER` | Register a voter with a verification level |
| `banVoter(addr, sig)` | EIP-712 sig from `BACKEND_SIGNER` | Permanently ban a voter |
| `upgradeTier(addr, newLevel, sig)` | EIP-712 sig from `BACKEND_SIGNER` | Elevate KYC tier (e.g. after face verification) |
| `isRegistered(addr)` | Public | Returns `true` if voter is active |
| `isBanned(addr)` | Public | Returns `true` if voter is banned |

- **Replay protection**: per-voter nonce incremented on every signed operation
- **Events**: `VoterRegistered`, `VoterBanned`, `TierUpgraded`

#### `RegionRegistry.sol`
- **Pattern**: UUPS · AccessControl
- **Key functions**: `createRegion`, `updateRegion`, `assignVoterRegion`, `getVoterRegion`
- **Auth**: `REGION_ADMIN` role for all mutations
- **Events**: `RegionCreated`, `RegionUpdated`, `VoterRegionAssigned`

#### `ZKVerifier.sol`
- **Pattern**: UUPS · AccessControl
- **Purpose**: Groth16 stub — accepts `(pA, pB, pC, pubSignals)` and returns `bool`
- Designed as a **drop-in** for a `snarkjs`-exported Solidity verifier

---

### Party & Candidate — `src/`

#### `PoliticalPartyRegistry.sol`
- **Pattern**: UUPS · AccessControl
- **Status lifecycle**: `Pending → Active | Suspended | Dissolved`
- Manifesto stored as `keccak256` hash; full document lives on IPFS
- **Auth**: `PARTY_REGISTRAR` role
- **Events**: `PartyRegistered`, `PartyApproved`, `PartyStatusChanged`, `ManifestoUpdated`

#### `CandidateRegistry.sol`
- **Pattern**: UUPS · AccessControl
- **Status lifecycle**: `Pending → Active | Disqualified | Withdrawn`
- Popularity score updated via EIP-712 signed batch (prevents gas-expensive on-chain aggregation)
- **Key functions**:

| Function | Auth | Description |
|---|---|---|
| `nominate(candidateAddr, electionId, partyId)` | `OPERATOR` | Nominate a candidate |
| `approve(candidateId)` | `OPERATOR` | Approve candidate for election |
| `disqualify(candidateId, reasonHash)` | `OPERATOR` | Disqualify with reason |
| `updatePopularityScore(candidateId, delta, sig)` | EIP-712 `BACKEND_SIGNER` | Adjust popularity score |

- **Events**: `CandidateNominated`, `CandidateApproved`, `CandidateDisqualified`, `CandidateScoreUpdated`

---

### Election — `src/core/ElectionFactory.sol`

- **Pattern**: UUPS · AccessControl
- **Phase state machine**:

```
PENDING → ACTIVE → TALLYING → FINALIZED
              ↓
          PAUSED → ACTIVE (resume)
              ↓
          CANCELLED
```

- **Key functions**:

| Function | Auth | Description |
|---|---|---|
| `createElection(params)` | `ELECTION_CREATOR` | Configure election (type, region, dates, fee) |
| `startVoting(electionId)` | `OPERATOR` | Advance `PENDING → ACTIVE` |
| `pauseVoting(electionId)` | `OPERATOR` | Emergency pause |
| `resumeVoting(electionId)` | `OPERATOR` | Resume from pause |
| `endVoting(electionId)` | `OPERATOR` | Advance `ACTIVE → TALLYING` |
| `finalise(electionId, winner, resultHash)` | `TALLY` | Publish winner + IPFS result CID |
| `cancel(electionId)` | `ADMIN` | Cancel and unlock escrow refunds |

- **Events**: `ElectionCreated`, `PhaseTransitioned`, `ElectionFinalised`, `ElectionCancelled`

---

### Payments — `src/payments/VoteFeeEscrow.sol`

- **Pattern**: UUPS · ReentrancyGuard · AccessControl
- **Pull-payment pattern** — no direct ETH push to arbitrary addresses
- **Key functions**:

| Function | Auth | Description |
|---|---|---|
| `deposit(electionId)` | Voter (payable) | Lock exact fee on castVote |
| `releaseFee(electionId, voter, candidate)` | `VoteProtocol` | Forward fee to candidate payout address |
| `refund(electionId)` | Voter | Pull refund after election cancelled |
| `batchRefund(electionId, voters[])` | `OPERATOR` | Operator-triggered batch refund (≤200) |

- **Events**: `FeeDeposited`, `FeeReleased`, `FeeRefunded`

---

### Vote Protocol — `src/core/VoteProtocol.sol`

- **Pattern**: UUPS · ReentrancyGuard · Pausable
- **`castVote(params)` — 8-step validation pipeline**:

```
Step 1 — Election in ACTIVE phase              (ElectionFactory)
Step 2 — Voter registered and not banned       (IdentityRegistry)
Step 3 — Voter region matches election region  (RegionRegistry)
Step 4 — Candidate approved in this election   (CandidateRegistry)
Step 5 — Nullifier not already consumed        (double-vote prevention)
Step 6 — EIP-712 backend sig valid + not stale (15-min expiry + nonce)
Step 7 — Optional ZK proof verification        (ZKVerifier — skipped if empty)
Step 8 — Exact fee deposit confirmed           (VoteFeeEscrow)
```

- **`revote(oldParams, newParams)`**: burns old nullifier, stores new, adjusts tallies, re-runs all 8 steps
- **Events**: `VoteCast`, `VoteRevoked`, `VoteChanged`

---

### Forum — `src/ForumGovernance.sol`

- **Pattern**: UUPS · Pausable · AccessControl
- Voters post questions (content stored as IPFS CID hash); candidates reply within **24 hr SLA**
- SLA breach auto-applies `SLA_MISS_PENALTY = -50` to candidate popularity score
- Moderator (`MODERATOR_ROLE`) can score posts 1-5, pin, and remove content
- **Events**: `PostCreated`, `PostReplied`, `PostModerated`, `PostPinned`, `SLABreached`

---

### Fraud Detection — `src/FraudDetection.sol`

- **Pattern**: UUPS · AccessControl · Pausable
- `FRAUD_ORACLE_ROLE` submits flags with `FraudSeverity`
- `HIGH` or `CRITICAL` → immediate `IdentityRegistry.banVoter()` call
- Accumulated score threshold escalates `MEDIUM → HIGH`
- Evidence stored as IPFS CID hash
- **Events**: `FraudFlagSubmitted`, `SeverityEscalated`, `AutoBanTriggered`

---

### Donation Distributor — `src/DonationDistributor.sol`

- Splits ETH donations among approved candidates by weight set per election
- Pull-pattern distribution — no push to arbitrary addresses
- **Events**: `DonationReceived`, `DonationDistributed`, `WeightUpdated`

---

## 5. Interfaces

| Interface | Key Functions |
|---|---|
| `IIdentityRegistry` | `registerVoter`, `banVoter`, `upgradeTier`, `isRegistered`, `isBanned` |
| `IRegionRegistry` | `createRegion`, `assignVoterRegion`, `getVoterRegion` |
| `ICandidateRegistry` | `nominate`, `approve`, `disqualify`, `updatePopularityScore` |
| `IPoliticalPartyRegistry` | `registerParty`, `approveParty`, `updateManifesto` |
| `IElectionFactory` | `createElection`, `startVoting`, `finalise`, `cancel` |
| `IVoteFeeEscrow` | `deposit`, `releaseFee`, `refund`, `batchRefund` |
| `IVoteProtocol` | `castVote(CastVoteParams)`, `revote` |
| `IForumGovernance` | `createPost`, `reply`, `moderatePost`, `scorePost` |
| `IFraudDetection` | `submitFlag`, `escalate`, `getScore` |
| `IDonationDistributor` | `donate`, `setWeights`, `withdraw` |
| `IElectionManager` | Legacy alias — maps to `IElectionFactory` |
| `IModerator` | Legacy alias — maps to `IForumGovernance` |
| `IVoterRegistry` | Legacy alias — maps to `IIdentityRegistry` |

`IVoteProtocol` also defines the `CastVoteParams` struct used by `VoteProtocol.castVote()`.

---

## 6. Deployment Scripts

### `script/DeploySystem.s.sol` — Full system deploy

Deploys all 10 core contracts as UUPS proxies in dependency order and wires cross-contract roles:

```
1.  ZKVerifier
2.  RegionRegistry
3.  IdentityRegistry       ← grants ZKVerifier.VERIFIER_ROLE
4.  PoliticalPartyRegistry
5.  CandidateRegistry
6.  ElectionFactory
7.  VoteFeeEscrow
8.  VoteProtocol           ← granted VoteFeeEscrow.RELEASER_ROLE
                           ← granted IdentityRegistry.READER_ROLE
9.  ForumGovernance        ← granted CandidateRegistry.SCORE_UPDATER_ROLE
10. FraudDetection         ← granted IdentityRegistry.BANNING_ROLE
```

Outputs proxy addresses to `broadcast/` JSON for SDK / front-end consumption.

### `script/UpgradeContracts.s.sol` — Conditional upgrade

Reads `NEW_IMPL_$(CONTRACT)` env vars and upgrades only those proxies. Safe no-op when vars are unset. Verifies new implementation is `UUPSUpgradeable` before calling `upgradeToAndCall`.

### Other scripts

| Script | Purpose |
|---|---|
| `DeployElection.s.sol` | Deploy and configure a single election |
| `RegisterParties.s.sol` | Batch-register parties from a JSON file via `vm.parseJson` |
| `SetupSystem.s.sol` | Post-deploy role assignment helper |

---

## 7. Tests

### `test/VoteSecureTestBase.t.sol` — Shared test harness

- Deploys full proxy suite in `setUp()` matching `DeploySystem.s.sol` order
- EIP-712 domain separator computed once; signers created via `vm.addr(privKey)`
- **Helper methods**:

| Method | Purpose |
|---|---|
| `signRegisterVoter(addr, level, nonce)` | Produces valid `BACKEND_SIGNER` sig for voter registration |
| `signCastVote(params)` | Produces valid `BACKEND_SIGNER` sig for `castVote` |
| `signUpgradeTier(addr, level, nonce)` | Produces valid sig for tier upgrade |
| `_createActiveElection()` | Creates election → registers candidates → advances to `ACTIVE` |

- **Fixtures**: `admin`, `operator`, `backendSigner`, `voter1–voter4`, `candidate1`, `candidate2` — each with deterministic private key

### Unit Tests

#### `test/unit/IdentityRegistry.t.sol` — 10 tests

| Test | Asserts |
|---|---|
| `testRegisterVoter_success` | Voter stored, nonce incremented |
| `testRegisterVoter_duplicateReverts` | `AlreadyRegistered` error |
| `testRegisterVoter_invalidSigReverts` | `InvalidSignature` error |
| `testRegisterVoter_replayReverts` | Nonce replay blocked |
| `testBanVoter_success` | Status set to Banned |
| `testBanVoter_alreadyBannedReverts` | `AlreadyBanned` error |
| `testUpgradeTier_success` | Tier incremented |
| `testUpgradeTier_unregisteredReverts` | `VoterNotFound` error |
| `testPause_blocksRegistration` | Paused contract reverts |
| `testOnlyAdminCanGrantRoles` | Non-admin `grantRole` reverts |

#### `test/unit/VoteProtocol.t.sol` — 10 tests

| Test | Validates |
|---|---|
| `testCastVote_success` | Full happy path; nullifier stored; fee released |
| `testCastVote_wrongPhaseReverts` | Step 1 gate |
| `testCastVote_bannedVoterReverts` | Step 2 gate |
| `testCastVote_wrongRegionReverts` | Step 3 gate |
| `testCastVote_unapprovedCandidateReverts` | Step 4 gate |
| `testCastVote_doubleVoteReverts` | Step 5 — nullifier replay |
| `testCastVote_staleSigReverts` | Step 6 — expired timestamp |
| `testCastVote_invalidSigReverts` | Step 6 — tampered sig |
| `testRevote_success` | Nullifier recycled; old/new tallies adjusted |
| `testPause_blocksCasting` | Pausable gate verified |

### Integration Tests

#### `test/integration/FullElection.t.sol`

Full lifecycle:
- Deploy → register 3 voters → create election → register candidates → `PENDING → ACTIVE`
- All voters cast; tally verified per candidate
- **Revote path**: voter2 switches candidate mid-election; old/new tallies checked
- **Cancel + refund path**: election cancelled; all voters pull refund; escrow balance asserts zero

### Stub Tests (next sprint)

`ElectionManager.t.sol`, `FraudDetection.t.sol`, `Moderator.t.sol`, `PoliticalPartyRegistry.t.sol`, `VoterRegistry.t.sol`, `DonationDistributor.t.sol`

---

## 8. Access Control Roles

| Role constant | `keccak256` key | Granted to |
|---|---|---|
| `ADMIN_ROLE` | `"ADMIN_ROLE"` | Deployer multisig |
| `OPERATOR_ROLE` | `"OPERATOR_ROLE"` | Backend operator service |
| `MODERATOR_ROLE` | `"MODERATOR_ROLE"` | Forum moderation service |
| `FRAUD_ORACLE_ROLE` | `"FRAUD_ORACLE_ROLE"` | Fraud detection oracle |
| `BACKEND_SIGNER_ROLE` | `"BACKEND_SIGNER_ROLE"` | Off-chain signing key (HSM) |
| `UPGRADER_ROLE` | `"UPGRADER_ROLE"` | Upgrade multisig / timelock |
| `ELECTION_CREATOR_ROLE` | `"ELECTION_CREATOR_ROLE"` | Election admin service |
| `TALLY_ROLE` | `"TALLY_ROLE"` | Results finalisation service |

---

## 9. EIP-712 Signed Operations

All state-mutating operations that originate off-chain are gated behind EIP-712 domain-separated signatures from `BACKEND_SIGNER_ROLE`. This prevents on-chain replay and MEV manipulation.

| Operation | Signed fields |
|---|---|
| `registerVoter` | `voter`, `identityHash`, `verificationLevel`, `nonce`, `expiry` |
| `banVoter` | `voter`, `nonce`, `expiry` |
| `upgradeTier` | `voter`, `newLevel`, `nonce`, `expiry` |
| `castVote` | `electionId`, `candidateId`, `nullifier`, `nonce`, `expiry` |
| `updatePopularityScore` | `candidateId`, `delta`, `nonce`, `expiry` |

**Replay protection**: per-subject nonce incremented on every consumed signature. Signatures expire after `SIGNATURE_VALIDITY = 15 minutes`.

---

## 10. Key Constants

Defined in `src/types/Constants.sol`:

| Constant | Value | Purpose |
|---|---|---|
| `QUESTION_SLA` | 24 hours | Forum candidate reply deadline |
| `SIGNATURE_VALIDITY` | 15 minutes | EIP-712 sig expiry window |
| `MIN_ELECTION_DURATION` | 1 hour | Shortest allowed election window |
| `MAX_ELECTION_DURATION` | 365 days | Longest allowed election window |
| `DISPUTE_PERIOD` | 24 hours | Post-finalisation challenge window |
| `DEFAULT_VOTE_FEE_CENTS` | 100 ($1.00) | Default fee in USD cents |
| `MIN_VOTE_FEE_CENTS` | 10 ($0.10) | Minimum configurable fee |
| `MAX_VOTE_FEE_CENTS` | 10,000 ($100.00) | Maximum configurable fee |
| `PROTOCOL_FEE_BPS` | 500 (5%) | Protocol cut of escrow on finalisation |
| `SLA_MISS_PENALTY` | -50 | Popularity score delta on SLA breach |
| `GOOD_ANSWER_REWARD` | +10 | Popularity delta for quality forum answer |
| `MAX_CANDIDATES_PER_ELECTION` | 100 | Hard cap on candidate count |
| `MIN_CANDIDATES_PER_ELECTION` | 2 | Minimum to start voting |

---

## 11. Dependencies

| Library | Version | Purpose |
|---|---|---|
| `openzeppelin-contracts` | v5 | AccessControl, UUPS, ReentrancyGuard, Pausable, EIP-712 |
| `openzeppelin-contracts-upgradeable` | v5 | Upgradeable variants of all OZ contracts |
| `forge-std` | latest | Test helpers, `vm` cheatcodes, `Script` base |

Installed via `forge install`. Managed as git submodules in `lib/`.

**Remappings** (in `foundry.toml`):
```toml
remappings = [
  "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
  "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
  "forge-std/=lib/forge-std/src/",
]
```

---

## 12. Makefile Commands

```bash
make install          # forge install all dependencies
make build            # forge build (via_ir, optimizer 200)
make clean            # forge clean (remove cache/ and out/)
make test             # forge test -vvv
make gas              # forge test --gas-report
make fmt              # forge fmt (auto-format all .sol files)
make lint             # npx solhint 'src/**/*.sol'
make size             # forge build --sizes (contract byte sizes)
make snapshot         # forge snapshot (gas baseline)

# Deployment
make deploy-anvil     # local Anvil node (default key)
make deploy-sepolia   # Sepolia testnet + Etherscan verify
make deploy-mainnet   # Ethereum mainnet + Etherscan verify
make deploy-polygon   # Polygon mainnet + verify
make deploy-zksync    # zkSync Era mainnet

# Upgrade
make upgrade          # UpgradeContracts.s.sol (reads NEW_IMPL_* env vars)
```

---

## 13. Environment Variables

Copy `.env.example` to `.env` before deploying:

```bash
cp .env.example .env
```

| Variable | Required | Description |
|---|---|---|
| `PRIVATE_KEY` | Deploy | Deployer EOA private key (no `0x` prefix) |
| `RPC_URL` | Deploy | JSON-RPC endpoint for target network |
| `SEPOLIA_RPC_URL` | Testnet | Sepolia RPC (Infura / Alchemy) |
| `MAINNET_RPC_URL` | Mainnet | Ethereum mainnet RPC |
| `POLYGON_RPC_URL` | Polygon | Polygon RPC |
| `ZKSYNC_RPC_URL` | zkSync | zkSync Era RPC |
| `ETHERSCAN_API_KEY` | Verify | Etherscan API key for contract verification |
| `BACKEND_SIGNER_KEY` | Runtime | Private key for EIP-712 off-chain signing (HSM in production) |
| `NEW_IMPL_IDENTITY_REGISTRY` | Upgrade | New implementation address for `UpgradeContracts.s.sol` |
| `NEW_IMPL_VOTE_PROTOCOL` | Upgrade | New `VoteProtocol` implementation address |

> **Never commit `.env`** — it is excluded in `.gitignore`.

---

## 14. Build Status

| Component | Status |
|---|---|
| `src/types/` — DataTypes, Errors, Events, Constants | Done |
| `src/identity/` — IdentityRegistry, RegionRegistry, ZKVerifier | Done |
| `src/PoliticalPartyRegistry` | Done |
| `src/CandidateRegistry` | Done |
| `src/core/ElectionFactory` | Done |
| `src/payments/VoteFeeEscrow` | Done |
| `src/core/VoteProtocol` | Done |
| `src/ForumGovernance` | Done |
| `src/FraudDetection` | Done |
| `src/DonationDistributor` | Done |
| Legacy alias contracts (VoterRegistry, Vote, Moderator, ElectionManager) | Done |
| All 13 interfaces | Done |
| DeploySystem.s.sol + UpgradeContracts.s.sol | Done |
| VoteSecureTestBase.t.sol | Done |
| IdentityRegistry unit tests (10) | Done |
| VoteProtocol unit tests (10) | Done |
| FullElection integration test | Done |
| `forge build` — zero errors | Done |
| Stub tests (ElectionManager, FraudDetection, Moderator, Party, Voter, Donation) | TODO |
| Full unit coverage for remaining contracts | TODO |
| Invariant tests | TODO |
| CI pipeline (GitHub Actions) | TODO |
| Natspec documentation generation | TODO |
| Formal verification (Certora / Halmos) | TODO |
