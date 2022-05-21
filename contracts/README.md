# FIXInsured.sol

## Version 1: Flight Delay Insurance

FIXInsured.sol is the main contract in FIX. It is launched and owned by prospective insured at the beginning.

When a person wants to buy an insurance from FIX, it is necessary to deploy a smart contract FIXInsured.sol for request. The prospective insured (as insured hereafter) needs to specify a few things when make such request:
1. EV_type: how eligibility is verified. Need all verifiers to say yes or at least one.
2. AV_type: how accident is verified. Need all verifiers to say yes or at least one.
3. potentialInsurerLimit: the maximum number of participants to compete for being an insurer.
4. insurerLimit: the number of insurers needed.
5. fixedLoss: total amount of loss when accident occurs.
6. hashedInsuredInfo: hash result of Personal Identifiable Information (PII) of the insured for eligibility verification
7. flight: flight number
8. flightDate: flight date

The last two elements are used for easy searching when verifying eligibility and flight delay.
