// SPDX-License-Identifier: MIT

import "./SelfToken.sol";

pragma solidity ^0.8.9;

contract Pair {
    SelfToken ArbLpToken;
    SelfToken UsdtLpToken;
    SelfToken EthLpToken;
    address private ArbLpaddress;
    address private UsdtLpaddress;
    address private EthLpaddress;
    struct CheckToken {
        address token1;
        address token2;
    }

    /**
    @dev lp pool용 mapping데이터들 
     */
    mapping(address => mapping(uint256 => CheckToken)) public poolData;
    uint[] public poolDataNum;
    uint public poolIndex;

    constructor() {}

    function makeLpPool(
        address _token1,
        address _token2,
        address _contractAddress,
        string memory _tokenName
    ) external {
        bool isExists = false;

        for (uint i = 0; i < poolDataNum.length; i++) {
            CheckToken memory existingPool = poolData[_contractAddress][i];

            if (
                (existingPool.token1 == _token1 &&
                    existingPool.token2 == _token2) ||
                (existingPool.token1 == _token2 &&
                    existingPool.token2 == _token1)
            ) {
                isExists = true;
                break;
            }
        }
        require(!isExists, "The pool already exists.");
        if (!isExists) {
            CheckToken memory newPool = CheckToken(_token1, _token2);
            poolData[_contractAddress][poolIndex] = newPool;
            poolDataNum.push(poolIndex);
            poolIndex += 1;
            if (keccak256(bytes(_tokenName)) == keccak256(bytes("ARB"))) {
                ArbLpToken = new SelfToken("ARBLP", "LP");
                ArbLpaddress = address(ArbLpToken);
                // ARBtokenAddress = _token1;
            } else if (
                keccak256(bytes(_tokenName)) == keccak256(bytes("USDT"))
            ) {
                UsdtLpToken = new SelfToken("USDTLP", "LP");
                UsdtLpaddress = address(UsdtLpToken);
                // USDTtokenAddress = _token1;
            } else if (
                keccak256(bytes(_tokenName)) == keccak256(bytes("ETH"))
            ) {
                EthLpToken = new SelfToken("ETHLP", "LP");
                EthLpaddress = address(UsdtLpToken);
                // ETHtokenAddress = _token1;
            }
        }
    }

    function getLpAddress()
        public
        view
        returns (address arblp, address usdtlp, address ethlp)
    {
        return (ArbLpaddress, UsdtLpaddress, EthLpaddress);
    }
}
