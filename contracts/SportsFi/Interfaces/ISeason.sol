//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface ISeason {
    function endSeason() external; 
    function burnBatch(address, uint256[] calldata, uint256[] calldata) external;
}