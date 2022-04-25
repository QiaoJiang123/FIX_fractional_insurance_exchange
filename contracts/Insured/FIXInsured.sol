// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*

@author: Qiao Jiang
@notice A smart contract to initiate an insurance policy by an insured.

@para enum POLICY_STATE 

    POLICY_STATE has 6 states:
        OPEN_UNVERIFIED: An insured deployed a smart contract to request an insurance policy but the eligibility is not verified
        OPEN_VERIFIED: The eligibility is verified. Open to accept insurers.
        AUCTION: The number of insurers meet a certain criterion. Ready to pick insurers.
        ACTIVE_POLICY: Policy is effective
        ACCIDENT_VERIFIED: An accident occurs and is verified by Accident Verifier.
        CLOSED: Policy is closed

@para eligibilityVerifier
    
    eligibilityVerifier is an array of addresses which could provide eligibility verification with certain fees.

@para eligibilityVerifierResult

    eligibilityVerifierResult is a mapping from address to string. There are 3 values allowed to pass to eligibilityVerifierResult values:
        ADDED: the eligibility verifer has been added but no action has been taken by the verifier.
        VERIFIED_POSITIVE: the eligibility verifier has verified eligibility. The result is positive, which means the insured is eligible to purchase an insurance.
        VERIFIED_NEGATIVE: the eligibility verifier has verified eligibility. The result is negative, which means the insured is not eligible to purchase an insurance.

@para accidentVerifier
    
    accidentVerifier is an array of addresses which could provide accident verification with certain fees.

@para accidentVerifierResult

    accidentVerifierResult is a mapping from address to string. There are 3 values allowed to pass to accidentVerifierResult values:
        ADDED: the accident verifer has been added but no action has been taken by the verifier.
        VERIFIED_POSITIVE: the accident verifier has verified accident. The result is positive, which means an accident has occurred.
        VERIFIED_NEGATIVE: the accident verifier has verified accident. The result is negative, which means no accident has occurred.


EV_type: 

    There are two types of eligibility verification. And and Or.
    And type means the eligibility is verified if all eligibility verifiers say yes.
    Or type means the eligibility is verified if at least one eligibility verifiers says yes.
    0 for And
    1 for Or


EV_verified_count: a uint256 variable that count the number of verification received



Functions to include:

setInsurerCondition



@ dev addEligibilityVerifier

    addEligibilityVerifier allows the insured to add an eligibility verifier needed for this contract.
    If the eligibility verifier proposed is not added before, it will be added. Otherwise, it raises an error.
    The value of this eligiility verifier in eligibilityVerifierResult is changed to "ADDED"

@ dev addAccidentVerifier

    addAccidentVerifier allows the insured to add an accident verifier needed for this contract.
    If the accident verifier proposed is not added before, it will be added. Otherwise, it raises an error.
    The value of this accident verifier in eligibilityVerifierResult is changed to "ADDED"

verifyEligibility: (Done)

addAccidentVerifier:

verifyAccident: ()

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

    uint256 EV_type;
    uint256 EV_verified_count = 0;

    address[] public eligibilityVerifier;
    mapping(address => string) public eligibilityVerifierResult;

    address[] public accidentVerifier;
    mapping(address => string) public accidentVerifierResult;

    POLICY_STATE public policy_state = POLICY_STATE.OPEN_UNVERIFIED;

    constructor(uint256 _EV_type) {
        require(
            _EV_type == 1 || _EV_type == 0,
            "The type of eligibility verification can only be 1 or 0"
        );
        EV_type = _EV_type;
    }

    function addEligibilityVerifier(address _eligibilityVerifier)
        public
        onlyOwner
    {
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Eligibility Verifier at this stage!"
        );
        require(
            compareStrings(eligibilityVerifierResult[_eligibilityVerifier], ""),
            "This eligibility verifier has been added."
        );
        eligibilityVerifier.push(_eligibilityVerifier);
        eligibilityVerifierResult[_eligibilityVerifier] = "ADDED";
    }

    function addAccidentVerifier(address _accidentVerifier) public onlyOwner {
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Accident Verifier at this stage!"
        );
        require(
            compareStrings(accidentVerifierResult[_accidentVerifier], ""),
            "This accident verifier has been added."
        );
        accidentVerifier.push(_accidentVerifier);
        accidentVerifierResult[_accidentVerifier] = "ADDED";
    }

    function verifyEligibility(bool _verificationDummy) public {
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Eligibility Verification at this stage!"
        );
        require(
            compareStrings(eligibilityVerifierResult[msg.sender], "ADDED"),
            "You are either not in the eligibility verifier list or have submitted your verification."
        );
        if (_verificationDummy == true) {
            eligibilityVerifierResult[msg.sender] = "VERIFIED_POSITIVE";
        } else {
            eligibilityVerifierResult[msg.sender] = "VERIFIED_NEGATIVE";
        }
    }

    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
