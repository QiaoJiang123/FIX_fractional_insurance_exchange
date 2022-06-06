from scripts.help_scripts import get_account
from brownie import accounts, FIXInsured, exceptions
import sha3
import pandas as pd
import pytest

# use ganache-cli -a <number of accounts> to specify how many accounts needed for testing.
# This test will be on local chain.

policy_state_dict = {
    0: "OPEN_UNVERIFIED",
    1: "OPEN_VERIFIED",
    2: "LOTTERY",
    3: "ACTIVE_POLICY",
    4: "ACCIDENT_VERIFIED",
    5: "CLOSED",
}

EV_type = 1
AV_type = 1
potentialInsurerLimit = 6
insurerLimit = 3
fixedLoss = 567
premiumUpper = 12
premiumLower = 10

first_name = "James"
middle_name = ""
last_name = "Jiang"
confirmation_number = "ABC123"
flight = "NB1234"
flightDate = "2022-05-20"

information_combined = [
    first_name,
    middle_name,
    last_name,
    confirmation_number,
    flight,
    flightDate,
]
information_combined = ",".join([x.strip().lower() for x in information_combined])
print(information_combined)
k = sha3.keccak_256()
k.update(str.encode(information_combined))
hashedInsuredInfo = k.hexdigest()


def hash_keccak_256(string):
    k = sha3.keccak_256()
    k.update(str.encode(string))
    return k.hexdigest()


def deploy_fixinsured(
    EV_type,
    AV_type,
    potentialInsurerLimit,
    insurerLimit,
    fixedLoss,
    hashedInsuredInfo,
    flight,
    flightDate,
):
    """

    This function deploy FIXInsured.sol

    In this


    """

    # account = accounts[0]
    # print(f"The insurer {account} is going to deploy a FIXInsured contract.")
    fixinsured = FIXInsured.deploy(
        EV_type,
        AV_type,
        potentialInsurerLimit,
        insurerLimit,
        fixedLoss,
        hashedInsuredInfo,
        flight,
        flightDate,
        {"from": accounts[0]},
    )
    # print(f"The insurer {account} deployed the contract successfully.")
    return fixinsured


def test_deploy_insured():

    # Arrange
    # Act
    fixinsured_contract = deploy_fixinsured(
        EV_type,
        AV_type,
        potentialInsurerLimit,
        insurerLimit,
        fixedLoss,
        hashedInsuredInfo,
        flight,
        flightDate,
    )
    pass
    # Assert
    assert fixinsured_contract.EV_type() == EV_type
    assert fixinsured_contract.AV_type() == AV_type
    assert fixinsured_contract.potentialInsurerLimit() == potentialInsurerLimit
    assert fixinsured_contract.insurerLimit() == insurerLimit
    assert fixinsured_contract.hashedInsuredInfo() == hashedInsuredInfo
    assert fixinsured_contract.flight() == flight
    assert fixinsured_contract.flight() == flight
    assert (
        fixinsured_contract.policy_state() == 0
    )  # The status of this policy is OPEN_UNVERIFIED


def test_setPremiumRange():
    # Arrange
    fixinsured_contract = deploy_fixinsured(
        EV_type,
        AV_type,
        potentialInsurerLimit,
        insurerLimit,
        fixedLoss,
        hashedInsuredInfo,
        flight,
        flightDate,
    )
    fixinsured_contract.setPremiumRange(10, 12, {"from": accounts[0]})
    assert fixinsured_contract.premium_range()[0] == 10
    assert fixinsured_contract.premium_range()[1] == 12
    with pytest.raises(exceptions.VirtualMachineError):
        # "You have set premium range"
        fixinsured_contract.setPremiumRange(11, 12, {"from": accounts[0]})
    fixinsured_contract = deploy_fixinsured(
        EV_type,
        AV_type,
        potentialInsurerLimit,
        insurerLimit,
        fixedLoss,
        hashedInsuredInfo,
        flight,
        flightDate,
    )
    # fixinsured_contract.setPremiumRange(13, 12, {"from": accounts[0]})
    # fixinsured_contract.setPremiumRange(10, 12, {"from": accounts[1]})
    with pytest.raises(exceptions.VirtualMachineError) as exc_info:
        # Premium lower must not be larger than premium upper
        fixinsured_contract.setPremiumRange(13, 12, {"from": accounts[0]})
    with pytest.raises(exceptions.VirtualMachineError):
        # Caller must be the owner
        fixinsured_contract.setPremiumRange(10, 12, {"from": accounts[1]})
