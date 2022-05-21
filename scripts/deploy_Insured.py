from scripts.help_scripts import get_account
from brownie import accounts, FIXInsured
import sha3
import pandas as pd

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


def eligibility_verification(hash_result, fixedLoss, file_loc):
    k = sha3.keccak_256()
    df = pd.read_csv(file_loc)
    df.fillna("", inplace=True)
    df["hash_result"] = [
        hash_keccak_256(",".join([str(y).strip().lower() for y in x[0]]))
        for x in zip(
            df[
                [
                    "first_name",
                    "middle_name",
                    "last_name",
                    "confirmation_number",
                    "flight",
                    "flightDate",
                ]
            ].to_numpy()
        )
    ]
    if hash_result in df["hash_result"].tolist():
        ticket_price = df[df["hash_result"] == hash_result]["ticket_price"].tolist()
        return (
            sum([fixedLoss >= x * 0.99 and fixedLoss <= 1.01 for x in ticket_price])
            >= 1
        )
    else:
        return False


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
    print(
        "==================================== STEP 1: DEPLOY FIXINSURED ===================================="
    )
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
    print(
        "==================================== STEP 2: INSURED ADD PREMIUM RANGE, EV, AND AV ===================================="
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
    print(
        "==================================== STEP 3: ELIGIBILITY VERIFICATION ===================================="
    )
    fixinsured_contract.verifyEligibility(
        eligibility_verification(
            fixinsured_contract.hashedInsuredInfo(),
            fixinsured_contract.fixedLoss(),
            "mock_data/mock_flight_data.csv",
        ),
        {"from": accounts[1]},
    )
    fixinsured_contract.verifyEligibility(
        eligibility_verification(
            fixinsured_contract.hashedInsuredInfo(),
            fixinsured_contract.fixedLoss(),
            "mock_data/mock_flight_data_2.csv",
        ),
        {"from": accounts[2]},
    )
    print(
        f"* * *  The eligibility verification for each verifier is {fixinsured_contract.eligibilityVerifier(0)}, {fixinsured_contract.eligibilityVerifier(1)}."
    )
    print(
        f"* * *  The eligibility verification for each verifier is {fixinsured_contract.eligibilityVerifierResult(fixinsured_contract.eligibilityVerifier(0))}, {fixinsured_contract.eligibilityVerifierResult(fixinsured_contract.eligibilityVerifier(1))}."
    )
