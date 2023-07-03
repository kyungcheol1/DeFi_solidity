// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./SelfToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Staking {
    address private VASDtokenAddress;
    address private stakingAddress;
    SelfToken VASDtoken;
    struct StakeInfo {
        uint256 amount;
        uint256 stakedTime;
        bool isWithdrawable;
        address Lpaddress;
    }
    uint256 stakePid;

    mapping(address => mapping(address => mapping(uint256 => StakeInfo)))
        public stakeInfo;
    mapping(address => uint256) public stakeMonth;

    constructor() {
        stakingAddress = address(this);
    }

    function StakeDifferLp(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month,
        address _VASDtokenAddress
    ) public {
        VASDtokenAddress = _VASDtokenAddress;
        VASDtoken = SelfToken(VASDtokenAddress);
        if (stakeMonth[_userAccount] == 0) {
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                _amount,
                _month
            );
            stakeMonth[_userAccount] = _month;
        } else if (stakeMonth[_userAccount] < _month) {
            uint256 existMonth = stakeMonth[_userAccount];
            uint256 existAmount = stakeInfo[_userAccount][_differLptoken][
                stakeMonth[_userAccount]
            ].amount;
            uint256 takeAmount = _amount + existAmount;
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                takeAmount,
                _month
            );
            resetValue(_userAccount, _differLptoken, existMonth);
            stakeMonth[_userAccount] = _month;
        } else if (stakeMonth[_userAccount] > _month) {
            uint256 existMonth = stakeMonth[_userAccount];
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                _amount,
                _month
            );
            stakeInfo[_userAccount][_differLptoken][existMonth]
                .amount += stakeInfo[_userAccount][_differLptoken][_month]
                .amount;
            stakeMonth[_userAccount] = existMonth;
        } else if (stakeMonth[_userAccount] == _month) {
            uint256 existMonth = stakeMonth[_userAccount];
            uint256 existValue = stakeInfo[_userAccount][_differLptoken][
                existMonth
            ].amount;
            mergeFunction(
                _differLptoken,
                _userAccount,
                _factoryAddress,
                _amount,
                _month
            );
            stakeInfo[_userAccount][_differLptoken][_month]
                .amount += existValue;
        }
    }

    function withDrawDifferLp() public {}

    function transferStaking(
        address _differLptoken,
        address _userAccount,
        uint256 _amount,
        uint256 _month,
        address _factoryAddress
    ) internal {
        SelfToken(_differLptoken).transferFrom(
            _userAccount,
            _factoryAddress,
            _amount
        );
        stakeInfo[_userAccount][_differLptoken][_month].amount = _amount;
        stakeInfo[_userAccount][_differLptoken][_month].stakedTime = block
            .timestamp;
        stakeInfo[_userAccount][_differLptoken][_month].isWithdrawable = false;
    }

    function rewardStaking(address _userAccount, uint256 _amount) internal {
        VASDtoken.mint(_amount);
        VASDtoken.approve(_userAccount, _amount);
        VASDtoken.transferFrom(VASDtokenAddress, _userAccount, _amount);
    }

    function mergeFunction(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month
    ) internal {
        if (_month == 4) {
            transferStaking(
                _differLptoken,
                _userAccount,
                _amount,
                _month,
                _factoryAddress
            );
            rewardStaking(_userAccount, _amount);
        } else if (_month == 8) {
            transferStaking(
                _differLptoken,
                _userAccount,
                _amount,
                _month,
                _factoryAddress
            );
            rewardStaking(_userAccount, 2 * _amount);
        } else if (_month == 12) {
            transferStaking(
                _differLptoken,
                _userAccount,
                _amount,
                _month,
                _factoryAddress
            );
            rewardStaking(_userAccount, 4 * _amount);
        } else {
            revert("wrong month");
        }
    }

    function resetValue(
        address _userAccount,
        address _differLptoken,
        uint256 _findValue
    ) internal {
        stakeInfo[_userAccount][_differLptoken][_findValue].amount = 0;
        stakeInfo[_userAccount][_differLptoken][_findValue].stakedTime = 0;
        stakeInfo[_userAccount][_differLptoken][_findValue]
            .isWithdrawable = false;
    }
}
