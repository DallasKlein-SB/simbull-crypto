//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FakeUSDC is ERC20 {
    
    constructor() ERC20("FakeUSDC", "fUSDC") {

    }

    function mintTokens(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }
}