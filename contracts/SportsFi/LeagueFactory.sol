//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./League.sol";

contract LeagueFactory {

    //--Events-------------------------------------------
    event LeagueCreated(address indexed leagueAddress); //each new league gets an event emitted

    //--Variables----------------------------------------
    address[] public leagues;                   //All league contract addresses

    //--Constructor--------------------------------------
    constructor() {
    }


    //---------------------------------------------------
    //--Modifiers----------------------------------------
    //---------------------------------------------------


    //---------------------------------------------------
    //--Core Functions-----------------------------------
    //---------------------------------------------------

    //Create New League function
    function createNewLeague(
        string[2] calldata info_strings,  //name, symbol, description, uri
        uint256[3] calldata info_uint256, //number of teams, exchange rate, number of seasons
        address _treasury_token           //which erc20 token is used in the League Treasury
    ) public returns (address) {

        uint256 _league_id = leagues.length; //save the id 
        address _owner = msg.sender;            //owner of the League has edit priviledges 

        // 1. Create New League Contract with inputs
        address _leagueContract = address(new League(
            info_strings,
            info_uint256, 
            _league_id, 
            _owner, 
            _treasury_token
        ));

        leagues.push(_leagueContract);              //adds to the league directory map

        emit LeagueCreated(_leagueContract);                //send event

        return _leagueContract;
    }

    //---------------------------------------------------
    //--GETTERS------------------------------------------
    //---------------------------------------------------
    
    //Get League Address By ID
    /*function getLeagueAddressById(uint256 _id) public view returns(address) {
        return leagues[_id];
    }*/

    //Check to make sure it's a league
    function checkLeagueByAddress(address _league_address) public view returns(bool) {
        if (_league_address == 0x0000000000000000000000000000000000000000) {
            return false;
        }
        
        for(uint256 i = 0; i < leagues.length; i++){
            if (_league_address == leagues[i]) {
                return true;
            }
        }

        return false;
    }

}