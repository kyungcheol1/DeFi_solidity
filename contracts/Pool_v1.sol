// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Math.sol";
import "./Swap.sol";
import "./SelfToken.sol";
import "./Lphandle.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Pool_v1 is Swap, LpHandle {
    using SafeMath for uint256;
    uint public poolLevel;
    uint private totalLpAmount;
    address private owner;
    address public contractAddress;
    address public ASDAddress;
    address public VASDAddress;
    uint private totaltoken1;
    uint private totaltoken2;
    uint private receiveFeeAmount;
    SelfToken ASDtoken;
    SelfToken VASDtoken;
    uint one_month = 2592000;
    uint four_month = 11836800;
    uint eight_month = 23673600;
    uint stakePid = 0;

    event CalcLendingEvent(uint tokenTotalLp);

    struct StakeInfo {
        uint256 amount;
        uint256 stakedTime;
        bool isWithdrawable;
        address Lpaddress;
    }

    mapping(address => mapping(address => uint256)) public Accounts;
    mapping(address => uint256) public Lpcalc;
    mapping(uint256 => mapping(address => mapping(uint256 => StakeInfo)))
        public stakeInfo;
    mapping(address => mapping(address => uint256)) lpLevel;

    constructor(uint _feePercentage) Swap(_feePercentage) {
        owner = msg.sender;
        contractAddress = address(this);
        ASDtoken = new SelfToken("ASD", "VASD");
        ASDAddress = address(ASDtoken);
        VASDtoken = new SelfToken("VASD", "VASD");
        VASDAddress = address(VASDtoken);
    }

    modifier checkOwner() {
        require(msg.sender == owner, "only owner!!");
        _;
    }

    function getSupply(address _token) public view returns (uint) {
        return IERC20(_token).totalSupply();
    }

    function initialize(address _feeRecipient, uint _feePercentage) public {
        owner = msg.sender;
        contractAddress = address(this);
        feeRecipient = _feeRecipient;
        feePercentage = _feePercentage;
    }

    function ArbapproveSwap(
        address _arbToken,
        address _asdToken,
        uint arbAmount
    ) public {
        ArbAsdSwapTokens(SelfToken(_arbToken), SelfToken(_asdToken), arbAmount);
    }

    function ArbAsdPool_1(
        address _arbToken,
        address _asdToken,
        uint arbAmount,
        uint asdAmount,
        address _lptoken
    ) public {
        // token 주소들 넣어놓고 대조하는 require문 작성
        require(
            lpLevel[msg.sender][ARBaddress] == 1,
            "wront LP level, check the level"
        );
        address userAccount = msg.sender;
        setDeposit(msg.sender, _arbToken, arbAmount, _asdToken, asdAmount);
        uint lpAmount = calclending(
            _arbToken,
            arbAmount,
            _asdToken,
            asdAmount,
            _lptoken
        );
        ARBLpPool();
        ARBLpReward(userAccount, lpAmount);
    }

    function ArbAsdPool_2(
        address _arbToken,
        address _asdToken,
        uint arbAmount,
        uint asdAmount,
        address _lptoken
    ) public {
        require(
            lpLevel[msg.sender][ARBaddress] == 2,
            "wront LP level, check the level"
        );
        address userAccount = msg.sender;
        setDeposit(msg.sender, _arbToken, arbAmount, _asdToken, asdAmount);
        uint lpAmount = calclending(
            _arbToken,
            arbAmount,
            _asdToken,
            asdAmount,
            _lptoken
        );

        ARBLpPool();
        ARBLpReward(userAccount, lpAmount);
        uint256 rewardToken = lpAmount / 100;
        ASDtoken.approve(userAccount, rewardToken);
        ASDtoken.transferFrom(contractAddress, userAccount, rewardToken);
    }

    function ArbAsdPool_3(
        address _arbToken,
        address _asdToken,
        uint arbAmount,
        uint asdAmount,
        address _lptoken
    ) public {
        require(
            lpLevel[msg.sender][ARBaddress] == 3,
            "wront LP level, check the level"
        );
        address userAccount = msg.sender;
        setDeposit(msg.sender, _arbToken, arbAmount, _asdToken, asdAmount);
        uint lpAmount = calclending(
            _arbToken,
            arbAmount,
            _asdToken,
            asdAmount,
            _lptoken
        );
        ARBLpPool();
        ARBLpReward(userAccount, lpAmount);
        uint256 rewardToken = lpAmount / 100;
        VASDtoken.approve(userAccount, rewardToken);
        VASDtoken.transferFrom(contractAddress, userAccount, rewardToken);
    }

    function ARBstake(uint256 month) external {
        uint256 userLpBalance = ARBLptoken.balanceOf(msg.sender);
        if (month == 4) {
            ARBstakeLp(month, userLpBalance);
            stakeVASD(userLpBalance);
        } else if (month == 8) {
            ARBstakeLp(month, userLpBalance);
            stakeVASD(2 * userLpBalance);
        } else if (month == 12) {
            ARBstakeLp(month, userLpBalance);
            stakeVASD(4 * userLpBalance);
        } else {
            revert("wrong month");
        }
    }

    function ARBstakeLp(uint256 _month, uint256 _amount) internal {
        require(_amount > 0, "cannot stake 0Lp tokens");
        address userAccount = msg.sender;
        ARBLptoken.approve(userAccount, _amount);
        ARBLptoken.transferFrom(userAccount, address(this), _amount);
        uint256 currentStakeId = stakePid;
        stakePid += 1;
        stakeInfo[_month][msg.sender][currentStakeId].amount = _amount;
        stakeInfo[_month][msg.sender][currentStakeId].stakedTime = block
            .timestamp;
        stakeInfo[_month][msg.sender][currentStakeId].isWithdrawable = false;
    }

    function stakeVASD(uint256 _amount) internal {
        require(_amount > 0, "cannot stake 0Lp tokens");
        address userAccount = msg.sender;
        VASDtoken.mint(_amount);
        VASDtoken.approve(userAccount, _amount);
        VASDtoken.transferFrom(VASDAddress, userAccount, _amount);
    }

    function Withdrawable(
        uint256 _month,
        uint256 _index
    ) external returns (bool) {
        if (
            _month == 4 &&
            block.timestamp >
            stakeInfo[4][msg.sender][_index].stakedTime + one_month
        ) {
            stakeInfo[4][msg.sender][_index].isWithdrawable = true;
        }
        if (
            _month == 8 &&
            block.timestamp >
            stakeInfo[8][msg.sender][_index].stakedTime + one_month
        ) {
            stakeInfo[8][msg.sender][_index].isWithdrawable = true;
        }
        if (
            _month == 12 &&
            block.timestamp >
            stakeInfo[12][msg.sender][_index].stakedTime + one_month
        ) {
            stakeInfo[12][msg.sender][_index].isWithdrawable = true;
        }
        return stakeInfo[_month][msg.sender][_index].isWithdrawable;
    }

    function ARBwithDraw(uint256 _month, uint256 _index) public {
        require(
            stakeInfo[_month][msg.sender][_index].isWithdrawable,
            "not yet"
        );
        uint256 withDrawAmount = stakeInfo[_month][msg.sender][_index].amount;
        ARBLptoken.transferFrom(address(this), msg.sender, withDrawAmount);
    }

    function setDeposit(
        address _user,
        address _token1,
        uint256 _amount1,
        address _token2,
        uint256 _amount2
    ) public {
        Accounts[_user][_token1] = _amount1;
        Accounts[_user][_token2] = _amount2;
        Lpcalc[_token1] += _amount1;
        Lpcalc[_token2] += _amount2;
    }

    function calclending(
        address _token1,
        uint amount1,
        address _token2,
        uint amount2,
        address _lptoken
    ) public returns (uint) {
        SelfToken(_lptoken);
        uint totalTokenamount = SelfToken(_lptoken).totalSupply() +
            amount1 +
            amount2;
        totalLpAmount = Lpcalc[_token1] * Lpcalc[_token2];
        uint token1Percent = ((amount1 * 100) / totalTokenamount);
        uint token2Percent = ((amount2 * 100) / totalTokenamount);
        uint token1Lp = (totalTokenamount * token1Percent) / 100;
        uint token2Lp = (totalTokenamount * token2Percent) / 100;
        uint tokenTotalLp = token1Lp + token2Lp;
        return tokenTotalLp;
    }

    function whatLpcheck(address _lptoken) public view returns (uint) {
        address userAccount = msg.sender;
        return SelfToken(_lptoken).balanceOf(userAccount);
    }

    function whatLpPoolCheck(address _lptoken) public view returns (uint) {
        return SelfToken(_lptoken).totalSupply();
    }
}
