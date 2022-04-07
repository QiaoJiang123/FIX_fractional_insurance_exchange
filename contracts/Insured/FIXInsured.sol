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

Functions to include:




*/

contract FIXInsurer {
    enum POLICY_STATE {
        OPEN_UNVERIFIED,
        OPEN_VERIFIED,
        AUCTION,
        ACTIVE_POLICY,
        ACCIDENT_VERIFIED,
        CLOSED
    }
}
