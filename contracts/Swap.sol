// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./TokenPriceOracle.sol";
import "./SelfToken.sol";

contract Swap {
    address public feeRecipient;
    uint public feePercentage;
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

    constructor(uint _feePercentage) {
        feeRecipient = address(this);
        feePercentage = _feePercentage;
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

    function differTokenSwap(
        address tokenA,
        address tokenB,
        address _userAccount,
        address _contractAddress,
        uint256 amountA
    ) public {
        uint256 amountB;
        uint256 feeAmount;
        uint256 amountToSwap;
        uint256 swapPercent;
        if (
            keccak256(bytes(SelfToken(tokenA).name())) ==
            keccak256(bytes("ARB"))
        ) {
            swapPercent = ArbSwapPercent;
        } else if (
            keccak256(bytes(SelfToken(tokenA).name())) ==
            keccak256(bytes("USDT"))
        ) {
            swapPercent = UsdtSwapPercent;
        } else if (
            keccak256(bytes(SelfToken(tokenA).name())) ==
            keccak256(bytes("ETH"))
        ) {
            swapPercent = EthSwapPercent;
        } else {
            revert("Unsupported token");
        }

        (feeAmount, amountToSwap) = calculateFeesAndAmountToSwap(amountA);

        amountB = calculateAmountB(amountToSwap, swapPercent);

        conductTransfer(
            tokenA,
            tokenB,
            _userAccount,
            _contractAddress,
            amountA,
            amountB,
            feeAmount,
            amountToSwap
        );
    }

    function calculateFeesAndAmountToSwap(
        uint256 amountA
    ) public view returns (uint256 feeAmount, uint256 amountToSwap) {
        uint256 _feePercentage = feePercentage * 10 ** 17;
        feeAmount = (amountA / 10 ** 18) * _feePercentage;
        amountToSwap = amountA - feeAmount;
        return (feeAmount, amountToSwap);
    }

    function calculateAmountB(
        uint256 amountToSwap,
        uint256 swapPercent
    ) public pure returns (uint256) {
        return amountToSwap * swapPercent;
    }

    function conductTransfer(
        address tokenA,
        address tokenB,
        address _userAccount,
        address _contractAddress,
        uint256 amountA,
        uint256 amountB,
        uint256 feeAmount,
        uint256 amountToSwap
    ) public payable {
        SelfToken(tokenA).approve(_contractAddress, amountA);
        SelfToken(tokenB).approve(_contractAddress, amountB);
        SelfToken(tokenA).transferFrom(
            _userAccount,
            _contractAddress,
            feeAmount
        );
        SelfToken(tokenA).transferFrom(
            _userAccount,
            _contractAddress,
            amountToSwap
        );
        SelfToken(tokenB).transferFrom(_contractAddress, _userAccount, amountB);
    }
}
