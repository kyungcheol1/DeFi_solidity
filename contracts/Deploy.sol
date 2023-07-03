// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Pool.sol";
import "./SelfToken.sol";
import "./Pair.sol";
import "./Liquid.sol";
import "./Swap.sol";
import "./Staking.sol";

contract Deploy {
    Pair pairParam;
    Liquid liquidParam;
    Swap swapParam;
    Staking stakingParam;
    address private VASDtokenAddress;
    address private pairAddress;
    address private liquidAddress;
    address private swapAddress;
    address private stakingAddress;
    SelfToken deployAsdtoken;
    SelfToken deployVasdtoken;
    SelfToken deployArbtoken;
    SelfToken deployUsdttoken;
    SelfToken deployEthtoken;

    constructor(uint256 _feePercent) {
        deployVasdtoken = new SelfToken("VASD", "VASD");
        VASDtokenAddress = address(deployVasdtoken);
        pairParam = new Pair();
        pairAddress = address(pairParam);
        liquidParam = new Liquid();
        liquidAddress = address(liquidParam);
        swapParam = new Swap(_feePercent);
        swapAddress = address(swapParam);
        stakingParam = new Staking();
        stakingAddress = address(stakingParam);
    }

    function tokenAddress() public view returns (address vasdToken) {
        return (VASDtokenAddress);
    }

    function featureAddress()
        public
        view
        returns (address pair, address liquid, address swap, address staking)
    {
        return (pairAddress, liquidAddress, swapAddress, stakingAddress);
    }
}
