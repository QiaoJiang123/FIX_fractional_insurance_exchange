// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*

This smart contract contains the reserve for an insurer. Typically, the reserve would be less than the total contingent amount an insurer is possibly liable to.

*/
import "@openzeppelin/contracts/access/Ownable.sol";

contract Reserve is Ownable {
    function addPolicy(address _insurancePolicy) {}
}
