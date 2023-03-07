//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface ISeasonFactory {
    function createNewSeason(string calldata, address, uint256) external returns (address); 
}