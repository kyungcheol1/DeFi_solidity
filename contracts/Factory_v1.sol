// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./SelfToken.sol";
import "./Pool.sol";
import "./Interface/IPair.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Factory_v1 {
    uint256 public factoryLevel; // 팩토리레벨
    address private owner; // 거버넌스
    address public factoryAddress; // Factory 주소
    // 토큰들 주소
    address public ARBtokenAddress;
    address public USDTtokenAddress;
    address public ETHtokenAddress;
    address public ASDtokenAddress; // 여기서는 테스트 용으로 지금 놓지만 나중에는 자동으로 배포해서 받자.
    address public VASDtokenAddress;
    // pair, liquid, swap, pool
    address public pairAddress;
    address public liquidAddress;
    address public swapAddress;
    address public poolAddress;
    // lp 주소
    address public ArbLpaddress; // ARBLpaddress
    address public UsdtLpaddress; // ARBLpaddress
    address public EthLpaddress; // ARBLpaddress
    Pool pool;

    // Deploy getData;

    constructor(address _deployAddress) {
        factoryAddress = address(this);
        pool = new Pool(_deployAddress);
        poolAddress = address(pool);
        (VASDtokenAddress) = IDeploy(_deployAddress).tokenAddress();
        (pairAddress, liquidAddress, swapAddress) = IDeploy(_deployAddress)
            .featureAddress();
    }

    event CalcLendingEvent(uint tokenTotalLp);

    function swapToken(
        address _diffrentToken,
        address _AsdToken,
        uint256 _amount
    ) public {
        address userAccount = msg.sender;
        pool.swapToken(
            _diffrentToken,
            _AsdToken,
            userAccount,
            factoryAddress,
            _amount
        );
    }

    function createPool(address _differentToken, address _AsdToken) public {
        pool.differLpPool(_differentToken, _AsdToken, factoryAddress);
        pairAddress = pool.pairAddress();
        (ArbLpaddress, UsdtLpaddress, EthLpaddress) = IPair(pairAddress)
            .getLpAddress();
    }

    function checkLptoken(
        address _randomAddress
    ) public view returns (uint256) {
        address userAccount = msg.sender;
        return SelfToken(_randomAddress).balanceOf(userAccount);
    }

    function addLiquid_1(
        address _differentToken,
        uint256 _amount1,
        address _AsdToken,
        uint256 _amount2
    ) public {
        address userAccount = msg.sender;
        pool.differLiquid(
            _differentToken,
            _amount1,
            _AsdToken,
            _amount2,
            userAccount,
            factoryAddress
        );
    }

    function withDrawLiquid(
        address _differLpToken,
        uint256 _amount,
        address _AsdToken
    ) public {
        address userAccount = msg.sender;
        pool.removeLiquid(
            _differLpToken,
            _amount,
            userAccount,
            factoryAddress,
            _AsdToken
        );
    }

    function LpStaking(
        address _differLptoken,
        uint256 _amount,
        uint256 month
    ) public {
        address userAccount = msg.sender;
        uint256 checkAmount = SelfToken(_differLptoken).balanceOf(userAccount);
        require(_amount <= checkAmount, "check the LpBalance");
        pool.differLpstaking(
            _differLptoken,
            userAccount,
            factoryAddress,
            _amount,
            month,
            VASDtokenAddress
        );
    }

    function withDrawStaking() public {
        address userAccount = msg.sender;
        pool.differLpWithdraw(userAccount);
    }
}
