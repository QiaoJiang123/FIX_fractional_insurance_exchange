// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// initial_supply should be 1000000000000000000000000000

contract FIXToken is ERC20 {
    // 1 billion FIX tokens are issued

    constructor(uint256 initial_supply) public ERC20("FIX Token", "FIX") {
        _mint(msg.sender, initial_supply);
    }
}
