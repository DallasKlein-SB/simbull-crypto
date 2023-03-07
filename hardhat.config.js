require("@nomicfoundation/hardhat-toolbox");
require('hardhat-contract-sizer');
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version:"0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  networks: {
    hardhat: {

    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      accounts: [process.env.MUMBAI_PRIVATE_KEY, process.env.ADDR1_PRIVATE_KEY, process.env.ADDR2_PRIVATE_KEY, process.env.ADDR3_PRIVATE_KEY]
    }
  }
  ,
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    only: ['League', 'LeagueFactory', 'SeasonFactory', "SingleSeason"],
  }
};
