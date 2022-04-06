// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FIXToken is ERC20 {
    // 1 billion FIX tokens are issued

    constructor() public ERC20("FIX Token", "FIX") {
        _mint(msg.sender, 1000000000000000000000000000);
    }
}
