
# SportsFi v1 Protocol by SimBull

This project is a the first version of a protocol that enables people to create leagues that earn interest from Aave and issue payouts according to any type of 'wins'. Similar to PoolTogether, but instead of a lottery determining who the interest on the deposits is paid to, it's determined based on the number of wins.

An example- A League Contract represents an NFL league that has 32 different tokens on an ERC1155 contract (one for each team). By sending USDC, or the specific token by the league, to the League Contract, addresses can mint an equal amount of each of the 32 Team Tokens, and then trade them on the secondary market to get their optimal portfolio of Team Tokens. Additionally, another ERC1155 contract is created to represent a single Season, where the tokens of that contract will be issued to all holders of a specific team token from the League Contract at the time of the win. Imagine you own two Team Tokens with id 14 from the League Contract that represents the New York Jets, they win the opening game of the 2023 season and you now receive two Win Payout Tokens with id 0 from the Season Contract. The next game issues Win Payout Tokens from the Season Contract with id 1, and so on. Once the season is ended, you can exchange your Win Payout Tokens with the League Contract for a portion of the interest that it earned from the Aave Protocol during that season. If the League Contract earned 100 USDC in interest from Aave over the course of the season, and there were 200 Win Payout Tokens issued from the Seaason Contract, each Win Payout Token is redeemable for 0.5 USDC. At the beginning of the next season, a new Season Contract is created and the cycle is repeated. As well, if an address has Team Tokens for all 32 teams, they can choose at any point to burn their tokens and get back the deposited USDC at the same exchange rate as the minting process.


# Step-by-Step

## 1. Deploy the League Factory

This contracts creates and is a directory for leagues. Anyone can create their own league. 


## 2. Deploy the Season Factory

This contract lets League owners create a new season for a specific league. Before creating a new season, it will make sure the the function call is coming from a valid League created by the associated League Factory.


## 3. Create a New League by calling LeagueFactory.createNewLeague()

To create a new league, the following parameters are required: 
    -name and symbol of the League
    -number of teams in the league
    -exchange rate from an ERC20 token to one token of each team in the league
    -number of seasons this league will last, with 0 representing forever
    -the ERC20 token address that will be used as the token to mint and earn from Aave

The address that calls the function will become the League Owner, giving it admin status over the contract to make updates and mint Win Payout Tokens.


## 4. (Part 1) Create a New Season by calling League.createNewSeason() from the League Owner address

The function must be called by the League Owner address and the league cannot have an active season currently. It also must include the parameters of a season name and season factory address to create the new season from.

## 4. (Part 2) The League Contract calls SeasonFactory.createNewSeason()

If the call is coming from a valid League Contract, a new Season is created. 


## 5. Users begin to Mint Team Tokens by calling League.mintBatch()

The League contract requires the sender address to have enough balance and give enough allowance of the ERC20 token to transfer the amount specified in the paramter of the function.

The League contract then transfers itself the ERC20 token, calculates the correct exchange rate from ERC20 token to ERC1155 Team Tokens while taking into account a minting fee, and then mints the new Team Tokens to the sender address.

Lastly, the League contract supplies the Aave protocol with the amount of ERC20 tokens it received from the mint, and receives back aTokens from Aave.


## 6. Games start to be completed, and the League Owner starts minting Win Payout Tokens from the Season Contract by calling Season.proposeWinPayout() 

Currently centralized, with the vision to decentralize in v2, the League Owner must send the correct amount of Win Payout Tokens to be minted for each Team Token Holder to the Season Contract. This is done on a local server by taking a snapshot at the end of the game of current Team Token Holders and their amount of Team Tokens. Then, an array of addresses and amounts is sent to the Season Contract to mint the Win Payout Tokens. This process will happen for each game of the season.


## 7. The League Owner can end a season by calling League.endSeason() with the season address as a parameter

Once the season is over in real life, the season needs to be ended on-chain for the Win Payout Tokens to be redeemable for their share of the interest earned on the deposits. 

The League Contract calculates what each Win Payout Token will be able to be excahnged for the specified Season Contract with the ERC20 token. It's calculated by dividing the interest gained from Aave during that season divided by the total amount Win Payout Tokens from that Season Contract.

It also switches the season status to COLLECTING, which indicates that the Win Payout Tokens from that Season Contract are able to be redeemed for the ERC20 token.


## 8. Users can now redeem their Win Payout Tokens from the ended season for the ERC20 token.

A user can approve the League Contract to burn their Win Payout Tokens from the Season Contract in order to redeem their ERC20. The user will have to send an array of token_ids and and their corresponding amounts, where the League contract will add up the amounts, withdraw ERC20 from Aave to the user, and burn the Win Payout Tokens.


## 9. Users can also burn their Team Tokens to get back deposited ERC20 by calling League.burnBatch()

If the League has burning enabled and the user has a certain amount of each Team Token, they can burn them all in exchange for the ERC20 at the same exchange rate as minting, minus a potential burning fee. The League contract will check that the user has the correct amount of each Team Token, burn them, and return back the correct amount of the ERC20 by withdrawing from Aave.

## 10. The cycle continues: The League Owner can create a new Season again, mint Win Payouts, etc. 



# Example Script

There is an example script that under scripts/LeagueContract.js that illustrates how it works and goes through each of the above steps. It creates a local version of an ERC20 token and yield protocol that are used in place of USDC and Aave.

```shell
npx hardhat run scripts/LeagueContract.js
```