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

@para hashedInsuredInfo

    This parameter is a keccak256 hashed result of first name, middle name, last name of the insured, confirmation number, flight, flight date.
    All elements are in string and lowercase, joined with comma.

@para flight

@para date



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

// Add a time constraint on the smart contract. If no action is ever done after the flight date. All money if ever transferred to this smart contract will be sent back.

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BokkyPooBahsDateTimeLibrary.sol";

contract FIXInsured is Ownable {
    enum POLICY_STATE {
        OPEN_UNVERIFIED,
        OPEN_VERIFIED,
        LOTTERY,
        ACTIVE_POLICY,
        ACCIDENT_VERIFIED,
        CLOSED
    }
    enum VERIFICATION_RESULT {
        NOTADDED,
        ADDED,
        VERIFIED_NEGATIVE,
        VERIFIED_POSITIVE
    }

    string public hashedInsuredInfo;
    string public flight;
    string public flightDate;

    struct premiumRange {
        uint256 premiumLower;
        uint256 premiumUpper;
    }

    premiumRange public premium_range;

    uint256 public fixedLoss;

    uint256 public EV_type;
    uint256 EV_verified_count = 0;
    bool public EV_final_result;

    uint256 public AV_type;
    uint256 AV_verified_count = 0;
    bool public AV_final_result;

    uint256 public potentialInsurerLimit;
    uint256 public insurerLimit;
    mapping(address => uint256[2]) public potentialInsurerDepositPremium;

    address[] public eligibilityVerifier;
    mapping(address => VERIFICATION_RESULT) public eligibilityVerifierResult;

    address[] public accidentVerifier;
    mapping(address => VERIFICATION_RESULT) public accidentVerifierResult;

    address[] public potentialInsurer;
    address[] public insurerSelected;
    uint256 public insuredDeposit;

    POLICY_STATE public policy_state = POLICY_STATE.OPEN_UNVERIFIED;

    uint256 public returnFundTimeStamp;

    constructor(
        uint256 _EV_type,
        uint256 _AV_type,
        uint256 _potentialInsurerLimit,
        uint256 _insurerLimit,
        uint256 _fixedLoss,
        string memory _hashedInsuredInfo,
        string memory _flight,
        string memory _flightDate
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
        hashedInsuredInfo = _hashedInsuredInfo;
        flight = _flight;
        flightDate = _flightDate;
        returnFundTimeStamp = getTimeStamp(flightDate);
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
        require(
            (premium_range.premiumLower == 0),
            "You have set premium range"
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
            eligibilityVerifierResult[_eligibilityVerifier] ==
                VERIFICATION_RESULT.NOTADDED,
            "This eligibility verifier has been added."
        );
        eligibilityVerifier.push(_eligibilityVerifier);
        eligibilityVerifierResult[_eligibilityVerifier] = VERIFICATION_RESULT
            .ADDED;
    }

    function addAccidentVerifier(address _accidentVerifier) public onlyOwner {
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Accident Verifier at this stage!"
        );
        require(
            accidentVerifierResult[_accidentVerifier] ==
                VERIFICATION_RESULT.NOTADDED,
            "This accident verifier has been added."
        );
        accidentVerifier.push(_accidentVerifier);
        accidentVerifierResult[_accidentVerifier] = VERIFICATION_RESULT.ADDED;
    }

    function verifyEligibility(bool _verificationDummy) public {
        // Eligibility verification is only allowed when the policy is not stated and no verification has been made.
        // That is when policy_state is OPEN_UNVERIFIED
        require(
            policy_state == POLICY_STATE.OPEN_UNVERIFIED,
            "Can't change Eligibility Verification at this stage!"
        );
        require(
            eligibilityVerifierResult[msg.sender] == VERIFICATION_RESULT.ADDED,
            "You are either not in the eligibility verifier list or have submitted your verification."
        );
        if (_verificationDummy == true) {
            eligibilityVerifierResult[msg.sender] = VERIFICATION_RESULT
                .VERIFIED_POSITIVE;
        } else {
            eligibilityVerifierResult[msg.sender] = VERIFICATION_RESULT
                .VERIFIED_NEGATIVE;
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
                    eligibilityVerifierResult[eligibilityVerifier[i]] ==
                    VERIFICATION_RESULT.VERIFIED_NEGATIVE
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
                    eligibilityVerifierResult[eligibilityVerifier[i]] ==
                    VERIFICATION_RESULT.VERIFIED_POSITIVE
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
            premium_range.premiumLower > 0,
            "The range of premium is not set yet. Wait for the insured to set the range."
        );
        require(
            (policy_state == POLICY_STATE.OPEN_VERIFIED) ||
                (policy_state == POLICY_STATE.LOTTERY),
            "You cannot add a potential insurer for the lottery later"
        );
        require(
            (potentialInsurerDepositPremium[msg.sender][0] == 0) &&
                (potentialInsurer.length < potentialInsurerLimit),
            "You are in the list for the aution or no space is available."
        );
        require(
            (_premiumProposed >= premium_range.premiumLower / insurerLimit) &&
                (_premiumProposed <= premium_range.premiumUpper / insurerLimit),
            "The proposed premium does not fall into the range. Please propose a new one!"
        );
        require(msg.value == fixedLoss / insurerLimit); // The deposit must be exactly the same amount as fixedLossPerInsurer.
        potentialInsurer.push(msg.sender);
        potentialInsurerDepositPremium[msg.sender][0] = msg.value;
        potentialInsurerDepositPremium[msg.sender][1] = _premiumProposed;

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
            msg.value == premium_range.premiumUpper,
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
            insurerSelected.push(
                potentialInsurerTemp[randomNumber % potentialInsurerTemp.length]
            );

            delete potentialInsurerTemp[
                randomNumber % potentialInsurerTemp.length
            ];
            // potentialInsurerTemp only has insurers not being selected.
        }
        // Pay back to un-selected insurers
        for (uint256 i = 0; i < potentialInsurerTemp.length; i++) {
            // This loop pay back the deposit to insurer
            payable(potentialInsurerTemp[i]).transfer(
                potentialInsurerDepositPremium[potentialInsurerTemp[i]][0]
            );
            delete potentialInsurerDepositPremium[potentialInsurerTemp[i]];
        }
        for (uint256 i = 0; i < insurerSelected.length; i++) {
            // This loop calculted how many premium insured should deposit based on selected insurers
            insuredDeposit =
                insuredDeposit +
                potentialInsurerDepositPremium[insurerSelected[i]][1];
        }
        payable(msg.sender).transfer(
            premium_range.premiumUpper - insuredDeposit
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
            accidentVerifierResult[msg.sender] == VERIFICATION_RESULT.ADDED,
            "You are either not in the accident verifier list or have submitted your verification."
        );
        if (_verificationDummy == true) {
            accidentVerifierResult[msg.sender] = VERIFICATION_RESULT
                .VERIFIED_POSITIVE;
        } else {
            accidentVerifierResult[msg.sender] = VERIFICATION_RESULT
                .VERIFIED_NEGATIVE;
        }
        AV_verified_count += 1;
    }

    function getAccidentFinalResult() public payable onlyOwner {
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
                    accidentVerifierResult[accidentVerifier[i]] ==
                    VERIFICATION_RESULT.VERIFIED_NEGATIVE
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
                    accidentVerifierResult[accidentVerifier[i]] ==
                    VERIFICATION_RESULT.VERIFIED_POSITIVE
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
                potentialInsurerDepositPremium[insurerSelected[i]][1]
            );
        }
        if (AV_final_result == true) {
            payable(msg.sender).transfer(fixedLoss);
        } else {
            for (uint256 i = 0; i < insurerSelected.length; i++) {
                payable(insurerSelected[i]).transfer(
                    potentialInsurerDepositPremium[insurerSelected[i]][0]
                );
            }
        }
    }

    function getSlice(
        uint256 begin,
        uint256 end,
        string memory text
    ) public pure returns (string memory) {
        bytes memory a = new bytes(end - begin + 1);
        for (uint256 i = 0; i <= end - begin; i++) {
            a[i] = bytes(text)[i + begin - 1];
        }
        return string(a);
    }

    function stringToInt(string memory numString)
        public
        pure
        returns (uint256)
    {
        uint256 val = 0;
        bytes memory stringBytes = bytes(numString);
        for (uint256 i = 0; i < stringBytes.length; i++) {
            uint256 exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint256 jval = uval - uint256(0x30);

            val += (uint256(jval) * (10**(exp - 1)));
        }
        return val;
    }

    function getTimeStamp(string memory _flightDate) public returns (uint256) {
        return
            BokkyPooBahsDateTimeLibrary.timestampFromDate(
                stringToInt(getSlice(1, 4, _flightDate)),
                stringToInt(getSlice(6, 7, _flightDate)),
                stringToInt(getSlice(9, 10, _flightDate))
            ) + BokkyPooBahsDateTimeLibrary.SECONDS_PER_DAY;
    }

    function overTimeRefund() public {
        // If the policy is not closed until one day after flight date. All money can be returned to each participant.
        require(
            returnFundTimeStamp <= block.timestamp,
            "Refund is not allowed. Please wait until one day after the flight date.s"
        );
        require(policy_state != POLICY_STATE.CLOSED, "This policy is closed");
        for (uint256 i = 0; i < insurerSelected.length; i++) {
            // pay back deposit
            payable(insurerSelected[i]).transfer(
                potentialInsurerDepositPremium[insurerSelected[i]][0]
            );
            // pay back premium
            payable(owner()).transfer(
                potentialInsurerDepositPremium[insurerSelected[i]][1]
            );
        }
    }
}
