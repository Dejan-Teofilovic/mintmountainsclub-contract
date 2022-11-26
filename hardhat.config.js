require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

const { API_KEY, MAINNET_RPC_URL, TESTNET_RPC_URL, WALLET_PRIVATE_KEY } = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.13",
  defaultNetwork: "goerli",
  networks: {
    goerli: {
      url: TESTNET_RPC_URL,
      accounts: [WALLET_PRIVATE_KEY],
    },
    ethereum: {
      url: MAINNET_RPC_URL,
      accounts: [WALLET_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: API_KEY,
  },
};
