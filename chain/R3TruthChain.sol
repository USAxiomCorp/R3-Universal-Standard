// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

/**
 * ================================================================
 * R³ TRUTH CHAIN
 * Russell Recursive Refinement — Universal Standard Axiom Corporation
 * ================================================================
 *
 * The official on-chain registry for R³ fixed points,
 * certainty briefs, and verification results.
 *
 * ARCHITECTURE:
 *   Primary Document (Dossier/Specification)
 *     └── Certainty Briefs (one per audience)
 *     └── Verification Results (from any institution)
 *     └── Correction Records (self-correction audit)
 *
 * Everything anchored in time.
 * Everything linked to its source.
 * Everything immutable.
 * Everything queryable by anyone.
 *
 * Deployed on: Polygon Mainnet
 * Author: Michael A. Russell
 * Organization: Advanceer IVS Labs
 *               Universal Standard Axiom Corporation
 * Patent: US Application 19/383,582
 * ================================================================
 */

contract R3TruthChain {

    // ============================================================
    // OWNER
    // ============================================================

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // ============================================================
    // DATA STRUCTURES
    // ============================================================

    /**
     * PRIMARY DOCUMENT
     * The dossier or specification.
     * The fixed point of the transaction.
     * Everything else links to this.
     */
    struct PrimaryDocument {
        bytes32 documentHash;     // SHA256 hash of the document
        string  industry;         // "pharmaceuticals" | "materials" | "finance" | etc
        string  fixedPoint;       // One sentence description of the fixed point
        string  iterationDepth;   // e.g. "10^15"
        string  certaintyLevel;   // "Confirmed" | "High" | "Medium-High" | "Medium" | "Pending" | "Theoretical"
        string  documentId;       // Human readable ID e.g. "R3-SPEC-MATERIALS-20260315"
        string  repositoryUrl;    // GitHub or IPFS URL
        uint256 timestamp;        // Block timestamp at registration
        address registrant;       // Who registered it
        bool    exists;
    }

    /**
     * CERTAINTY BRIEF
     * Derived from a primary document.
     * Translated for a specific audience.
     * Always links back to primary.
     */
    struct CertaintyBrief {
        bytes32 briefHash;        // SHA256 hash of the brief
        bytes32 primaryHash;      // Links to primary document
        string  audience;         // "bank" | "regulator" | "court" | "partner" | etc
        string  documentId;       // Human readable ID
        string  certaintyLevel;   // Inherited or adjusted from primary
        uint256 timestamp;
        address registrant;
        bool    exists;
    }

    /**
     * VERIFICATION RESULT
     * Submitted by any institution.
     * Linked to primary document.
     * Positive and negative equally recorded.
     */
    struct VerificationResult {
        bytes32 resultHash;       // Hash of the result document
        bytes32 primaryHash;      // Which fixed point was verified
        string  institution;      // Who performed verification
        string  verifier;         // Name of principal investigator
        string  result;           // "CONFIRM" | "DENY" | "INCONCLUSIVE"
        string  method;           // "DFT" | "EXPERIMENTAL" | "COMPUTATIONAL" | etc
        string  dataUrl;          // Where full data is stored
        uint256 timestamp;
        address submitter;
    }

    /**
     * CORRECTION RECORD
     * When R³ finds an error in its own work.
     * The error, the correction, the date.
     * Transparent. Permanent. Honest.
     */
    struct CorrectionRecord {
        bytes32 correctionHash;   // Hash of correction document
        bytes32 primaryHash;      // Which document was corrected
        string  errorDescription; // What was wrong
        string  correction;       // What was fixed
        string  documentId;       // Correction document ID
        uint256 timestamp;
        address registrant;
    }

    // ============================================================
    // STORAGE
    // ============================================================

    // Primary documents indexed by their hash
    mapping(bytes32 => PrimaryDocument) public primaryDocuments;

    // Certainty briefs indexed by brief hash
    mapping(bytes32 => CertaintyBrief) public certaintyBriefs;

    // All briefs derived from a primary document
    mapping(bytes32 => bytes32[]) public briefsByPrimary;

    // All verification results for a primary document
    mapping(bytes32 => VerificationResult[]) public resultsByPrimary;

    // All corrections for a primary document
    mapping(bytes32 => CorrectionRecord[]) public correctionsByPrimary;

    // Registry of all primary document hashes in order
    bytes32[] public primaryRegistry;

    // ============================================================
    // EVENTS
    // ============================================================

    event FixedPointRegistered(
        bytes32 indexed documentHash,
        string  industry,
        string  fixedPoint,
        string  documentId,
        uint256 timestamp
    );

    event CertaintyBriefRegistered(
        bytes32 indexed briefHash,
        bytes32 indexed primaryHash,
        string  audience,
        string  documentId,
        uint256 timestamp
    );

    event VerificationResultRecorded(
        bytes32 indexed primaryHash,
        string  institution,
        string  result,
        string  method,
        uint256 timestamp
    );

    event CorrectionRecorded(
        bytes32 indexed primaryHash,
        string  errorDescription,
        string  documentId,
        uint256 timestamp
    );

    // ============================================================
    // REGISTER PRIMARY DOCUMENT
    // ============================================================

    /**
     * Register a fixed point specification on chain.
     * This anchors the primary document in time.
     * Anyone can verify the hash matches the document.
     *
     * @param documentHash  SHA256 hash of the document file
     * @param industry      Industry domain
     * @param fixedPoint    One sentence fixed point description
     * @param iterationDepth  R3 iteration depth
     * @param certaintyLevel  Current certainty level
     * @param documentId    Human readable document ID
     * @param repositoryUrl Where the document lives
     */
    function registerFixedPoint(
        bytes32 documentHash,
        string memory industry,
        string memory fixedPoint,
        string memory iterationDepth,
        string memory certaintyLevel,
        string memory documentId,
        string memory repositoryUrl
    ) external onlyOwner {
        require(documentHash != bytes32(0), "Invalid hash");
        require(!primaryDocuments[documentHash].exists, "Already registered");

        primaryDocuments[documentHash] = PrimaryDocument({
            documentHash:   documentHash,
            industry:       industry,
            fixedPoint:     fixedPoint,
            iterationDepth: iterationDepth,
            certaintyLevel: certaintyLevel,
            documentId:     documentId,
            repositoryUrl:  repositoryUrl,
            timestamp:      block.timestamp,
            registrant:     msg.sender,
            exists:         true
        });

        primaryRegistry.push(documentHash);

        emit FixedPointRegistered(
            documentHash,
            industry,
            fixedPoint,
            documentId,
            block.timestamp
        );
    }

    // ============================================================
    // REGISTER CERTAINTY BRIEF
    // ============================================================

    /**
     * Register a certainty brief derived from a primary document.
     * Links the brief to its source. Proves derivation chain.
     *
     * @param briefHash     SHA256 hash of the brief document
     * @param primaryHash   Hash of the primary document this derives from
     * @param audience      Who this brief is for
     * @param documentId    Human readable brief ID
     * @param certaintyLevel Certainty level stated in this brief
     */
    function registerCertaintyBrief(
        bytes32 briefHash,
        bytes32 primaryHash,
        string memory audience,
        string memory documentId,
        string memory certaintyLevel
    ) external onlyOwner {
        require(briefHash != bytes32(0), "Invalid hash");
        require(primaryDocuments[primaryHash].exists, "Primary not registered");
        require(!certaintyBriefs[briefHash].exists, "Already registered");

        certaintyBriefs[briefHash] = CertaintyBrief({
            briefHash:      briefHash,
            primaryHash:    primaryHash,
            audience:       audience,
            documentId:     documentId,
            certaintyLevel: certaintyLevel,
            timestamp:      block.timestamp,
            registrant:     msg.sender,
            exists:         true
        });

        briefsByPrimary[primaryHash].push(briefHash);

        emit CertaintyBriefRegistered(
            briefHash,
            primaryHash,
            audience,
            documentId,
            block.timestamp
        );
    }

    // ============================================================
    // RECORD VERIFICATION RESULT
    // ============================================================

    /**
     * Record a verification result — positive or negative.
     * Anyone can submit. All results recorded equally.
     * This is open science. No selective reporting.
     *
     * @param resultHash    SHA256 hash of the result document
     * @param primaryHash   Which fixed point was verified
     * @param institution   Institution that performed verification
     * @param verifier      Name of principal investigator
     * @param result        CONFIRM | DENY | INCONCLUSIVE
     * @param method        DFT | EXPERIMENTAL | COMPUTATIONAL | etc
     * @param dataUrl       Where full data is stored
     */
    function recordVerification(
        bytes32 resultHash,
        bytes32 primaryHash,
        string memory institution,
        string memory verifier,
        string memory result,
        string memory method,
        string memory dataUrl
    ) external {
        require(resultHash != bytes32(0), "Invalid hash");
        require(primaryDocuments[primaryHash].exists, "Primary not registered");

        resultsByPrimary[primaryHash].push(VerificationResult({
            resultHash:   resultHash,
            primaryHash:  primaryHash,
            institution:  institution,
            verifier:     verifier,
            result:       result,
            method:       method,
            dataUrl:      dataUrl,
            timestamp:    block.timestamp,
            submitter:    msg.sender
        }));

        emit VerificationResultRecorded(
            primaryHash,
            institution,
            result,
            method,
            block.timestamp
        );
    }

    // ============================================================
    // RECORD CORRECTION
    // ============================================================

    /**
     * Record a self-correction.
     * R3 applied to R3 — errors documented publicly.
     * The correction record is as important as the work.
     *
     * @param correctionHash    Hash of correction document
     * @param primaryHash       Which document was corrected
     * @param errorDescription  What was wrong
     * @param correction        What was fixed
     * @param documentId        Correction document ID
     */
    function recordCorrection(
        bytes32 correctionHash,
        bytes32 primaryHash,
        string memory errorDescription,
        string memory correction,
        string memory documentId
    ) external onlyOwner {
        require(correctionHash != bytes32(0), "Invalid hash");
        require(primaryDocuments[primaryHash].exists, "Primary not registered");

        correctionsByPrimary[primaryHash].push(CorrectionRecord({
            correctionHash:   correctionHash,
            primaryHash:      primaryHash,
            errorDescription: errorDescription,
            correction:       correction,
            documentId:       documentId,
            timestamp:        block.timestamp,
            registrant:       msg.sender
        }));

        emit CorrectionRecorded(
            primaryHash,
            errorDescription,
            documentId,
            block.timestamp
        );
    }

    // ============================================================
    // READ FUNCTIONS
    // ============================================================

    /**
     * Get a primary document by hash
     */
    function getFixedPoint(bytes32 documentHash)
        external view
        returns (PrimaryDocument memory)
    {
        require(primaryDocuments[documentHash].exists, "Not found");
        return primaryDocuments[documentHash];
    }

    /**
     * Get all briefs derived from a primary document
     */
    function getBriefsByPrimary(bytes32 primaryHash)
        external view
        returns (bytes32[] memory)
    {
        return briefsByPrimary[primaryHash];
    }

    /**
     * Get all verification results for a primary document
     */
    function getVerificationResults(bytes32 primaryHash)
        external view
        returns (VerificationResult[] memory)
    {
        return resultsByPrimary[primaryHash];
    }

    /**
     * Get all corrections for a primary document
     */
    function getCorrections(bytes32 primaryHash)
        external view
        returns (CorrectionRecord[] memory)
    {
        return correctionsByPrimary[primaryHash];
    }

    /**
     * Get total number of registered fixed points
     */
    function totalFixedPoints()
        external view
        returns (uint256)
    {
        return primaryRegistry.length;
    }

    /**
     * Get the full registry of primary document hashes
     */
    function getRegistry()
        external view
        returns (bytes32[] memory)
    {
        return primaryRegistry;
    }

    /**
     * Verify a document hash matches what is on chain
     * Any party can call this to verify authenticity
     */
    function verifyDocument(bytes32 documentHash)
        external view
        returns (
            bool    isRegistered,
            string  memory industry,
            string  memory fixedPoint,
            string  memory certaintyLevel,
            uint256 registeredAt
        )
    {
        PrimaryDocument memory doc = primaryDocuments[documentHash];
        return (
            doc.exists,
            doc.industry,
            doc.fixedPoint,
            doc.certaintyLevel,
            doc.timestamp
        );
    }

    /**
     * Get complete chain summary for a fixed point
     * One call returns everything associated with a primary document
     */
    function getChainSummary(bytes32 primaryHash)
        external view
        returns (
            PrimaryDocument     memory primary,
            uint256                    briefCount,
            uint256                    verificationCount,
            uint256                    correctionCount
        )
    {
        require(primaryDocuments[primaryHash].exists, "Not found");
        return (
            primaryDocuments[primaryHash],
            briefsByPrimary[primaryHash].length,
            resultsByPrimary[primaryHash].length,
            correctionsByPrimary[primaryHash].length
        );
    }
}
