//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface ILeagueFactory {
    function leagues(uint256) external returns (address);
    function checkLeagueByAddress(uint256, address) external returns (bool);
}