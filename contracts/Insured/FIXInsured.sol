// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*

Variables to include:

enum POLICY_STATE has 6 states:

OPEN_UNVERIFIED: An insured deployed a smart contract to request an insurance policy but the eligibility is not verified
OPEN_VERIFIED: The eligibility is verified. Open to accept insurers.
AUCTION: The number of insurers meet a certain criterion. Ready to pick insurers.
ACTIVE_POLICY: Policy is effective
ACCIDENT_VERIFIED: An accident occurs and is verified by Accident Verifier.
CLOSED: Policy is closed

eligibility_verifier: an array of payable addresses which could provide eligibility verification with certain fees.

Functions to include:

setInsurerCondition

setEligibilityVerifier:
    This function allows the insured to list the eligibility verifiers needed for this contract.
verifyEligibility: (Done)
setAccidentVerifier

setLossVerifier:

addInsurerCandidate

pickInsurerLottery




*/

// Add modifier for condition check

import "@openzeppelin/contracts/access/Ownable.sol";

contract FIXInsurer is Ownable {
    enum POLICY_STATE {
        OPEN_UNVERIFIED,
        OPEN_VERIFIED,
        AUCTION,
        ACTIVE_POLICY,
        ACCIDENT_VERIFIED,
        CLOSED
    }

    address payable[] public eligibilityVerifier;
    address payable[] public AccidentVerifier;
    mapping(address => bool) public eligibilityVerifierResult;
    POLICY_STATE public policy_state;

    function setEligibilityVerifier(
        address payable[] memory _eligibilityVerifier
    ) public onlyOwner {
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Eligibility Verifier at this stage!"
        );
        for (uint256 i = 0; i < _eligibilityVerifier.length; i++) {
            eligibilityVerifier.push(_eligibilityVerifier[i]);
        }
    }

    function verifyEligibility(bool _verificationDummy) public {
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Eligibility Verification at this stage!"
        );
        for (uint256 i = 0; i < eligibilityVerifier.length; i++) {
            if (msg.sender == eligibilityVerifier[i]) {
                eligibilityVerifierResult[msg.sender] = _verificationDummy;
            }
        }
    }
}
