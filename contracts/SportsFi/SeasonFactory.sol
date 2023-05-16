//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "./Season.sol";
import {ILeagueFactory} from "./Interfaces/ILeagueFactory.sol";
import {LeagueFactory} from "./LeagueFactory.sol";


contract SeasonFactory {

    //---------------------------------------------------
    //--Variables----------------------------------------
    //---------------------------------------------------

    address[] public seasons;                //all seasons ids
    address public league_factory;
    address immutable public owner;


    //---------------------------------------------------
    //--Constructor--------------------------------------
    //---------------------------------------------------

    constructor(address _league_factory) {
        league_factory = _league_factory;
        owner = msg.sender;
    }


    //---------------------------------------------------
    //--Core Functions-----------------------------------
    //---------------------------------------------------

    function createNewSeason(
        string calldata _name, //name of season
        address _owner       //league owner, comes from owner of the League
        
    )
        public returns (address)
    {
        //is this coming from a league contract? --> Don't think this is necessary because of it's just and empty season essentially then? Nothing bad can happen
        //require(ILeagueFactory(league_factory).checkLeagueById(_league_id, msg.sender), "Not a valid league");
        require(LeagueFactory(league_factory).checkLeagueByAddress(msg.sender), "Not a valid league");

        //create
        //create the season
        address _thisAddress = address(new SingleSeason(_name, msg.sender, _owner));
        //add the season id to the array
        seasons.push(_thisAddress);
        return _thisAddress;
    }

    //---------------------------------------------------
    //--SETTERS------------------------------------------
    //---------------------------------------------------

    //setLeague_factory - Sets the address of the League Factory
    function setLeague_factory(address _league_factory) public {
        require(owner == msg.sender, "Must be contract owner");
        league_factory = _league_factory;
    }

}