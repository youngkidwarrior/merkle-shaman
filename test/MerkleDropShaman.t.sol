// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {MerkleDropShaman, IBAAL, IERC20} from "../src/MerkleDropShaman.sol";

contract MerkleDropShamanTest is Test {
    MerkleDropShaman public merkleDropShaman;
    IBAAL public baal;
    IERC20 public customToken;

    function setUp() public {
        // Set up your IBAAL and IERC20 instances here
        // You may need to deploy the contracts or use existing addresses
        baal = IBAAL(address(0));
        customToken = IERC20(address(0));

        uint256 periodLengthInSeconds = 1 weeks;
        uint256 startTimeInSeconds = block.timestamp + 1 days;
        uint256 totalTokensToDrop = 1000;
        bool shouldDropShares = true;
        bool shouldDropLoot = true;
        address customTokenAddress = address(customToken);

        merkleDropShaman = new MerkleDropShaman(
            address(baal),
            periodLengthInSeconds,
            startTimeInSeconds,
            totalTokensToDrop,
            shouldDropShares,
            shouldDropLoot,
            customTokenAddress
        );
    }

    function testAddPeriod() public {
        bytes32[] memory merkleRoots = merkleDropShaman.getMerkleRoots();
        uint256 initialPeriodsCount = merkleRoots.length;
        bytes32 merkleRoot = keccak256("test");
        merkleDropShaman.addPeriod(merkleRoot);
        uint256 newPeriodsCount = merkleRoots.length;

        assertEq(newPeriodsCount, initialPeriodsCount + 1);
        assertEq(merkleDropShaman.merkleRoots(newPeriodsCount - 1), merkleRoot);
    }

    function testLatestPeriodTimestamp() public {
        uint256 initialTimestamp = merkleDropShaman.latestPeriodTimestamp();
        uint256 periodLengthInSeconds = merkleDropShaman
            .getDropConfig()
            .periodLengthInSeconds;

        bytes32 merkleRoot = keccak256("test");
        merkleDropShaman.addPeriod(merkleRoot);

        uint256 newTimestamp = merkleDropShaman.latestPeriodTimestamp();
        assertEq(newTimestamp, initialTimestamp + periodLengthInSeconds);
    }

    // Add more test functions as needed to cover different functionalities and scenarios
}
