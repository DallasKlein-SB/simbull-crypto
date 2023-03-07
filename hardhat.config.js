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
