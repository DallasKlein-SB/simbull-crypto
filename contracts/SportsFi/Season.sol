//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract SingleSeason is ERC1155, ERC1155Burnable {

    //---------------------------------------------------
    //--Variables----------------------------------------
    //---------------------------------------------------

    string public name;  //@audit immutable
    uint256 public season_id;  //@audit immutable
    address public league_contract; //@audit immutable
    address public owner; //@audit OZ ownable
    uint256[] public token_ids; //@audit use an uint256 counter instead
    uint256 public payoutExchangeRate; //win payout to one ERC20 token  //@audit unused
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
    ) ERC1155("_a_uri_here_with_reference_to_each_game") {  //@audit uri?
        name = _name;
        season_id = _season_id;
        league_contract = _league_contract;
        owner = _owner; //@audit OZ ownable (ie transferOwnership in the constructor)
        totalWinPayouts = 0;  //@audit do not init default values
        status = SeasonStatus.ACTIVE; //@audit do not init default values
    }


    //---------------------------------------------------
    //--Modifiers----------------------------------------
    //---------------------------------------------------

    modifier onlyOwner() {  //@audit OZ ownable
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside //@audit rm unneeded comment
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }


    //---------------------------------------------------
    //--Core Functions-----------------------------------
    //---------------------------------------------------

    function proposeWinPayout(WinPayout[] calldata _win_payouts) public onlyOwner returns (uint256) {
        require(status == SeasonStatus.ACTIVE, "Can't make new payouts for non-active seasons."); //@audit error string < 32 bytes
        uint256 gameId = token_ids.length; //@audit use gameId as global variable and increment it accordingly
        token_ids.push(gameId);
        for (uint256 i = 0; i < _win_payouts.length; i++) {  //@audit push length into stack before iterating (uint256 _numberOfWinners = _win_payouts.length)
            uint256 amount = _win_payouts[i].amount;
            //increment totalWinPayouts
            totalWinPayouts += amount;
            //mint tokens
            _mint(_win_payouts[i].teamOwner, gameId, amount, ""); //@audit reentrancy (onERC1155Received)
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