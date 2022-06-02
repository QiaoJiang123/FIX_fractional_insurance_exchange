from asyncio import exceptions
from brownie import FIXInsured, accounts, config, network, exceptions
import pytest
from web3 import Web3


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

def test_deploy_insured():

    # Arrange



    # Act
    # Assert
