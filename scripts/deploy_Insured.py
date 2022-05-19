from scripts.help_scripts import get_account
from brownie import accounts, FIXInsured
import sha3

# use ganache-cli -a <number of accounts> to specify how many accounts needed for testing.
# This test will be on local chain.

EV_type = 1
AV_type = 1
potentialInsurerLimit = 6
insurerLimit = 3
fixedLoss = 300
premiumUpper = 12
premiumLower = 10

# Flight information for eligibility verification
# Insured need to provide three information:
# 1. flight
# 2. flight date
# 3. keccak 256 hash result of information include first name, middle name, last name of the insured, confirmation number, flight, flight date.
#    All elements are in string and lowercase, joined with comma.
#
# Eligibility verifier will use the keccak 256 hash result provided by the insured and compare it to its own database using the same hash. If

information_combined = "Hello"

k = sha3.keccak_256()
k.update(str.encode(information_combined))

hashedInsuredInfo = k.hexdigest()
flight = "ABC123"
flightDate = "2022-05-12"


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

    account = accounts[0]
    print(f"The insurer {account} is going to deploy a FIXInsured contract.")
    fixinsured = FIXInsured.deploy(
        EV_type,
        AV_type,
        potentialInsurerLimit,
        insurerLimit,
        fixedLoss,
        hashedInsuredInfo,
        flight,
        flightDate,
        {"from": account},
    )
    print(f"The insurer {account} deployed the contract successfully.")
    return fixinsured


def main():
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

    print(
        f"* * *  The type of eligibility verifier is {fixinsured_contract.EV_type()}.\n",
        f"* * *  The type of accident verifier is {fixinsured_contract.AV_type()}.\n",
        f"* * *  The potential insurer limit is {fixinsured_contract.potentialInsurerLimit()}.\n",
        f"* * *  The insurer limit is {fixinsured_contract.insurerLimit()}.\n",
        f"* * *  The fixed loss an insurer may be liable to is {fixinsured_contract.fixedLoss()}.",
    )
    print("* * *  Add the range of premium.")
    fixinsured_contract.setPremiumRange(
        premiumLower, premiumUpper, {"from": accounts[0]}
    )
    print(
        f"* * * The lower limit of premium is {fixinsured_contract.premium_range()[0]} and upper limit of premium is {fixinsured_contract.premium_range()[1]}"
    )
    print("* * * Add eligibility verifier.")
    print(accounts[1])
    print(accounts[2])
    fixinsured_contract.addEligibilityVerifier(accounts[1], {"from": accounts[0]})
    fixinsured_contract.addEligibilityVerifier(accounts[2], {"from": accounts[0]})

    print(
        f"* * *  {fixinsured_contract.eligibilityVerifier(0)}, {fixinsured_contract.eligibilityVerifier(1)} have been added as eligibility verifiers"
    )
    print("* * * Add accident verifier.")
    print(accounts[3])
    print(accounts[4])
    fixinsured_contract.addAccidentVerifier(accounts[3], {"from": accounts[0]})
    fixinsured_contract.addAccidentVerifier(accounts[4], {"from": accounts[0]})
    print(
        f"* * *  {fixinsured_contract.accidentVerifier(0)}, {fixinsured_contract.accidentVerifier(1)} have been added as eligibility verifiers"
    )
    # Need to convert it to data based verification.
    fixinsured_contract.verifyEligibility(True, {"from": accounts[1]})
    fixinsured_contract.verifyEligibility(True, {"from": accounts[2]})

    # for i in range(20):
    #    print(accounts[i])
