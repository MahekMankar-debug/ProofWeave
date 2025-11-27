// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ProofWeave
 * @dev Links multiple hashed artifacts into a single proof "weave" with versioned entries
 * @notice Use to group related hashes under a weaveId and track their history
 */
contract ProofWeave {
    address public owner;

    struct Weave {
        bytes32 id;          // logical weave identifier
        address creator;     // who created the weave
        string  label;       // human-readable label
        uint256 createdAt;   // weave creation time
        bool    isActive;    // soft delete flag
    }

    struct WeaveEntry {
        uint256 entryIndex;   // index within the weave
        bytes32 dataHash;     // hash of artifact
        string  note;         // optional note/description
        uint256 timestamp;    // when this hash was added
        bool    isActive;     // per-entry soft delete
    }

    // weaveId => Weave
    mapping(bytes32 => Weave) public weaves;

    // weaveId => list of entries
    mapping(bytes32 => WeaveEntry[]) public entriesOf;

    // creator => weaveIds
    mapping(address => bytes32[]) public weavesOf;

    event WeaveCreated(
        bytes32 indexed weaveId,
        address indexed creator,
        string label,
        uint256 createdAt
    );

    event WeaveStatusUpdated(
        bytes32 indexed weaveId,
        bool isActive,
        uint256 timestamp
    );

    event EntryAdded(
        bytes32 indexed weaveId,
        uint256 indexed entryIndex,
        bytes32 indexed dataHash,
        string note,
        uint256 timestamp
    );

    event EntryStatusUpdated(
        bytes32 indexed weaveId,
        uint256 indexed entryIndex,
        bool isActive,
        uint256 timestamp
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier weaveExists(bytes32 weaveId) {
        require(weaves[weaveId].creator != address(0), "Weave not found");
        _;
    }

    modifier onlyWeaveCreator(bytes32 weaveId) {
        require(weaves[weaveId].creator == msg.sender, "Not weave creator");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Create a new proof weave
     * @param weaveId User-chosen logical id (must be unique)
     * @param label Human-readable label
     */
    function createWeave(bytes32 weaveId, string calldata label) external {
        require(weaveId != 0, "Invalid id");
        require(weaves[weaveId].creator == address(0), "Weave exists");

        weaves[weaveId] = Weave({
            id: weaveId,
            creator: msg.sender,
            label: label,
            createdAt: block.timestamp,
            isActive: true
        });

        weavesOf[msg.sender].push(weaveId);

        emit WeaveCreated(weaveId, msg.sender, label, block.timestamp);
    }

    /**
     * @dev Toggle weave active status
     * @param weaveId Weave identifier
     * @param active New active state
     */
    function setWeaveActive(bytes32 weaveId, bool active)
        external
        weaveExists(weaveId)
        onlyWeaveCreator(weaveId)
    {
        weaves[weaveId].isActive = active;
        emit WeaveStatusUpdated(weaveId, active, block.timestamp);
    }

    /**
     * @dev Add a new hash entry to an existing weave
     * @param weaveId Weave identifier
     * @param dataHash Hash of the artifact
     * @param note Optional description
     * @return entryIndex Index of the created entry
     */
    function addEntry(
        bytes32 weaveId,
        bytes32 dataHash,
        string calldata note
    )
        external
        weaveExists(weaveId)
        returns (uint256 entryIndex)
    {
        require(dataHash != bytes32(0), "Invalid hash");
        require(weaves[weaveId].isActive, "Weave inactive");

        entryIndex = entriesOf[weaveId].length;

        entriesOf[weaveId].push(
            WeaveEntry({
                entryIndex: entryIndex,
                dataHash: dataHash,
                note: note,
                timestamp: block.timestamp,
                isActive: true
            })
        );

        emit EntryAdded(weaveId, entryIndex, dataHash, note, block.timestamp);
    }

    /**
     * @dev Update active status of a specific entry
     * @param weaveId Weave identifier
     * @param entryIndex Index of the entry in that weave
     */
    function setEntryActive(
        bytes32 weaveId,
        uint256 entryIndex,
        bool active
    )
        external
        weaveExists(weaveId)
        onlyWeaveCreator(weaveId)
    {
        require(entryIndex < entriesOf[weaveId].length, "Invalid index");

        entriesOf[weaveId][entryIndex].isActive = active;

        emit EntryStatusUpdated(weaveId, entryIndex, active, block.timestamp);
    }

    /**
     * @dev Get all entries for a given weave
     * @param weaveId Weave identifier
     * @return entries Array of WeaveEntry structs
     */
    function getEntries(bytes32 weaveId)
        external
        view
        weaveExists(weaveId)
        returns (WeaveEntry[] memory entries)
    {
        return entriesOf[weaveId];
    }

    /**
     * @dev Get all weaveIds created by a user
     * @param user Address to query
     */
    function getWeavesOf(address user) external view returns (bytes32[] memory) {
        return weavesOf[user];
    }

    /**
     * @dev Transfer contract ownership
     * @param newOwner New owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
