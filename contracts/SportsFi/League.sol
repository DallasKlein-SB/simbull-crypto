//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ISeasonFactory} from "./Interfaces/ISeasonFactory.sol";
import {ISeason} from "./Interfaces/ISeason.sol";
import {SingleSeason} from "./Season.sol";
import {IPool} from '../FakeAave/interfaces/IPool.sol';

contract League is ERC1155 {

    //---------------------------------------------------
    //--Events-------------------------------------------
    //---------------------------------------------------

    event SeasonCreated(address indexed seasonAddress);

    //---------------------------------------------------
    //--Variables----------------------------------------
    //---------------------------------------------------

    //descriptive variables
    string    public name;
    string    public symbol;
    uint256   immutable public league_id;
    uint256   public teams; //array of teams
    address   immutable public owner; //who created this league, not League Factory
    //variables
    uint256   public totalDeposited; //all time total deposited
    uint256   public totalWithdrawn; //all time total withdrawn
    uint256   public totalCurrentSupply; //current token sets outstanding
    uint256   immutable public exchangeRate; //amount of erc20 needed to mint/burn a single token set
    uint256   immutable public num_of_seasons; //how many seasons can be created from the SeasonFactory
    uint256   public mintFee; //fee put in win payout pool when minitng // mintFee / 10000 --> mintFee of 100 will be a fee of 1%, mintFee of 10 will be a fee of 0.1% 
    uint256   public burnFee; //fee put in win payout pool when burning // burnFee / 10000 --> burnFee of 100 will be a fee of 1%, burnFee of 10 will be a fee of 0.1% 
    bool      public canBurn = true; //ability to burn token sets for the exchangeRate of erc20 tokens
    //contract addresses
    address   immutable public erc20_address; //address of token used for the League Treasury
    address   public pool_proxy_polygon = 0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B; //main aave pool address
    address   public aToken_erc20_address; //address of atoken used for the League Treasury
    //season win payout info
    enum SeasonStatus { ACTIVE, INACTIVE, COLLECTING }
    address[] seasons;
    mapping(address => SeasonStatus) public seasonStatus;
    mapping(address => uint) public winPayoutAmt;


    //---------------------------------------------------
    //--Constructor--------------------------------------
    //---------------------------------------------------
    constructor(
        string[2] memory info_strings, //[name, symbol]
        uint256[3] memory info_uint256, //[numOfTeams, exchangeRate, num_of_seasons]
        uint256 _league_id, //league_id
        address _owner,
        address _treasury_token //erc20 token used to mint/burn
    ) ERC1155("") {
        //descriptive
        name = info_strings[0];
        symbol = info_strings[1];
        //description = info_strings[2];
        league_id = _league_id;
        teams = info_uint256[0];
        owner = _owner;
        //variables
        exchangeRate = info_uint256[1];
        num_of_seasons = info_uint256[2];
        //addresses
        erc20_address = _treasury_token;
    }

    //---------------------------------------------------
    //--Modifiers----------------------------------------
    //---------------------------------------------------

    modifier isLeagueOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    //---------------------------------------------------
    //--Core Functions-----------------------------------
    //---------------------------------------------------

    //Mint Team Tokens
    function mintBatch(uint256 _amount) public returns(bool) {

        //--DIRECTIONS

        // 1. Check Balance of ERC20 is greater than amount used to mint
        // 2. Check that this smart contract has enough allowance of the minters ERC20 to transfer
        // 3. Transfer the Amount of ERC20 tokens from the minter to the contract
        // 4. Create an Amount Array needed for the _mintBatch function using getExchangeRate()
        // 5. Update Variables - totalDeposited, totalCurrentlySupply
        // 6. Send ERC20 tokens to Aave
        // 7. Mint Batch
        // 8. Return true to indicate successful mint

        //--IMPLEMENTATION
        // 1. Check Balance of ERC20 is greater than amount used to mint
        //require(IERC20(erc20_address).balanceOf(msg.sender) >= _amount, "Not enough balance of this token");
        // 2. Check that this smart contract has enough allowance of the minters ERC20 to transfer
        //require(IERC20(erc20_address).allowance(msg.sender, address(this)) >= _amount, "Not enough allowance of this token");        
        // 3. Transfer the Amount of ERC20 tokens from the minter to the contract
        IERC20(erc20_address).transferFrom(msg.sender, address(this), _amount);
        // 4. Create an Amount Array needed for the _mintBatch function using getExchangeRate()
        uint256[] memory amounts = new uint[](teams);
        uint256[] memory teamsArr = new uint[](teams);
        uint256 exchangeAmount = _amount / exchangeRate * (10000 - mintFee) / 10000;
        for(uint256 i = 0; i < teams; i++){
            amounts[i] = exchangeAmount;
            teamsArr[i] = i;
        }

        // 5. Update Variables - totalDeposited, totalCurrentlySupply
        totalDeposited = totalDeposited + _amount;
        totalCurrentSupply = totalCurrentSupply + exchangeAmount;

        // 6. Approve Aave and Send ERC20 tokens to Aave
        IERC20(erc20_address).approve(pool_proxy_polygon, _amount);
        IPool(pool_proxy_polygon).supply(erc20_address, _amount, address(this), 0);

        // 7. Mint Batch
        _mintBatch(msg.sender, teamsArr, amounts, "");

        // 8. Return true to indicate successful mint
        return true;
    }
        
    //Burn Team Tokens
    function burnBatch(uint256 _amount) public returns(bool) {

        //--DIRECTIONS

        // 0. Burning must be enabled for this league
        // 1. Create Addresses and Amounts Array to use _burnBatch function using getExchangeRate() and getMintFee()
        // 2. Check Balance of team tokens is greater than amount used to burn
        // 3. Check that this smart contract has enough allowance of the burners team tokens to transfer
        // 4. Update Variables - totalWithdrawn, totalCurrentSupply
        // 5. Burn Batch
        // 6. Withdraw ERC20 tokens from Aave and send to burner
        // 7. Return true to indicate successful burn

        //--IMPLEMENTATION

        // 0. Burning must be enabled for this league
        require(canBurn, "No burning.");
        // 3. Check that this smart contract has enough allowance of the burners team tokens to transfer
        //require(isApprovedForAll(msg.sender, address(this)), "Don't have approval to burn tokens");
        // 1. Create Addresses and Amounts Array to use _burnBatch function using getExchangeRate() and getBurnFee()
        uint256[] memory amounts = new uint[](teams);
        uint256[] memory teamsArr = new uint[](teams);
        uint256 exchangeAmount = _amount * exchangeRate * (10000 - burnFee) / 10000;
        for(uint256 i = 0; i < teams; i++){
            amounts[i] = _amount;
            teamsArr[i] = i;
            // 2. Check Balance of each team tokens is greater than amount used to burn
            //require(balanceOf(msg.sender, i) >= _amount, "Don't have enough balance of a token");
        }
        // 4. Update Variables - totalWithdrawn, totalCurrentSupply
        totalWithdrawn = totalWithdrawn + exchangeAmount;
        totalCurrentSupply = totalCurrentSupply - _amount;
        // 5. Burn Batch
        _burnBatch(msg.sender, teamsArr, amounts);
        // 6. Withdraw ERC20 tokens from Aave and send exchangeAmount to burner
        IPool(pool_proxy_polygon).withdraw(erc20_address, exchangeAmount, msg.sender);
        // 7. Return true to indicate successful burn
        return true;
    }

    //Create New Season
    function createNewSeason(string calldata _name, address _season_factory_address) public isLeagueOwner returns(address) {
        require(!hasActiveLeague(), "Has an active season");
        address season_address = ISeasonFactory(_season_factory_address).createNewSeason(_name, owner);
        emit SeasonCreated(season_address);
        seasons.push(season_address);
        seasonStatus[season_address] = SeasonStatus.ACTIVE;
        return season_address;
    }

    //End Season
    function endSeason(address _season) public isLeagueOwner {
        //--DIRECTIONS

        // 1. Check if active
        // 2. Set Win Payout Amount
        // 3. Put SeasonStatus to Collecting in League Contract
        // 4. Put SeasonStatus to Collecting in Season Contract
        

        //--IMPLEMENTATION
        // 1. Check if active
        require(seasonStatus[_season] == SeasonStatus.ACTIVE, "Not an active season");
        // 2. Set Win Payout Amount
        if (num_of_seasons != 0) {
            winPayoutAmt[_season] = (getCurrentERC20Value() / SingleSeason(_season).totalWinPayouts()) / num_of_seasons;
        } else {
            winPayoutAmt[_season] = (getCurrentERC20Value() - getCurrentDeposited()) / SingleSeason(_season).totalWinPayouts();
        }
        // 3. Put SeasonStatus to Collecting in League Contract
        seasonStatus[_season] = SeasonStatus.COLLECTING;
        // 4. Put SeasonStatus to Collecting in Season Contract
        ISeason(_season).endSeason();
    }

    //Redeem Dividend (Win Payouts) NFTs
    function redeemNFTs(uint256[] calldata _token_ids, uint256[] calldata _amounts, address _season_contract) public payable returns(uint256) {
        //--DIRECTIONS

        // 1. Is this season status for this season contract collecting?
        // 2. Require appoval for season contract tokens
        // 3. Burn the Win Payout tokens
        // 4. Send back the correct amount of erc20 based on the winPayoutAmt mapping by withdrawing from Aave to msg.sender

        //--IMPLEMENTATION
        // 1. Is this season status for this season contract collecting?
        require(seasonStatus[_season_contract] == SeasonStatus.COLLECTING, "Not collecting");
        // 2. Require Approval for season contract tokens
        //require(ERC1155(_season_contract).isApprovedForAll(msg.sender, address(this)), "No approval");
        // 3. Burn the Win Payout tokens
        ISeason(_season_contract).burnBatch(msg.sender, _token_ids, _amounts);
        // 4. Send back the correct amount of erc20 based on the winPayoutAmt mapping by withdrawing from Aave to msg.sender
        uint256 winPayouts = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            winPayouts += _amounts[i];
        }
        IPool(pool_proxy_polygon).withdraw(erc20_address, winPayouts * winPayoutAmt[_season_contract], msg.sender);
        return winPayouts * winPayoutAmt[_season_contract];
    }
    

    //---------------------------------------------------
    //--Helper Functions---------------------------------
    //---------------------------------------------------

    function hasActiveLeague() public view returns (bool) {
        for (uint256 i = 0; i < seasons.length; i++) {
            if (seasonStatus[seasons[i]] == SeasonStatus.ACTIVE) {
                return true;
            }
        }
        return false;
    }


    //---------------------------------------------------
    //--GETTERS------------------------------------------
    //---------------------------------------------------

    //VARIABLES

    //getCurrentDeposited - check current deposited in contract --> totalDeposited - totalWithdrawn
    function getCurrentDeposited() public view returns (uint256) {
        return totalDeposited - totalWithdrawn;
    }
    //getCurrentERC20Value - Get Current Contract erc20 (USDC) Value
    function getCurrentERC20Value() public view returns(uint256) {
        return IERC20(aToken_erc20_address).balanceOf(address(this)); //should be value of aTokens
    }
    //getWinPayoutPoolValue - Get Win Payout Pool Value
    function getWinPayoutPoolValue() public view returns(uint256) {
        return getCurrentERC20Value() - getCurrentDeposited();
    }


    //---------------------------------------------------
    //--SETTERS------------------------------------------
    //---------------------------------------------------

    //DESCRIPTIVE VARIABLES
    //setTeams - Sets the Teams of the League
    function setTeams(uint256 _teams) public isLeagueOwner {
        teams = _teams;
    }

    //VARIABLES
    //setMintFee - Set the fee to mint
    function setMintFee(uint256 _mintFee) public isLeagueOwner {
        require(_mintFee < 10000, "Greater than 100% fee");
        mintFee = _mintFee;
    }
    //setBurnFee - Set the fee to burn
    function setBurnFee(uint256 _burnFee) public isLeagueOwner {
        require(_burnFee < 10000, "Greater than 100% fee");
        burnFee = _burnFee;
    }
    //setCanBurn - Set Burning Ability
    function setCanBurn(bool _canBurn) public isLeagueOwner {
        canBurn = _canBurn;
    }
    //setATokenAddress - set aToken Address
    function setATokenAddress(address _aToken) public isLeagueOwner {
        aToken_erc20_address = _aToken;
    }

    //ADDRESSES

    //setAavePoolAdress - sets the address of the aave pool
    function setAavePoolAddress(address _address) public isLeagueOwner {
        pool_proxy_polygon = _address;
    }    

}