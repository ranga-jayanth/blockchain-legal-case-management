// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Educational registry for case IDs and document hashes. Do not store confidential data on-chain.
contract LegalCaseRegistry {
    address public immutable owner;
    mapping(address => bool) public isAuthorized;

    struct CaseRecord {
        bytes32 caseId;
        bytes32 documentHash;
        uint64 createdAt;
        uint64 updatedAt;
        uint32 version;
        bool archived;
    }

    mapping(bytes32 => CaseRecord) private caseRecords;

    event AccessGranted(address indexed account, address indexed grantedBy);
    event AccessRevoked(address indexed account, address indexed revokedBy);
    event CaseCreated(bytes32 indexed caseId, bytes32 documentHash, address indexed createdBy, uint32 version);
    event DocumentHashUpdated(bytes32 indexed caseId, bytes32 documentHash, address indexed updatedBy, uint32 version);
    event CaseArchived(bytes32 indexed caseId, address indexed archivedBy);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyAuthorized() {
        require(isAuthorized[msg.sender], "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        isAuthorized[msg.sender] = true;
        emit AccessGranted(msg.sender, msg.sender);
    }

    function grantAccess(address account) external onlyOwner {
        require(account != address(0), "Invalid account");
        require(!isAuthorized[account], "Already authorized");
        isAuthorized[account] = true;
        emit AccessGranted(account, msg.sender);
    }

    function revokeAccess(address account) external onlyOwner {
        require(account != owner, "Cannot revoke owner");
        require(isAuthorized[account], "Not authorized");
        isAuthorized[account] = false;
        emit AccessRevoked(account, msg.sender);
    }

    function createCase(bytes32 caseId, bytes32 documentHash) external onlyAuthorized {
        require(caseId != bytes32(0), "Invalid case ID");
        require(documentHash != bytes32(0), "Invalid document hash");
        require(caseRecords[caseId].version == 0, "Case already exists");

        uint64 nowTime = uint64(block.timestamp);
        caseRecords[caseId] = CaseRecord({
            caseId: caseId,
            documentHash: documentHash,
            createdAt: nowTime,
            updatedAt: nowTime,
            version: 1,
            archived: false
        });
        emit CaseCreated(caseId, documentHash, msg.sender, 1);
    }

    function updateDocumentHash(bytes32 caseId, bytes32 documentHash) external onlyAuthorized {
        CaseRecord storage record = caseRecords[caseId];
        require(record.version != 0, "Case does not exist");
        require(!record.archived, "Case is archived");
        require(documentHash != bytes32(0), "Invalid document hash");

        record.documentHash = documentHash;
        record.updatedAt = uint64(block.timestamp);
        record.version += 1;
        emit DocumentHashUpdated(caseId, documentHash, msg.sender, record.version);
    }

    function archiveCase(bytes32 caseId) external onlyAuthorized {
        CaseRecord storage record = caseRecords[caseId];
        require(record.version != 0, "Case does not exist");
        require(!record.archived, "Case already archived");
        record.archived = true;
        record.updatedAt = uint64(block.timestamp);
        emit CaseArchived(caseId, msg.sender);
    }

    function getCase(bytes32 caseId) external view onlyAuthorized returns (CaseRecord memory) {
        require(caseRecords[caseId].version != 0, "Case does not exist");
        return caseRecords[caseId];
    }
}
