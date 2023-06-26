// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Swap.sol";
import "./SelfToken.sol";
import "./Lphandle.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Pool_v1 is Swap, LpHandle {
    using SafeMath for uint256;
    uint public poolLevel;
    uint public totalLpAmount;
    address private owner;
    address public contractAddress;
    address public ASDAddress;
    address public VASDAddress;
    uint public totaltoken1;
    uint public totaltoken2;
    uint public receiveFeeAmount;
    uint public previousLp;
    SelfToken ASDtoken;
    SelfToken VASDtoken;
    uint one_month = 2592000;
    uint four_month = 11836800;
    uint eight_month = 23673600;
    uint stakePid = 0;
    uint decimals = 1000000000;

    event CalcLendingEvent(uint tokenTotalLp);

    struct StakeInfo {
        uint256 amount;
        uint256 stakedTime;
        bool isWithdrawable;
        address Lpaddress;
    }
    /** 
    @dev Acoounts는 첫번째로 pool에 스테이킹을 하는 Lp토큰을 받는 mapping데이터에 대한 설명입니다. 
    address_1 user의 계정
    address_2 어떤 lp token을 받았는지 
    address_3 어떤 토큰들을 예치할것인지
    uint 그 토큰을 얼마나 예치했는지 확인하는 것 
    */
    mapping(address => mapping(address => mapping(address => uint)))
        public Accounts;
    /**
    @dev Lpcalc는 Lp를 총 계산하는데 쓰이는 객체입니다. 
    lp 총 계산하는데 쓰이는 객체
    address_1: address 는 어떤 Lp 풀인가
    address_2: 어떤 토큰인가
    uint256: 얼마나 예치했는지
     */
    mapping(address => mapping(address => uint256)) public Lpcalc;
    /**
    @dev stakeInfo는 staking을 할떄 쓰이는 객체입니다. 
    uint256_1 month(얼마나 예치할건지)
    address_1 누가 예치했는지
    uint256_2 PID
    StakeInfo는 staking관련 정보들인데 
    4-1 얼마나 예치했는지(LP를!)
    4-2 는 stake한 시간이 언제인지
    4-3 스테이킹을 종료할 수 있는지, 아닌지
    4-4 어떤 Lp토큰을 예치했는지 
     */
    mapping(uint256 => mapping(address => mapping(uint256 => StakeInfo)))
        public stakeInfo;

    constructor(uint _feePercentage) Swap(_feePercentage) {
        owner = msg.sender;
        contractAddress = address(this);
        VASDtoken = new SelfToken("VASD", "VASD");
        VASDAddress = address(VASDtoken);
        poolLevel = 1;
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

    function ArbAsdPool_1(
        address _Arbtoken1,
        uint256 _amount1,
        address _Asdtoken2,
        uint256 _amount2
    ) public {
        require(
            _amount1 >= 1 && _amount2 >= _amount1 * ArbSwapPercent,
            "Please set the minimum proportion"
        );
        require(poolLevel == 1, "check the pool level");
        ARBLpPool();
        SelfToken(_Arbtoken1).transferFrom(msg.sender, address(this), _amount1);
        SelfToken(_Asdtoken2).transferFrom(msg.sender, address(this), _amount2);
        Accounts[msg.sender][ARBLpaddress][_Arbtoken1] += _amount1;
        Accounts[msg.sender][ARBLpaddress][_Asdtoken2] += _amount2;
        uint256 calcLp = calclending(
            _Arbtoken1,
            Accounts[msg.sender][ARBLpaddress][_Arbtoken1],
            _Asdtoken2,
            Accounts[msg.sender][ARBLpaddress][_Asdtoken2]
        );
        Lpcalc[ARBLpaddress][_Arbtoken1] += _amount1;
        Lpcalc[ARBLpaddress][_Asdtoken2] += _amount2;
        ARBLpReward(msg.sender, calcLp);
        totalLpAmount += calcLp;
    }

    function ArbAsdPool_2(
        address _Arbtoken1,
        uint256 _amount1,
        address _Asdtoken2,
        uint256 _amount2
    ) public {
        require(
            _amount1 >= 1 && _amount2 >= _amount1 * ArbSwapPercent,
            "Please set the minimum proportion"
        );
        require(poolLevel == 1, "check the pool level");
        ARBLpPool();
        SelfToken(_Arbtoken1).transferFrom(msg.sender, address(this), _amount1);
        SelfToken(_Asdtoken2).transferFrom(msg.sender, address(this), _amount2);
        Accounts[msg.sender][ARBLpaddress][_Arbtoken1] += _amount1;
        Accounts[msg.sender][ARBLpaddress][_Asdtoken2] += _amount2;
        uint256 calcLp = calclending(
            _Arbtoken1,
            Accounts[msg.sender][ARBLpaddress][_Arbtoken1],
            _Asdtoken2,
            Accounts[msg.sender][ARBLpaddress][_Asdtoken2]
        );
        Lpcalc[ARBLpaddress][_Arbtoken1] += _amount1;
        Lpcalc[ARBLpaddress][_Asdtoken2] += _amount2;
        ARBLpReward(msg.sender, calcLp);
        totalLpAmount += calcLp;
    }

    function ArbAsdPool_3(
        address _Arbtoken1,
        uint256 _amount1,
        address _Asdtoken2,
        uint256 _amount2
    ) public {
        require(
            _amount1 >= 1 && _amount2 >= _amount1 * ArbSwapPercent,
            "Please set the minimum proportion"
        );
        require(poolLevel == 1, "check the pool level");
        ARBLpPool();
        SelfToken(_Arbtoken1).transferFrom(msg.sender, address(this), _amount1);
        SelfToken(_Asdtoken2).transferFrom(msg.sender, address(this), _amount2);
        Accounts[msg.sender][ARBLpaddress][_Arbtoken1] += _amount1;
        Accounts[msg.sender][ARBLpaddress][_Asdtoken2] += _amount2;
        uint256 calcLp = calclending(
            _Arbtoken1,
            Accounts[msg.sender][ARBLpaddress][_Arbtoken1],
            _Asdtoken2,
            Accounts[msg.sender][ARBLpaddress][_Asdtoken2]
        );
        Lpcalc[ARBLpaddress][_Arbtoken1] += _amount1;
        Lpcalc[ARBLpaddress][_Asdtoken2] += _amount2;
        ARBLpReward(msg.sender, calcLp);
        totalLpAmount += calcLp;
    }

    function withdrawArbLp(
        address _Lptoken,
        address _Arbtoken,
        address _Asdtoken,
        uint256 _amount
    ) public {
        require(_Lptoken == ARBLpaddress, "please send correct token");
        require(
            SelfToken(_Lptoken).totalSupply() >= _amount,
            "insufficient lp amount"
        );
        uint256 lpcalcparams = _amount * decimals;
        uint256 lpcalcpercent = lpcalcparams / totalLpAmount;
        uint256 withdrawArb1 = (Lpcalc[_Lptoken][_Arbtoken] * lpcalcpercent) /
            decimals;
        uint256 withdrawAsd2 = (Lpcalc[_Lptoken][_Asdtoken] * lpcalcpercent) /
            decimals;
        ARBLptoken.transferFrom(msg.sender, address(this), _amount);
        SelfToken(_Arbtoken).transferFrom(
            address(this),
            msg.sender,
            withdrawArb1
        );
        SelfToken(_Asdtoken).transferFrom(
            address(this),
            msg.sender,
            withdrawAsd2
        );
    }

    function calclending(
        address _token1,
        uint256 amount1,
        address _token2,
        uint256 amount2
    ) public returns (uint) {
        if (
            SelfToken(_token1).balanceOf(address(this)) > 0 &&
            SelfToken(_token2).balanceOf(address(this)) > 0
        ) {
            totaltoken1 = SelfToken(_token1).balanceOf(address(this));
            totaltoken2 = SelfToken(_token2).balanceOf(address(this));
            previousLp = (SelfToken(_token1).balanceOf(address(this)) *
                SelfToken(_token2).balanceOf(address(this))).sqrt();
        }
        uint totalAmount = (SelfToken(_token1).balanceOf(address(this)) +
            amount1) * (SelfToken(_token2).balanceOf(address(this)) + amount2);
        uint totallpAmount = totalAmount.sqrt() - previousLp;
        return totallpAmount;
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
            block.timestamp > stakeInfo[4][msg.sender][_index].stakedTime + 5
            // stakeInfo[4][msg.sender][_index].stakedTime + one_month
        ) {
            stakeInfo[4][msg.sender][_index].isWithdrawable = true;
        }
        if (
            _month == 8 &&
            block.timestamp > stakeInfo[8][msg.sender][_index].stakedTime + 5
            // stakeInfo[8][msg.sender][_index].stakedTime + four_month
        ) {
            stakeInfo[8][msg.sender][_index].isWithdrawable = true;
        }
        if (
            _month == 12 &&
            block.timestamp > stakeInfo[12][msg.sender][_index].stakedTime + 5
            // stakeInfo[12][msg.sender][_index].stakedTime + one_month
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

    function whatLpcheck(address _lptoken) public view returns (uint) {
        address userAccount = msg.sender;
        return SelfToken(_lptoken).balanceOf(userAccount);
    }

    function whatLpPoolCheck(address _lptoken) public view returns (uint) {
        return SelfToken(_lptoken).totalSupply();
    }

    function whoVasdPoolCheck(address _account) public view returns (uint) {
        return VASDtoken.balanceOf(_account);
    }

    function vasdPoolCheck() public view returns (uint) {
        return VASDtoken.totalSupply();
    }
}
