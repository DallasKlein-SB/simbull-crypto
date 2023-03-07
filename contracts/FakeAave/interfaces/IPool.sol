//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface IPool {
    function supply(address , uint256 , address , uint16 ) external; 
    function withdraw(address , uint256 , address )  external;
}