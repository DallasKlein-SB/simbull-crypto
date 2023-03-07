//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {f_aUSDC} from './f_aUSDC.sol';

contract FakeAave {

    address aToken;
    
     constructor(address _aToken) {
        aToken = _aToken;
    }

    function supply(address _token_contract, uint256 _amount, address _onBehalfOf, uint16 _promo) public {
        IERC20(_token_contract).transferFrom(msg.sender, address(this), _amount);
        f_aUSDC(aToken).mintTokens(_onBehalfOf, _amount);
    }

    function withdraw(address _token_contract, uint256 _amount, address _to) public {
        IERC20(_token_contract).transfer(_to, _amount);
        f_aUSDC(aToken).burnTokens(msg.sender, _amount);
    }
}