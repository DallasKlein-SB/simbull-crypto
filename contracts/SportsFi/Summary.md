# League.sol

- Ln15 - Ln212
`using SafeMath for uint;`
Solc has a built-in under/overflow check since v0.8.0. SafeMath is no longer needed.

- Ln21
`event SeasonCreated(address seasonAddress);`
indexing the event is a good practice. It allows to filter the event by the indexed parameter. In this case, it would be the seasonAddress.

- Ln28-29-30-37-38-43
Make these variable immutable saves gas (and they aren't changeable after deployment)

- Ln31
`uint256[] public teams;`
These array stores sequential id's. Using a counter (an uint256) would save gas (and prevent an unlikely DoS). the loop Ln129 would then populate the array in memory (avoiding storage access at all).

- Ln36
`uint256   public totalCurrentSupply;` 
If this is the same as deposit - withdraw, making the (unchecked) difference is cheaper than storing a counter

- Ln46
`address   public contract_address;`
This variable is uninitialised and unused. Suggest removing it.

- Ln74-75-76-79-80
Initialising variable with their default value is not needed and cost gas

- Ln90
Best practice is to avoid reinventing the wheel (as it add an additional risk), suggest using OpenZeppelin Ownable

- Ln91-96
Use of custom errors is cheaper than revert(string)

- Ln95
This modifier is used only once, suggest moving the require to the function body.

- Ln105
This function doesn't treat ETH payment yet is payable. Especially for a mint function, this could lead to user loss of funds. Suggest removing payable.

- Ln109-110
Both are check not needed as they're performed in the ERC20 contract itself. Performing them twice is a non-negligible gas cost.

- Ln134
_mintBatch is a safe mint function, triggering onERC1155BatchReceived on the sender -> this is a reentrancy vector and as such should be called last (check-effect-interaction pattern) or use a reentrancy guard

- Ln142
supply could transfer from the sender to the pool directly (without transferring first to the contract then to the pool, which is an extra storage access)

- Ln165
When using require, gas cost of a string has a stipend every 32 bytes (ie a new word is used), if not using custom error, minimise reason string length

- Ln167-175
Same as Ln109-110 (double check) but for erc1155

# Season.sol

- Ln38 URI is a temporary value?

# LeagueFactory.sol

- Ln12-13-14
This looks like a set structure without using it's functionnalities. Suggest using OpenZeppelin EnumerableSet address (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol), which implement the functions commented out too (in O(1))

- Ln42&50
Cast the return value of create into an address, avoiding further manipulation: 
`address _leagueContract = address(new League(...))`