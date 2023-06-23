# hardhat version

```js
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
      url: "https://api.baobab.klaytn.net:8651",
      chainId: 1001,
      accounts: require("./accounts.json").privateKey,
      gas: 20000000,
      gasPrice: 250000000000,
    },
    abitrum: {
      url: "https://endpoints.omniatech.io/v1/arbitrum/goerli/public",
      chainId: 421613,
      accounts: require("./accounts.json").privateKey,
      gas: 20000000,
      gasPrice: 25000000000,
    },
  },
};
```

# remixd 설치

```sh
npm install @remix-project/remixd
remixd -s . --remix-ide https://remix.ethereum.org
```

# openzeppelin/contracts 설치

```sh
npm install @openzeppelin/contracts
```

# chainlink address / decimal 10^8

eth/usd : 0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08
usdt /usd : 0x0a023a3423D9b27A0BE48c768CCF2dD7877fEf5E
arb / usd : 0x2eE9BFB2D319B31A573EA15774B755715988E99D
이렇게 총 세개임

# 상태변수 읽어오기

상태변수가 선언되어있으면 자동적으로 getter함수가 생김 하지만 constructor가 생겨야 하기떄문에

await를 써서 가져와야 함

# CA 주소들(1버전)

ASD token 주소 : 0x3136B924058Da7127f83C76Ea512576CB5a9fDBa
ARB token 주소 : 0x66E7fE6Ca7B1D2A3Bbd321160a6adA649d568F1e
VASD token 주소 : 0x1A4C3758EF080bC5F04122e950cB1b138155e387
Pool 주소: 0xDc04625769FC5Ee454804BE3271B9fe0F13bd2db
gover 주소 : 0x2905462d901930ef98f7BdA835602086Aff97612
