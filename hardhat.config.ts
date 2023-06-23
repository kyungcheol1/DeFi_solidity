import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      forking: {
        url: "https://klaytn.blockpi.network/v1/rpc/public",
      },
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        accountsBalance: "10000000000000000000000000", // 10,000,000 KLAY
      },
      blockGasLimit: 30000000,
    },
    baobab: {
      url:"https://api.baobab.klaytn.net:8651",
      chainId: 1001,
      accounts : require("./accounts.json").privateKey,
      gas: 20000000,
      gasPrice: 250000000000
    },
    abitrum: {
      url:"https://endpoints.omniatech.io/v1/arbitrum/goerli/public",
      chainId:421613,
      accounts : require("./accounts.json").privateKey,
      gas:20000000,
      gasPrice: 25000000000
    }

  }
};

export default config;
