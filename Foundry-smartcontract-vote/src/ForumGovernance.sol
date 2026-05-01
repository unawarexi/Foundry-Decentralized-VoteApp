// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {DataTypes} from "./types/DataTypes.sol";
import {Constants} from "./types/Constants.sol";
import {Errors__QuestionNotFound,
        Errors__SLANotExpired,
        Errors__QuestionAlreadyClosed,
        Errors__OnlyCandidateCanAnswer,
        Errors__MissingQuestionContent,
        Errors__ZeroAddress,
        Errors__CandidateNotActive} from "./types/Errors.sol";
import {Events__QuestionAsked,
        Events__QuestionAnswered,
        Events__QuestionUpvoted,
        Events__QuestionDownvoted,
        Events__SLAPenaltyApplied} from "./types/Events.sol";
import {IForumGovernance} from "../interfaces/IForumGovernance.sol";
import {ICandidateRegistry} from "../interfaces/ICandidateRegistry.sol";
import {IIdentityRegistry} from "../interfaces/IIdentityRegistry.sol";

/// @title ForumGovernance
/// @notice Manages the Q&A forum per election.
///         Voters ask questions, candidates must answer within 24 hours.
///         SLA misses trigger a popularity score penalty (oracle/keeper calls applyUnansweredPenalty).
///
/// @dev Questions content is stored on IPFS — only the CID hash is on-chain.
///      Popularity deltas are applied to CandidateRegistry via OPERATOR_ROLE call.
contract ForumGovernance is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    IForumGovernance
{
    // ─── State ───────────────────────────────────────────────────────────────

    ICandidateRegistry public candidateRegistry;
    IIdentityRegistry  public identityRegistry;

    mapping(uint256 => DataTypes.Question) private _questions;
    mapping(uint256 => uint256[]) private _candidateQuestions; // candidateId → questionId[]
    mapping(uint256 => uint256[]) private _electionQuestions;  // electionId → questionId[]

    // voter → electionId → questionCount (anti-spam)
    mapping(address => mapping(uint256 => uint256)) private _voterQuestionCount;

    // voter → questionId → voted (upvote/downvote)
    mapping(address => mapping(uint256 => bool)) private _questionVoted;

    uint256 private _nextQuestionId;
    uint256 private _totalQuestions;

    // ─── Initializer ─────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(
        address admin,
        address _candidateRegistry,
        address _identityRegistry
    ) external initializer {
        if (admin == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        _grantRole(Constants.OPERATOR_ROLE, admin);

        candidateRegistry = ICandidateRegistry(_candidateRegistry);
        identityRegistry  = IIdentityRegistry(_identityRegistry);
        _nextQuestionId = 1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ASK QUESTION
    // ─────────────────────────────────────────────────────────────────────────

    function askQuestion(
        uint256 electionId,
        uint256 candidateId,
        bytes32 contentIpfsHash
    )
        external
        whenNotPaused
        returns (uint256 questionId)
    {
        if (contentIpfsHash == bytes32(0)) revert Errors__MissingQuestionContent();

        // Must be a registered voter
        require(identityRegistry.isVoterRegistered(msg.sender), "Must be registered voter");
        require(!identityRegistry.isVoterBanned(msg.sender), "Voter is banned");

        // Candidate must be active
        if (!candidateRegistry.isCandidateActive(candidateId)) {
            revert Errors__CandidateNotActive(candidateId);
        }

        // Anti-spam: max N questions per voter per election
        require(
            _voterQuestionCount[msg.sender][electionId] < Constants.MAX_QUESTIONS_PER_VOTER,
            "Question limit reached"
        );

        questionId = _nextQuestionId++;
        _totalQuestions++;
        _voterQuestionCount[msg.sender][electionId]++;

        uint64 deadline = uint64(block.timestamp) + Constants.QUESTION_SLA;

        _questions[questionId] = DataTypes.Question({
            id: questionId,
            electionId: electionId,
            candidateId: candidateId,
            asker: msg.sender,
            contentIpfsHash: contentIpfsHash,
            status: DataTypes.QuestionStatus.OPEN,
            upvotes: 0,
            downvotes: 0,
            askedAt: uint64(block.timestamp),
            answerDeadline: deadline,
            answeredAt: 0,
            answerIpfsHash: bytes32(0),
            popularityDelta: 0
        });

        _candidateQuestions[candidateId].push(questionId);
        _electionQuestions[electionId].push(questionId);

        emit Events__QuestionAsked(questionId, electionId, candidateId, msg.sender, contentIpfsHash, deadline);
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ANSWER
    // ─────────────────────────────────────────────────────────────────────────

    function answerQuestion(uint256 questionId, bytes32 answerIpfsHash)
        external
        whenNotPaused
    {
        DataTypes.Question storage q = _getOpenQuestion(questionId);

        // Only the candidate can answer
        DataTypes.Candidate memory candidate = candidateRegistry.getCandidate(q.candidateId);
        if (candidate.wallet != msg.sender) revert Errors__OnlyCandidateCanAnswer(questionId);

        q.status = DataTypes.QuestionStatus.ANSWERED;
        q.answeredAt = uint64(block.timestamp);
        q.answerIpfsHash = answerIpfsHash;

        // Reward for answering within SLA
        bool withinSLA = block.timestamp <= q.answerDeadline;
        int256 delta = withinSLA ? Constants.GOOD_ANSWER_REWARD : Constants.BAD_ANSWER_PENALTY;
        q.popularityDelta = delta;

        candidateRegistry.applyPopularityDelta(q.candidateId, delta);

        emit Events__QuestionAnswered(questionId, q.candidateId, answerIpfsHash, uint64(block.timestamp));
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VOTING ON QUESTIONS
    // ─────────────────────────────────────────────────────────────────────────

    function upvoteQuestion(uint256 questionId) external whenNotPaused {
        require(identityRegistry.isVoterRegistered(msg.sender), "Not registered");
        require(!_questionVoted[msg.sender][questionId], "Already voted on question");
        _questions[questionId].upvotes++;
        _questionVoted[msg.sender][questionId] = true;
        emit Events__QuestionUpvoted(questionId, msg.sender, _questions[questionId].upvotes);
    }

    function downvoteQuestion(uint256 questionId) external whenNotPaused {
        require(identityRegistry.isVoterRegistered(msg.sender), "Not registered");
        require(!_questionVoted[msg.sender][questionId], "Already voted on question");
        _questions[questionId].downvotes++;
        _questionVoted[msg.sender][questionId] = true;
        emit Events__QuestionDownvoted(questionId, msg.sender, _questions[questionId].downvotes);
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  SLA ENFORCEMENT (called by keeper/backend oracle)
    // ─────────────────────────────────────────────────────────────────────────

    function applyUnansweredPenalty(uint256 questionId)
        external
        onlyRole(Constants.OPERATOR_ROLE)
    {
        DataTypes.Question storage q = _questions[questionId];
        if (q.id == 0) revert Errors__QuestionNotFound(questionId);
        if (q.status != DataTypes.QuestionStatus.OPEN) revert Errors__QuestionAlreadyClosed(questionId);
        if (block.timestamp <= q.answerDeadline) revert Errors__SLANotExpired(questionId, q.answerDeadline);

        q.status = DataTypes.QuestionStatus.UNANSWERED_EXPIRED;
        q.popularityDelta = Constants.SLA_MISS_PENALTY;

        candidateRegistry.applyPopularityDelta(q.candidateId, Constants.SLA_MISS_PENALTY);

        emit Events__SLAPenaltyApplied(questionId, q.candidateId, Constants.SLA_MISS_PENALTY);
    }

    function closeQuestion(uint256 questionId)
        external
        onlyRole(Constants.MODERATOR_ROLE)
    {
        DataTypes.Question storage q = _questions[questionId];
        if (q.id == 0) revert Errors__QuestionNotFound(questionId);
        q.status = DataTypes.QuestionStatus.CLOSED;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW
    // ─────────────────────────────────────────────────────────────────────────

    function getQuestion(uint256 questionId)
        external
        view
        returns (DataTypes.Question memory)
    {
        return _questions[questionId];
    }

    function getQuestionsForCandidate(uint256 candidateId)
        external
        view
        returns (uint256[] memory)
    {
        return _candidateQuestions[candidateId];
    }

    function getQuestionsForElection(uint256 electionId)
        external
        view
        returns (uint256[] memory)
    {
        return _electionQuestions[electionId];
    }

    function isSLAExpired(uint256 questionId) external view returns (bool) {
        DataTypes.Question storage q = _questions[questionId];
        return q.id != 0
            && q.status == DataTypes.QuestionStatus.OPEN
            && block.timestamp > q.answerDeadline;
    }

    function totalQuestions() external view returns (uint256) { return _totalQuestions; }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _getOpenQuestion(uint256 questionId)
        internal
        view
        returns (DataTypes.Question storage)
    {
        DataTypes.Question storage q = _questions[questionId];
        if (q.id == 0) revert Errors__QuestionNotFound(questionId);
        if (q.status != DataTypes.QuestionStatus.OPEN) revert Errors__QuestionAlreadyClosed(questionId);
        return q;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────────────────────────────────

    function pause() external onlyRole(Constants.ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(Constants.ADMIN_ROLE) { _unpause(); }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}
