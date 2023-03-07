//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "./Season.sol";
import {ILeagueFactory} from "./Interfaces/ILeagueFactory.sol";
import {LeagueFactory} from "./LeagueFactory.sol";


contract SeasonFactory {

    //---------------------------------------------------
    //--Variables----------------------------------------
    //---------------------------------------------------

    uint256[] private season_ids;                //all seasons ids
    mapping(uint256 => address) private seasons; //mapping ids to addresses
    address private league_factory;
    address private owner;


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
        address _owner,        //league owner, comes from owner of the League
        uint256 _league_id     //league id with ownership
    )
        public returns (address)
    {
        //is this coming from a league contract?
        //require(ILeagueFactory(league_factory).checkLeagueById(_league_id, msg.sender), "Not a valid league");
        require(LeagueFactory(league_factory).leagues(_league_id) == msg.sender, "Not a valid league");

        //create
        //get new season id by incrementing season_ids
        uint256 _season_id = season_ids.length;
        //create the season
        SingleSeason _seasonContract = new SingleSeason(_name, _season_id, msg.sender, _owner);
        //save the seasons address in the seasons array
        address _thisAddress = address(_seasonContract);
        seasons[_season_id] = _thisAddress;
        //add the season id to the array
        season_ids.push(_season_id);
        return _thisAddress;
    }


    //---------------------------------------------------
    //--GETTERS------------------------------------------
    //---------------------------------------------------

    function getAmountOfSeasons() public view returns (uint256) {
        return season_ids.length;
    }

    function getSeasonAddress(uint256 _season_id) public view returns (address) {
        return seasons[_season_id];
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