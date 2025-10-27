// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProofWeave
 * @dev A decentralized proof-of-existence system allowing users to register and verify digital document hashes.
 * This ensures immutability and transparency for digital records.
 */
contract ProofWeave {
    struct Proof {
        address owner;
        uint256 timestamp;
    }

    mapping(bytes32 => Proof) private proofs;

    event ProofRegistered(bytes32 indexed documentHash, address indexed owner, uint256 timestamp);

    /**
     * @dev Register a proof for a digital document hash.
     * @param documentHash The SHA-256 hash of the document.
     */
    function registerProof(bytes32 documentHash) external {
        require(proofs[documentHash].owner == address(0), "Proof already exists");
        proofs[documentHash] = Proof(msg.sender, block.timestamp);
        emit ProofRegistered(documentHash, msg.sender, block.timestamp);
    }

    /**
     * @dev Verify if a proof exists for a given document hash.
     * @param documentHash The SHA-256 hash of the document.
     * @return exists True if proof exists, false otherwise.
     * @return owner Address of the user who registered the proof.
     * @return timestamp The time when proof was registered.
     */
    function verifyProof(bytes32 documentHash)
        external
        view
        returns (bool exists, address owner, uint256 timestamp)
    {
        Proof memory p = proofs[documentHash];
        if (p.owner != address(0)) {
            return (true, p.owner, p.timestamp);
        } else {
            return (false, address(0), 0);
        }
    }

    /**
     * @dev Retrieve the owner of a registered document hash.
     * @param documentHash The SHA-256 hash of the document.
     * @return owner Address of the user who registered the proof.
     */
    function getProofOwner(bytes32 documentHash) external view returns (address owner) {
        return proofs[documentHash].owner;
    }
}
