from scripts.help_scripts import get_account
from brownie import accounts, FIXInsured
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

irst_name = "James"
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


def test_deploy_insured():

    # Arrange

    # Act
    # Assert
    pass
