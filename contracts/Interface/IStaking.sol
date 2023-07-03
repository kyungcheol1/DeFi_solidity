// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IStaking {
    function StakeDifferLp(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month,
        address _VASDtokenAddress
    ) external;

    function withDrawDifferLp() external;
}
