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

addEligibilityVerifier:
    This function allows the insured to add an eligibility verifier needed for this contract.
verifyEligibility: (Done)
setAccidentVerifier

setLossVerifier:

addInsurerCandidate

pickInsurerLottery

EV_type: 

    There are two types of eligibility verification. And and Or.
    And type means the eligibility is verified if all eligibility verifiers say yes.
    Or type means the eligibility is verified if at least one eligibility verifiers says yes.
    0 for And
    1 for Or


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

    uint256 EV_type;
    address payable[] public eligibilityVerifier;
    address payable[] public AccidentVerifier;
    mapping(address => bool) public eligibilityVerifierResult;
    POLICY_STATE public policy_state = OPEN_UNVERIFIED;

    constructor(uint256 _EV_type) {
        require(
            _EV_type == 1 || _EV_type == 0,
            "The type of eligibility verification can only be 1 or 0"
        );
        EV_type = _EV_type;
    }

    function addEligibilityVerifier(address payable _eligibilityVerifier)
        public
        onlyOwner
    {
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Eligibility Verifier at this stage!"
        );
        bool EV_exist = false;
        for (uint256 i = 0; i < eligibilityVerifier.length; i++) {
            if (eligibilityVerifier[i] == _eligibilityVerifier) {
                EV_exist = true;
            }
        }
        if (EV_exist == false) {
            eligibilityVerifier.push(_eligibilityVerifier);
        }
    }

    function get_EV_length() public view returns (uint256) {
        return eligibilityVerifier.length;
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
