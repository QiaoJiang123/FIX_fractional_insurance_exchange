// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*

@author: Qiao Jiang
@notice A smart contract to initiate an insurance policy by an insured.

@para enum POLICY_STATE 

    POLICY_STATE has 6 states:
        OPEN_UNVERIFIED: An insured deployed a smart contract to request an insurance policy but the eligibility is not verified
        OPEN_VERIFIED: The eligibility is verified. Open to accept insurers.
        LOTTERY: The number of insurers meet a certain criterion. Ready to pick insurers.
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


@para EV_type

    There are two types of eligibility verification. And and Or.
    And type means the eligibility is verified if all eligibility verifiers say yes.
    Or type means the eligibility is verified if at least one eligibility verifiers says yes.
    1 for And
    2 for Or

@para EV_verified_count

    a uint256 variable that count the number of verification received

@para EV_final_result

    A bool variable that returns the final result of eligibility verification when called by the insured. 
    Also, the insured must wait until all eligibility verifier submit their verification.

@para premiumRange

    A range of premium proposed by the insured. The lower bound may be subject to regulation to mitigate insolvency risk.
    Upper bound may be given by the insured.

@para fixedLoss

    Fixed loss is the loss amount proposed by the insured. This applies to trip delay insurance where the insured knows how much he/she has paid for
    the ticket. This amount will also be verified by EV.


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

@ dev verifyEligibility

    verifyEligibility is called by eligibility verifiers. It is called after verifiers are added.

@dev getEligibilityFinalResult

    This function determines whether the insured is eligible to get insurance or not.
    It is called by the insured. The policy' state must be OPEN_UNVERIFIED.
    If the final result, EV_final_result is true, the request will move to the next stage, OPEN_VERIFIED.
    Otherwise, the request will be moved to the last stage, CLOSED. No further action is allowed in this smart contract.

@dev addPotentialInsurer

    An insurer can add himself or herself to this smart contract for later lottery.

@dev verifyAccident

    verifyAccident is called by accident verifiers. It is called after verifiers are added.

@dev insurerSelectionLottery

    start the lottery to select insurers.

@dev addPotentialInsurers

    Allow insurers to add themselves for the lottery later.

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
        LOTTERY,
        ACTIVE_POLICY,
        ACCIDENT_VERIFIED,
        CLOSED
    }

    struct premiumRange {
        uint256 premiumLower;
        uint256 premiumUpper;
    }

    premiumRange premium_range;

    uint256 fixedLoss;
    uint256 fixedLossPerInsurer;

    uint256 EV_type;
    uint256 EV_verified_count = 0;
    bool EV_final_result;

    uint256 AV_type;
    uint256 AV_verified_count = 0;
    bool AV_final_result;

    uint256 public potentialInsurerLimit;
    uint256 public insurerLimit;
    mapping(address => uint256) public potentialInsurerDeposit;
    mapping(address => uint256) public potentialInsurerPremium;

    address[] public eligibilityVerifier;
    mapping(address => string) public eligibilityVerifierResult;

    address[] public potentialInsurer;
    address[] public insurerSelected;
    mapping(address => uint256) public insurerSelectedDeposit;
    mapping(address => uint256) public insurerSelectedPremium;
    uint256 public insuredDeposit;

    address[] public accidentVerifier;
    mapping(address => string) public accidentVerifierResult;

    POLICY_STATE public policy_state = POLICY_STATE.OPEN_UNVERIFIED;

    constructor(
        uint256 _EV_type,
        uint256 _AV_type,
        uint256 _potentialInsurerLimit,
        uint256 _insurerLimit,
        uint256 _fixedLoss
    ) {
        require(
            _EV_type == 1 || _EV_type == 2,
            "The type of eligibility verification can only be 1 or 2"
        );
        require(
            _AV_type == 1 || _AV_type == 2,
            "The type of accident verification can only be 1 or 2"
        );

        EV_type = _EV_type;
        AV_type = _AV_type;
        potentialInsurerLimit = _potentialInsurerLimit;
        insurerLimit = _insurerLimit;
        fixedLoss = _fixedLoss;
        fixedLossPerInsurer = _fixedLoss / _insurerLimit;
    }

    function setPremiumRange(uint256 _premiumLower, uint256 _premiumUpper)
        public
        onlyOwner
    {
        require(
            (policy_state == POLICY_STATE.OPEN_UNVERIFIED) ||
                (policy_state == POLICY_STATE.OPEN_VERIFIED),
            "You cannot set premium range at this moment!"
        );
        premium_range.premiumLower = _premiumLower;
        premium_range.premiumUpper = _premiumUpper;
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
        // Eligibility verification is only allowed when the policy is not stated and no verification has been made.
        // That is when policy_state is OPEN_UNVERIFIED
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
        EV_verified_count += 1;
    }

    function getEligibilityFinalResult() public onlyOwner {
        // EV_type == 1 means all verification must be positive (And)
        // EV_type == 2 means at least one verification should be positive (Or)
        require(
            (EV_verified_count == eligibilityVerifier.length) &&
                (policy_state == POLICY_STATE.OPEN_UNVERIFIED),
            "Wait until all eligibility verifiers submit their verification"
        );
        bool EV_result;
        if (EV_type == 1) {
            EV_result = true;
            // And
            for (uint256 i = 0; i < eligibilityVerifier.length; i++) {
                if (
                    compareStrings(
                        eligibilityVerifierResult[eligibilityVerifier[i]],
                        "VERIFIED_NEGATIVE"
                    ) == true
                ) {
                    EV_result = false;
                    break;
                }
            }
        } else {
            EV_result = false;
            // Or
            for (uint256 i = 0; i < eligibilityVerifier.length; i++) {
                if (
                    compareStrings(
                        eligibilityVerifierResult[eligibilityVerifier[i]],
                        "VERIFIED_POSITIVE"
                    ) == true
                ) {
                    EV_result = true;
                    break;
                }
            }
        }
        EV_final_result = EV_result;
        if (EV_final_result == true) {
            policy_state = POLICY_STATE.OPEN_VERIFIED;
        } else {
            policy_state = POLICY_STATE.CLOSED;
        }
    }

    function addPotentialInsurers(uint256 _premiumProposed) public payable {
        require(
            (policy_state == POLICY_STATE.OPEN_VERIFIED) ||
                (policy_state == POLICY_STATE.LOTTERY),
            "You cannot add a potential insurer for the lottery later"
        );
        require(
            (potentialInsurerDeposit[msg.sender] == 0) &&
                (potentialInsurer.length < potentialInsurerLimit),
            "You are in the list for the aution or no space is available."
        );
        require(
            (_premiumProposed >= premium_range.premiumLower) &&
                (_premiumProposed <= premium_range.premiumUpper),
            "The proposed premium does not fall into the range. Please propose a new one!"
        );
        require(msg.value == fixedLossPerInsurer); // The deposit must be exactly the same amount as fixedLossPerInsurer.
        potentialInsurer.push(msg.sender);
        potentialInsurerDeposit[msg.sender] = msg.value;
        potentialInsurerPremium[msg.sender] = _premiumProposed;

        if (potentialInsurer.length >= insurerLimit) {
            // Once there are enough potential insurers, the lottery can begin.
            // It is not necessary to wait until potential insurers hit the limit.
            policy_state = POLICY_STATE.LOTTERY;
        }
    }

    function insurerSelectionLottery() public payable onlyOwner {
        // Insured needs to deposit tentative premium first.
        // The amount of tentative premium equals the number of insurers multiplied by the upper limit of premium.
        // After selection lottery is drawn, the actual premium will be calculated.
        // The excess of premium, tentative premium minus actual premium, will be returned to the insured.
        require(
            msg.value == insurerLimit * premium_range.premiumUpper,
            "Insured should deposit enough money for insurer selection lottery."
        );
        address[] memory potentialInsurerTemp = potentialInsurer;
        for (uint256 i = 0; i < insurerLimit; i++) {
            uint256 randomNumber = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        msg.sender,
                        i,
                        block.difficulty
                    )
                )
            );
            insurerSelected[i] = potentialInsurerTemp[
                randomNumber % potentialInsurerTemp.length
            ];

            insurerSelectedDeposit[
                insurerSelected[i]
            ] = potentialInsurerDeposit[insurerSelected[i]];
            potentialInsurerDeposit[insurerSelected[i]] = 0;

            insurerSelectedPremium[
                insurerSelected[i]
            ] = potentialInsurerPremium[insurerSelected[i]];

            delete potentialInsurerTemp[
                randomNumber % potentialInsurerTemp.length
            ];
        }
        // Pay back to un-selected insurers
        for (uint256 i = 0; i < insurerSelected.length; i++) {
            payable(potentialInsurer[i]).transfer(
                potentialInsurerDeposit[potentialInsurer[i]]
            );
        }
        for (uint256 i = 0; i < potentialInsurer.length; i++) {
            insuredDeposit =
                insuredDeposit +
                insurerSelectedPremium[insurerSelected[i]];
        }
        msg.sender.transfer(
            insurerLimit * premiumRange.premiumUpper - insuredDeposit
        );
        policy_state = POLICY_STATE.ACTIVE_POLICY;
    }

    function verifyAccident(bool _verificationDummy) public {
        // Accident verification is only allowed when the policy is active. That is when policy_state is ACTIVE_POLICY
        require(
            policy_state == POLICY_STATE.ACTIVE_POLICY,
            "Can't change Accident Verification at this stage!"
        );
        require(
            compareStrings(accidentVerifierResult[msg.sender], "ADDED"),
            "You are either not in the accident verifier list or have submitted your verification."
        );
        if (_verificationDummy == true) {
            accidentVerifierResult[msg.sender] = "VERIFIED_POSITIVE";
        } else {
            accidentVerifierResult[msg.sender] = "VERIFIED_NEGATIVE";
        }
        AV_verified_count += 1;
    }

    function getAccidentFinalResult() public onlyOwner {
        // AV_type == 1 means all verification must be positive (And)
        // AV_type == 2 means at least one verification should be positive (Or)
        require(
            (AV_verified_count == accidentVerifier.length) &&
                (policy_state == POLICY_STATE.ACTIVE_POLICY),
            "Wait until all eligibility verifiers submit their verification or the policy is active."
        );
        bool AV_result;
        if (AV_type == 1) {
            AV_result = true;
            // And
            for (uint256 i = 0; i < accidentVerifier.length; i++) {
                if (
                    compareStrings(
                        accidentVerifierResult[accidentVerifier[i]],
                        "VERIFIED_NEGATIVE"
                    ) == true
                ) {
                    AV_result = false;
                    break;
                }
            }
        } else {
            AV_result = false;
            // Or
            for (uint256 i = 0; i < accidentVerifier.length; i++) {
                if (
                    compareStrings(
                        accidentVerifierResult[accidentVerifier[i]],
                        "VERIFIED_POSITIVE"
                    ) == true
                ) {
                    AV_result = true;
                    break;
                }
            }
        }
        AV_final_result = AV_result;
        policy_state = POLICY_STATE.CLOSED;
        for (uint256 i = 0; i < insurerSelected.length; i++) {
            payable(insurerSelected[i]).transfer(
                insurerSelectedPremium[insurerSelected[i]]
            );
        }
        if (AV_final_result == true) {
            msg.sender.transfer(fixedLoss);
        } else {
            for (uint256 i = 0; i < insurerSelected.length; i++) {
                payable(insurerSelected[i]).transfer(
                    insurerSelectedDeposit[insurerSelected[i]]
                );
            }
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
