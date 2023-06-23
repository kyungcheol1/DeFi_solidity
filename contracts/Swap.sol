// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./TokenPriceOracle.sol";
import "./SelfToken.sol";

contract Swap {
    using SafeMath for uint256;
    address public feeRecipient;
    uint256 public feePercentage;
    uint256 private ASDbalance;
    TokenPriceOracle public priceOracle;

    address public EthAddress = 0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08;
    address public UsdtAddress = 0x0a023a3423D9b27A0BE48c768CCF2dD7877fEf5E;
    address public ArbAddress = 0x2eE9BFB2D319B31A573EA15774B755715988E99D;

    constructor(uint256 _feePercentage) {
        feeRecipient = address(this);
        feePercentage = _feePercentage.mul(10 ** 18); // scale up the feePercentage by 10^18
        ASDbalance = 100000000;
        priceOracle = new TokenPriceOracle(EthAddress, UsdtAddress, ArbAddress);
    }

    function EthAsdSwapTokens(
        SelfToken tokenA,
        SelfToken tokenB,
        uint256 amountA
    ) public {
        uint256 feeAmount = amountA.mul(feePercentage).div(10 ** 20); // scale down the result
        uint256 amountToSwap = amountA.sub(feeAmount);

        // Get price for both tokens
        uint256 priceA = priceOracle.getEthPrice();
        uint256 amountB = amountToSwap.mul(priceA).div(ASDbalance);

        require(
            tokenA.transferFrom(msg.sender, feeRecipient, feeAmount),
            "Transfer of fee failed"
        );
        require(
            tokenA.transferFrom(msg.sender, address(this), amountToSwap),
            "Transfer of tokenA failed"
        );
        require(
            tokenB.transfer(msg.sender, amountB),
            "Transfer of tokenB failed"
        );
    }

    function UsdtAsdSwapTokens(
        SelfToken tokenA,
        SelfToken tokenB,
        uint256 amountA
    ) public {
        uint256 feeAmount = amountA.mul(feePercentage).div(10 ** 20);
        uint256 amountToSwap = amountA.sub(feeAmount);

        uint256 priceA = priceOracle.getUsdtPrice();
        uint256 amountB = amountToSwap.mul(priceA).div(ASDbalance);

        require(
            tokenA.transferFrom(msg.sender, feeRecipient, feeAmount),
            "Transfer of fee failed"
        );
        require(
            tokenA.transferFrom(msg.sender, address(this), amountToSwap),
            "Transfer of tokenA failed"
        );
        require(
            tokenB.transfer(msg.sender, amountB),
            "Transfer of tokenB failed"
        );
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
        uint256 priceA = 100000000;
        uint256 amountB = amountToSwap.mul(priceA).div(ASDbalance);

        // require(
        //     tokenA.transferFrom(msg.sender, feeRecipient, feeAmount),
        //     "Transfer of fee failed"
        // );
        require(
            tokenA.transferFrom(msg.sender, address(this), amountToSwap),
            "Transfer of tokenA failed"
        );
        require(
            tokenB.transfer(msg.sender, amountB),
            "Transfer of tokenB failed"
        );
    }
}
