//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract SingleSeason is ERC1155, ERC1155Burnable {

    //---------------------------------------------------
    //--Variables----------------------------------------
    //---------------------------------------------------

    string public name;
    uint256 public season_id;
    address public league_contract;
    address public owner;
    uint256[] public token_ids;
    uint256 public payoutExchangeRate; //win payout to one ERC20 token
    uint256 public totalWinPayouts;
    enum SeasonStatus { ACTIVE, INACTIVE, COLLECTING }
    SeasonStatus public status;

    struct WinPayout {
        address teamOwner;
        uint256 amount;
    }


    //---------------------------------------------------
    //--Constructor--------------------------------------
    //---------------------------------------------------

    constructor(
        string memory _name,
        uint256 _season_id,
        address _league_contract,
        address _owner
    ) ERC1155("_a_uri_here_with_reference_to_each_game") {
        name = _name;
        season_id = _season_id;
        league_contract = _league_contract;
        owner = _owner;
        totalWinPayouts = 0;
        status = SeasonStatus.ACTIVE;
    }


    //---------------------------------------------------
    //--Modifiers----------------------------------------
    //---------------------------------------------------

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }


    //---------------------------------------------------
    //--Core Functions-----------------------------------
    //---------------------------------------------------

    function proposeWinPayout(WinPayout[] calldata _win_payouts) public onlyOwner returns (uint256) {
        require(status == SeasonStatus.ACTIVE, "Can't make new payouts for non-active seasons.");
        uint256 gameId = token_ids.length;
        token_ids.push(gameId);
        for (uint256 i = 0; i < _win_payouts.length; i++) {
            uint256 amount = _win_payouts[i].amount;
            //increment totalWinPayouts
            totalWinPayouts += amount;
            //mint tokens
            _mint(_win_payouts[i].teamOwner, gameId, amount, "");
        }
        return gameId;
    }

    function endSeason() public {
        require(msg.sender == league_contract, "Not league contract");
        if (status == SeasonStatus.ACTIVE) {
            status = SeasonStatus.COLLECTING;
        }
    }

}