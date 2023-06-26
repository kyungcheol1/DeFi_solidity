// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./TokenPriceOracle.sol";
import "./SelfToken.sol";

contract Swap {
    using SafeMath for uint256;
    address public feeRecipient;
    uint256 public feePercentage;
    uint256 private AsdPrice;
    uint256 public EthPrice;
    uint256 public UsdtPrice;
    uint256 public ArbPrice;
    uint256 public EthSwapPercent;
    uint256 public UsdtSwapPercent;
    uint256 public ArbSwapPercent;
    uint256 public testValue;

    TokenPriceOracle public priceOracle;

    address public EthAddress = 0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08;
    address public UsdtAddress = 0x0a023a3423D9b27A0BE48c768CCF2dD7877fEf5E;
    address public ArbAddress = 0x2eE9BFB2D319B31A573EA15774B755715988E99D;

    constructor(uint256 _feePercentage) {
        feeRecipient = address(this);
        // feePercentage = _feePercentage.mul(10 ** 18); // scale up the feePercentage by 10^18
        AsdPrice = 100000000;
        priceOracle = new TokenPriceOracle(EthAddress, UsdtAddress, ArbAddress);
        // EthPrice = priceOracle.getEthPrice();
        // UsdtPrice = priceOracle.getUsdtPrice();
        // ArbPrice = priceOracle.getArbPrice();
        // EthSwapPercent = EthPrice / AsdPrice;
        // UsdtSwapPercent = UsdtPrice / AsdPrice;
        // ArbSwapPercent = ArbPrice / AsdPrice;
        EthSwapPercent = 1878;
        UsdtSwapPercent = 1;
        ArbSwapPercent = 1;
    }

    // function EthAsdSwapTokens(
    //     SelfToken tokenA,
    //     SelfToken tokenB,
    //     uint256 amountA
    // ) public {
    //     // uint256 feeAmount = amountA.mul(feePercentage).div(10 ** 20); // scale down the result
    //     uint256 amountToSwap = amountA.sub(feeAmount);

    //     // Get price for both tokens
    //     uint256 amountB = amountToSwap.mul(EthSwapPercent);

    //     require(
    //         tokenA.transferFrom(msg.sender, feeRecipient, feeAmount),
    //         "Transfer of fee failed"
    //     );
    //     require(
    //         tokenA.transferFrom(msg.sender, address(this), amountToSwap),
    //         "Transfer of tokenA failed"
    //     );
    //     require(
    //         tokenB.transfer(msg.sender, amountB),
    //         "Transfer of tokenB failed"
    //     );
    // }

    // function UsdtAsdSwapTokens(
    //     SelfToken tokenA,
    //     SelfToken tokenB,
    //     uint256 amountA
    // ) public {
    //     uint256 feeAmount = amountA.mul(feePercentage).div(10 ** 20);
    //     uint256 amountToSwap = amountA.sub(feeAmount);

    //     uint256 amountB = amountToSwap.mul(UsdtSwapPercent);

    //     require(
    //         tokenA.transferFrom(msg.sender, feeRecipient, feeAmount),
    //         "Transfer of fee failed"
    //     );
    //     require(
    //         tokenA.transferFrom(msg.sender, address(this), amountToSwap),
    //         "Transfer of tokenA failed"
    //     );
    //     require(
    //         tokenB.transfer(msg.sender, amountB),
    //         "Transfer of tokenB failed"
    //     );
    // }
    function testFunction(uint256 _amountA) public {
        testValue = _amountA * ArbSwapPercent;
    }

    function ArbAsdSwapTokens(
        SelfToken tokenA,
        SelfToken tokenB,
        uint256 amountA
    ) public {
        // uint256 feeAmount = amountA.mul(feePercentage).div(10 ** 20);
        // uint256 amountToSwap = amountA.sub(feeAmount);
        uint256 amountToSwap = amountA;

        // uint256 priceA = priceOracle.getArbPrice();
        uint256 amountB = amountToSwap * ArbSwapPercent;
        // testValue = amountB;
        // tokenB.approve(msg.sender, amountB);
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(address(this), msg.sender, amountB);
    }
}
