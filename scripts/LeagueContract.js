// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  //Pre-Work
  // 1. Publish Fake USDC
  const FakeUSDC = await hre.ethers.getContractFactory("FakeUSDC");
  const fUSDC = await FakeUSDC.deploy();

  await fUSDC.deployed();

  const fUSDC_receipt = await fUSDC.deployTransaction.wait()

  //console.log(fUSDC_receipt)

  const fUSDCaddress = fUSDC_receipt.contractAddress;

  console.log(`Fake USDC deployed: ${fUSDCaddress}`)

  // 2. Mint Fake USDC

  const fUSDC_Contract = await hre.ethers.getContractAt("FakeUSDC", fUSDCaddress);
  const mint_fUSDC = await fUSDC_Contract.mintTokens(3200);
  const mint_Receipt = await mint_fUSDC.wait();

  //console.log(mint_Receipt);
  console.log(`My Balance of fUSDC: ${await fUSDC_Contract.balanceOf(mint_Receipt.from)}`)

  // 3. Publish Fake Aave and f_aUSDC
  const f_aUSDCContractFactory = await hre.ethers.getContractFactory("f_aUSDC");
  const f_aUSDCDeploy = await f_aUSDCContractFactory.deploy();
  await f_aUSDCDeploy.deployed();
  const f_aUSDCDeploymentReceipt = await f_aUSDCDeploy.deployTransaction.wait();
  const f_aUSDCaddress = f_aUSDCDeploymentReceipt.contractAddress;

  const FakeAave = await hre.ethers.getContractFactory("FakeAave");
  const fakeAave = await FakeAave.deploy(f_aUSDCaddress);
  await fakeAave.deployed();
  const fakeAaveDeploymentReceipt = await fakeAave.deployTransaction.wait();
  const fakeAaveaddress = fakeAaveDeploymentReceipt.contractAddress;

  const f_aUSDCContract = await hre.ethers.getContractAt("f_aUSDC", f_aUSDCaddress);

  console.log(`Fake aUSDC deployed: ${f_aUSDCaddress}`)
  console.log(`Fake Aave deployed: ${fakeAaveaddress}`)

  //-------------
  //Main Contract
  //-------------

  // 1. Publish League Factory
  const LeagueFactory = await hre.ethers.getContractFactory("LeagueFactory");
  const leagueFactory = await LeagueFactory.deploy();

  await leagueFactory.deployed();

  const receipt = await leagueFactory.deployTransaction.wait()

  const myAddress = receipt.from;
  const leagueFactoryAddress = receipt.contractAddress;

  //console.log(receipt)

  console.log(`League Factory deployed: ${leagueFactoryAddress}`)

  // 2. Publish Season Factory

  const SeasonFactory = await hre.ethers.getContractFactory("SeasonFactory");
  const seasonFactory = await SeasonFactory.deploy(leagueFactoryAddress);

  await seasonFactory.deployed();

  const seasonFactoryReceipt = await seasonFactory.deployTransaction.wait()

  const seasonFactoryAddress = seasonFactoryReceipt.contractAddress;

  //console.log(seasonFactoryReceipt)

  console.log(`Season Factory deployed: ${seasonFactoryAddress}`)

  // 3. Create New League through League Factory

  const info_strings = ["TestLeague1", "TST"];
  const info_nums = [32, 3200, 1];
  //const treasury_token = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"; //USDC Polygon Mainnet

  const LeagueFactoryContract = await hre.ethers.getContractAt("LeagueFactory", leagueFactoryAddress);
  const createLeague1 = await LeagueFactoryContract.createNewLeague(info_strings, info_nums, fUSDCaddress);
  const league1Receipt = await createLeague1.wait();

  let league1Address = null;

  if (league1Receipt.events) {
    for (let i = 0; i < league1Receipt.events.length; i++) {
      if (league1Receipt.events[i].args && league1Receipt.events[i].event == 'LeagueCreated') {
        league1Address = league1Receipt.events[i].args[0];
      }
    }
  }

  //console.log(league1Receipt)
  console.log(`League1 Created: ${league1Address}`)
  

  // 4. Create New Season through League by calling Season Factory
  //createNewSeason(string_name, address_season_factory_address)
  const season1name = "NFL 2023";

  const League1Contract = await hre.ethers.getContractAt("League", league1Address);
  const createSeason1 = await League1Contract.createNewSeason(season1name, seasonFactoryAddress);
  const season1Receipt = await createSeason1.wait();
  const setAavePool1 = await League1Contract.setAavePoolAddress(fakeAaveaddress);

  console.log(`League1 ERC20: ${await League1Contract.erc20_address()}`);
  console.log(`League1 Aave Pool: ${await League1Contract.pool_proxy_polygon()}`);

  //console.log(season1Receipt)

  let season1Address = "";

  if (season1Receipt.events) {
    for (let i = 0; i < season1Receipt.events.length; i++) {
      if (season1Receipt.events[i].args && season1Receipt.events[i].event == 'SeasonCreated') {
        season1Address = season1Receipt.events[i].args[0];
      }
    }
  }

  console.log(`Season1 for League1 Created: ${season1Address}`)


  // 5. Mint Team Tokens for League1
  const [owner, addr1, addr2, addr3] = await ethers.getSigners();
  
  //Mint fUSDC for addr1
  const addr1mint_fUSDC = await fUSDC_Contract.connect(addr1).mintTokens(3200);
  await addr1mint_fUSDC.wait();
  console.log(`Addr1 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr1.address)}`)
  await fUSDC_Contract.connect(addr1).approve(league1Address, 3200);
  //console.log(`league1 Allowance of Addr1 fUSDC: ${await fUSDC_Contract.allowance(addr1.address, league1Address)}`)

  //Mint fUSDC for addr2
  const addr2mint_fUSDC = await fUSDC_Contract.connect(addr2).mintTokens(6400);
  await addr2mint_fUSDC.wait();
  console.log(`Addr2 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr2.address)}`)
  await fUSDC_Contract.connect(addr2).approve(league1Address, 6400);
  //console.log(`league1 Allowance of Addr1 fUSDC: ${await fUSDC_Contract.allowance(addr2.address, league1Address)}`)

  //Mint fUSDC for addr3
  const addr3mint_fUSDC = await fUSDC_Contract.connect(addr3).mintTokens(9600);
  await addr3mint_fUSDC.wait();
  console.log(`Addr3 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr3.address)}`)
  await fUSDC_Contract.connect(addr3).approve(league1Address, 9600);
  //console.log(`league1 Allowance of Addr1 fUSDC: ${await fUSDC_Contract.allowance(addr3.address, league1Address)}`)

  //Need Approval for addr1
  const mint1League1 = await League1Contract.connect(addr1).mintBatch(3200);
  const mint1Receipt = await mint1League1.wait();
  const mint2League1 = await League1Contract.connect(addr2).mintBatch(6400);
  const mint2Receipt = await mint2League1.wait();
  const mint3League1 = await League1Contract.connect(addr3).mintBatch(9600);
  const mint3Receipt = await mint3League1.wait();

  console.log('-----Mint Tokens------')

  console.log(`Addr1 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr1.address)}`)
  console.log(`Addr2 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr2.address)}`)
  console.log(`Addr3 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr3.address)}`)
  console.log(`League1 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(league1Address)}`)
  console.log(`League1 Balance of f_aUSDC: ${await f_aUSDCContract.balanceOf(league1Address)}`)

  console.log(`Addr1 Balance of TeamToken[0]: ${await League1Contract.balanceOf(addr1.address, 0)}`)
  console.log(`Addr2 Balance of TeamToken[0]: ${await League1Contract.balanceOf(addr2.address, 0)}`)
  console.log(`Addr3 Balance of TeamToken[0]: ${await League1Contract.balanceOf(addr3.address, 0)}`)

  //console.log("------MINT 1 RECEIPT--------");
  //console.log(mint1Receipt);
  //console.log("------MINT 2 RECEIPT--------");
  //console.log(mint2Receipt);
  //console.log("------MINT 3 RECEIPT--------");
  //console.log(mint3Receipt);


  // 6. Propose Win Payout 1 for Season1
  const WinPayout1Array = [
    { teamOwner: addr1.address, amount: 1, },
    { teamOwner: addr2.address, amount: 2, },
    { teamOwner: addr3.address, amount: 3, },
  ];

  const Season1Contract = await hre.ethers.getContractAt("SingleSeason", season1Address);
  const proposeWinPayout1 = await Season1Contract.proposeWinPayout(WinPayout1Array);
  const proposeWinPayout1Receipt = await proposeWinPayout1.wait();

  console.log("------WIN PAYOUT 1--------");
  console.log(`Addr1 Balance of WinPayoutToken[0]: ${await Season1Contract.balanceOf(addr1.address, 0)}`)
  console.log(`Addr2 Balance of WinPayoutToken[0]: ${await Season1Contract.balanceOf(addr2.address, 0)}`)
  console.log(`Addr3 Balance of WinPayoutToken[0]: ${await Season1Contract.balanceOf(addr3.address, 0)}`)
  //console.log(proposeWinPayout1Receipt)

  // 7. Propose Win Payout 2 for Season1
  const WinPayout2Array = [
    { teamOwner: addr1.address, amount: 1, },
    { teamOwner: addr2.address, amount: 2, },
    { teamOwner: addr3.address, amount: 3, },
  ];

  const proposeWinPayout2 = await Season1Contract.proposeWinPayout(WinPayout2Array);
  const proposeWinPayout2Receipt = await proposeWinPayout2.wait();

  //console.log("------WIN PAYOUT 2 RECEIPT--------");
  //console.log(proposeWinPayout2Receipt)
  console.log("------WIN PAYOUT 2--------");
  console.log(`Addr1 Balance of WinPayoutToken[1]: ${await Season1Contract.balanceOf(addr1.address, 1)}`)
  console.log(`Addr2 Balance of WinPayoutToken[1]: ${await Season1Contract.balanceOf(addr2.address, 1)}`)
  console.log(`Addr3 Balance of WinPayoutToken[1]: ${await Season1Contract.balanceOf(addr3.address, 1)}`)

  // 8. Propose Win Payout 3 for Season1

  const proposeWinPayout3 = await Season1Contract.proposeWinPayout(WinPayout1Array);
  const proposeWinPayout3Receipt = await proposeWinPayout3.wait();

  //console.log("------WIN PAYOUT 3 RECEIPT--------");
  //console.log(proposeWinPayout3Receipt)
  console.log("------WIN PAYOUT 3--------");
  console.log(`Addr1 Balance of WinPayoutToken[2]: ${await Season1Contract.balanceOf(addr1.address, 2)}`)
  console.log(`Addr2 Balance of WinPayoutToken[2]: ${await Season1Contract.balanceOf(addr2.address, 2)}`)
  console.log(`Addr3 Balance of WinPayoutToken[2]: ${await Season1Contract.balanceOf(addr3.address, 2)}`)

  // 9. Add Aave Interest and Make Season1 SeasonStatus.COLLECTING by ending season through League1

  console.log("------END SEASON--------");

  //set the a token address for the win payout calculation
  await League1Contract.setATokenAddress(f_aUSDCaddress);

  const addAaveInterest = await f_aUSDCContract.mintTokens(league1Address, 600);
  await addAaveInterest.wait();
  console.log(`League1 Balance of f_aUSDC after yield: ${await f_aUSDCContract.balanceOf(league1Address)}`)
  console.log(`League1 Current Deposited: ${await League1Contract.getCurrentDeposited()}`)
  console.log(`Season1 TotalWinpayouts: ${await Season1Contract.totalWinPayouts()}`)

  const endSeason1League1 = await League1Contract.endSeason(season1Address);
  const endSeason1League1Receipt = await endSeason1League1.wait();
  console.log(`SeasonStatus (LeagueContract): ${await League1Contract.seasonStatus(season1Address)}`);
  console.log(`SeasonStatus (SeasonContract): ${await Season1Contract.status()}`);

  console.log(`Win Payout Amount: ${await League1Contract.winPayoutAmt(season1Address)}`);

  // 10. Redeem Win Payouts
  const _token_ids = [0, 1, 2];
  const _amounts = [1, 1, 1];

  console.log("------Addr 1 Redeem Win Payouts--------");

  const allowance1 = await Season1Contract.connect(addr1).setApprovalForAll(league1Address, true);
  await allowance1.wait();

  const redeemWinPayoutsSeason1League1addr1 = await League1Contract.connect(addr1).redeemNFTs(_token_ids, _amounts, season1Address);
  const redeemWinPayoutsSeason1League1addr1Receipt = await redeemWinPayoutsSeason1League1addr1.wait();
  //console.log(redeemWinPayoutsSeason1League1addr1Receipt);

  console.log(`Addr1 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr1.address)}`)
  console.log(`Addr2 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr2.address)}`)
  console.log(`Addr3 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr3.address)}`)


  // 11. Burn Tokens

  console.log("------Addr 1 Burn Tokens--------");

  const burnAllowance1 = await League1Contract.connect(addr1).setApprovalForAll(league1Address, true);
  await burnAllowance1.wait();
  const burnTeamTokensLeague1addr1 = await League1Contract.connect(addr1).burnBatch(1);
  const burnTeamTokensLeague1addr1Receipt = await burnTeamTokensLeague1addr1.wait();
  console.log(`Addr1 Balance of fUSDC: ${await fUSDC_Contract.balanceOf(addr1.address)}`)
  console.log(`Team Token Balance of addr1: ${await League1Contract.balanceOf(addr1.address, 0)}`)


  //Data
  console.log('-----------------------------------')
  console.log(`My Address: ${myAddress}`);
  console.log(`League Factory Address: ${leagueFactoryAddress}`);
  console.log(`Season Factory Address: ${seasonFactoryAddress}`);
  console.log(`League1 Address: ${league1Address}`);
  console.log(`Season1 Address: ${season1Address}`);
  console.log(`afUSDC Balance of LeagueContract: ${await f_aUSDCContract.balanceOf(league1Address)}`)
  console.log(`fUSDC Balance of addr1: ${await fUSDC_Contract.balanceOf(addr1.address)}`)
  console.log(`fUSDC Balance of addr2: ${await fUSDC_Contract.balanceOf(addr2.address)}`)
  console.log(`fUSDC Balance of addr3: ${await fUSDC_Contract.balanceOf(addr3.address)}`)
  console.log(`Team Token Balance of addr1: ${await League1Contract.balanceOf(addr1.address, 0)}`)
  console.log(`Team Token Balance of addr2: ${await League1Contract.balanceOf(addr2.address, 0)}`)
  console.log(`Team Token Balance of addr3: ${await League1Contract.balanceOf(addr3.address, 0)}`)
  console.log(`Win Payout 1 Balance of addr1: ${await Season1Contract.balanceOf(addr1.address, 0)}`)
  console.log(`Win Payout 2 Balance of addr1: ${await Season1Contract.balanceOf(addr1.address, 1)}`)
  console.log(`Win Payout 3 Balance of addr1: ${await Season1Contract.balanceOf(addr1.address, 2)}`)
  console.log(`Win Payout 1 Balance of addr2: ${await Season1Contract.balanceOf(addr2.address, 0)}`)
  console.log(`Win Payout 2 Balance of addr2: ${await Season1Contract.balanceOf(addr2.address, 1)}`)
  console.log(`Win Payout 3 Balance of addr2: ${await Season1Contract.balanceOf(addr2.address, 2)}`)
  console.log('-----------------------------------')


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
