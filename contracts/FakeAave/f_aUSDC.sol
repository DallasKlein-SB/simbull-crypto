//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract f_aUSDC is ERC20 {
    
    constructor() ERC20("Fake_aUSDC", "f_aUSDC") {

    }

    function mintTokens(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

    function burnTokens(address _from, uint256 _amount) public {
        _burn(_from, _amount);
    }
}