//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./League.sol";

contract LeagueFactory {

    //--Events-------------------------------------------
    event LeagueCreated(address leagueAddress); //each new league gets an event emitted

    //--Variables----------------------------------------
    uint256[] public league_ids;                   //All league contract addresses //@audit an address array is enough
    mapping(uint256 => address) public leagues;    //Mapping league ids to their contract address //@audit cf supra
    address public owner;                          //creator of the league factory //@audit rm unused var

    //--Constructor--------------------------------------
    constructor() {
        owner = msg.sender; //saves the creator //@audit unused
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

        uint256 _league_id = league_ids.length; //save the id 
        address _owner = msg.sender;            //owner of the League has edit priviledges 

        // 1. Create New League Contract with inputs
        League _leagueContract = new League(
            info_strings,
            info_uint256, 
            _league_id, 
            _owner, 
            _treasury_token
        );

        address _thisAddress = address(_leagueContract); //saves address on new league //@audit rm unneeded var (cast _leagueContract to address instead)
        leagues[_league_id] = _thisAddress;              //adds to the league directory map
        league_ids.push(_league_id);                     //save the id in the array

        emit LeagueCreated(_thisAddress);                //send event

        return _thisAddress;
    }

    //---------------------------------------------------
    //--GETTERS------------------------------------------
    //---------------------------------------------------
     //@audit use OZ address set (.at() and .contains()) - https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol
    //Get League Address By ID
    /*function getLeagueAddressById(uint256 _id) public view returns(address) {
        return leagues[_id];
    }*/

    //Check to make sure it's a league
    /*function checkLeagueById(uint256 _league_id, address _league_address) public view returns(bool) {
        address id_address = leagues[_league_id];
        if (id_address != 0x0000000000000000000000000000000000000000 && id_address == _league_address) {
            return true;
        } else return false;
    }*/

}