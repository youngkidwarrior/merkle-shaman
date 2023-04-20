// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(
        bytes32[] memory proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(
            leavesLen + proof.length - 1 == totalHashes,
            "MerkleProof: invalid multiproof"
        );

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen
                ? leaves[leafPos++]
                : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuilds the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(
            leavesLen + proof.length - 1 == totalHashes,
            "MerkleProof: invalid multiproof"
        );

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value from the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen
                ? leaves[leafPos++]
                : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(
        bytes32 a,
        bytes32 b
    ) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

interface IBAAL {
    function mintLoot(
        address[] calldata to,
        uint256[] calldata amount
    ) external;

    function mintShares(
        address[] calldata to,
        uint256[] calldata amount
    ) external;

    function shamans(address shaman) external returns (uint256);

    function isManager(address shaman) external returns (bool);

    function target() external returns (address);

    function totalSupply() external view returns (uint256);

    function sharesToken() external view returns (address);

    function lootToken() external view returns (address);
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title MerkleDropShaman
 * @dev This contract allows for a token drop of multiple tokens (shares, loot, and custom tokens)
 * in a decentralized organization using a Merkle Tree. The Merkle Tree is used to prove
 * the allocation of tokens for each participant. Each Merkle Tree root represents a period
 * during which token claims can be made.
 */
contract MerkleDropShaman {
    IBAAL public baal;
    bytes32[] public merkleRoots;
    mapping(uint256 => mapping(address => bool)) public claimed;

    struct Tokens {
        IERC20 lootToken;
        IERC20 sharesToken;
        IERC20 customToken;
    }

    struct Config {
        bool shouldDropShares;
        bool shouldDropLoot;
        uint256 periodLengthInSeconds;
        uint256 startTimeInSeconds;
    }

    Config dropConfig;
    Tokens dropTokens;

    event Claimed(address indexed user, uint256 period, uint256[3] amounts);

    /**
     * @notice Constructor for MerkleDropShaman contract
     * @param _daoAddress The address of the Baal DAO contract
     * @param _periodLengthInSeconds The length of each drop period in seconds
     * @param _startTimeInSeconds The start time of the first drop period in seconds since Unix epoch
     * @param _shouldDropShares Boolean flag to enable or disable dropping shares tokens
     * @param _shouldDropLoot Boolean flag to enable or disable dropping loot tokens
     * @param _customToken The address of the custom ERC20 token to be dropped (optional)
     */
    constructor(
        address _daoAddress,
        uint256 _periodLengthInSeconds,
        uint256 _startTimeInSeconds,
        bool _shouldDropShares,
        bool _shouldDropLoot,
        address _customToken
    ) {
        require(
            _shouldDropShares || _shouldDropLoot || _customToken != address(0),
            "Must set at least one type of token to be dropped"
        );
        baal = IBAAL(_daoAddress);

        if (_shouldDropShares) {
            dropTokens.sharesToken = IERC20(baal.sharesToken());
        }
        if (_shouldDropLoot) {
            dropTokens.lootToken = IERC20(baal.lootToken());
        }
        if (_customToken != address(0)) {
            dropTokens.customToken = IERC20(_customToken);
        }

        dropConfig = Config({
            periodLengthInSeconds: _periodLengthInSeconds,
            startTimeInSeconds: _startTimeInSeconds,
            shouldDropShares: _shouldDropShares,
            shouldDropLoot: _shouldDropLoot
        });
    }

    /**
     * @notice Claim tokens for a given period using the provided Merkle proof
     * @param period The period for which the claim is being made
     * @param amounts The amounts of tokens being claimed
     * @param merkleProof The Merkle proof to validate the claim
     */
    function claim(
        uint256 period,
        uint256[3] calldata amounts,
        bytes32[] calldata merkleProof
    ) public {
        require(period < merkleRoots.length, "Invalid period");
        require(
            !claimed[period][msg.sender],
            "Already claimed for this period"
        );

        bytes32 node = keccak256(abi.encodePacked(msg.sender, amounts));
        require(
            MerkleProof.verify(merkleProof, merkleRoots[period], node),
            "Invalid Merkle proof"
        );

        address[] memory recipients = new address[](1);
        recipients[0] = msg.sender;

        uint256[] memory _amounts = new uint256[](1);

        // Mint and/or transfer tokens
        if (dropConfig.shouldDropShares) {
            _amounts[0] = amounts[0];
            baal.mintShares(recipients, _amounts);
        }
        if (dropConfig.shouldDropLoot) {
            _amounts[0] = amounts[1];
            baal.mintLoot(recipients, _amounts);
        }
        if (address(dropTokens.customToken) != address(0)) {
            require(
                dropTokens.customToken.transfer(msg.sender, amounts[2]),
                "Token transfer failed"
            );
        }

        // Mark the claim as complete
        claimed[period][msg.sender] = true;

        emit Claimed(msg.sender, period, amounts);
    }

    /**
     * @notice Claim tokens for multiple periods using the provided Merkle proofs
     * @param periods Array of periods for which the claims are being made
     * @param amounts Array of array of amounts of tokens being claimed
     * @param merkleProofs Array of Merkle proofs to validate the claims
     */
    function claimAll(
        uint256[] calldata periods,
        uint256[3][] calldata amounts,
        bytes32[][] calldata merkleProofs
    ) external {
        require(
            periods.length == amounts.length &&
                amounts.length == merkleProofs.length,
            "Input arrays must have the same length"
        );

        for (uint256 i = 0; i < periods.length; i++) {
            claim(periods[i], amounts[i], merkleProofs[i]);
        }
    }

    /**
     * @notice Add a new period with the provided Merkle root
     * @param _merkleRoot The Merkle root for the new period
     */
    function addPeriod(bytes32 _merkleRoot) external {
        require(baal.isManager(msg.sender), "Only manager can add period");
        require(
            block.timestamp >= latestPeriodTimestamp(),
            "Previous period not ended yet"
        );

        merkleRoots.push(_merkleRoot);
    }

    /**
     * @notice Get the start timestamp of the latest period
     * @return uint256 Timestamp of the latest period
     */
    function latestPeriodTimestamp() public view returns (uint256) {
        return
            dropConfig.startTimeInSeconds +
            ((merkleRoots.length) * dropConfig.periodLengthInSeconds);
    }

    /**
     * @notice get how many periods havve passed since the start of the drop
     * @return uint256 Timestamp of the latest period
     */
    function periodCount() external view returns (uint256) {
        return
            (block.timestamp - dropConfig.startTimeInSeconds) /
            dropConfig.periodLengthInSeconds; // solidity should cut off the decimal here and round to the zero
    }

    /**
     * @notice Recover any remaining custom tokens to the Baal DAO's target address
     * callable only by a manager
     */
    function recover() external {
        require(baal.isManager(msg.sender), "Only manager can recover tokens");
        dropTokens.customToken.transfer(
            baal.target(),
            dropTokens.customToken.balanceOf(address(this))
        );
    }

    function getMerkleRoots() external view returns (bytes32[] memory) {
        return merkleRoots;
    }

    function getDropConfig() external view returns (Config memory) {
        return dropConfig;
    }
}
