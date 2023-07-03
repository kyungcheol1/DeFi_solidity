// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./SelfToken.sol";
import "./Deploy.sol";
import "./Interface/IDeploy.sol";
import "./Interface/ISwap.sol";
import "./Interface/IPair.sol";
import "./Interface/ILiquid.sol";
import "./Interface/IStaking.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Pool {
    address public poolAddress;
    // token
    address public ARBtokenAddress;
    address public USDTtokenAddress;
    address public ETHtokenAddress;
    // lp 토큰 관련 주소들
    address public ArbLpaddress;
    address public UsdtLpaddress;
    address public EthLpaddress;
    // pair, liquid, swap, staking주소
    address public pairAddress;
    address public liquidAddress;
    address public swapAddress;
    address public stakingAddress;
    // test용
    uint256 public withdrawArb;
    uint256 public withdrawAsd;
    uint256 public totalLpAmount;

    struct lpInfo {
        address ArbLp;
        uint256 ArbLpAmount;
        address UsdtLp;
        uint256 UsdtLpAmount;
        address EthLp;
        uint256 EthLpAmount;
    }

    mapping(address => lpInfo) whatLp;

    Deploy getData;

    constructor(address _deployaddress) {
        poolAddress = address(this);
        (pairAddress, liquidAddress, swapAddress, stakingAddress) = IDeploy(
            _deployaddress
        ).featureAddress();
    }

    function swapToken(
        address _diffrentToken,
        address _AsdToken,
        address _userAccount,
        address _contractAddress,
        uint256 _amount
    ) public {
        ISwap(swapAddress).differTokenSwap(
            _diffrentToken,
            _AsdToken,
            _userAccount,
            _contractAddress,
            _amount
        );
    }

    function differLpPool(
        address _token1,
        address _token2,
        address _contractAddress
    ) public {
        string memory differTokenName = SelfToken(_token1).name();

        IPair(pairAddress).makeLpPool(
            _token1,
            _token2,
            _contractAddress,
            differTokenName
        );
        (ArbLpaddress, UsdtLpaddress, EthLpaddress) = IPair(pairAddress)
            .getLpAddress();
    }

    function differLiquid(
        address _token1,
        uint256 _amount1,
        address _token2,
        uint256 _amount2,
        address _userAccount,
        address _factoryAddress
    ) public {
        ILiquid(liquidAddress).makeLiquid(
            _token1,
            _amount1,
            _token2,
            _amount2,
            _userAccount,
            _factoryAddress,
            pairAddress
        );
    }

    function removeLiquid(
        address _differLptoken,
        uint256 _amount,
        address _userAccount,
        address _factoryAddress,
        address _AsdToken
    ) public {
        ILiquid(liquidAddress).doRemoveLiquid(
            _differLptoken,
            _amount,
            _userAccount,
            _factoryAddress,
            _AsdToken
        );
        (
            withdrawArb,
            withdrawAsd,
            totalLpAmount,
            ARBtokenAddress,
            USDTtokenAddress,
            ETHtokenAddress
        ) = ILiquid(liquidAddress).checkTest();
    }

    function differLpstaking(
        address _differLptoken,
        address _userAccount,
        address _factoryAddress,
        uint256 _amount,
        uint256 _month,
        address _VASDtokenAddress
    ) public {
        string memory tokenName = SelfToken(_differLptoken).name();
        if (Strings.equal(tokenName, "ARBLP")) {
            whatLp[_userAccount].ArbLp = _differLptoken;
            whatLp[_userAccount].ArbLpAmount = _amount;
        } else if (Strings.equal(tokenName, "USDTLP")) {
            whatLp[_userAccount].UsdtLp = _differLptoken;
            whatLp[_userAccount].UsdtLpAmount = _amount;
        } else if (Strings.equal(tokenName, "ETHLP")) {
            whatLp[_userAccount].EthLp = _differLptoken;
            whatLp[_userAccount].EthLpAmount = _amount;
        }
        IStaking(stakingAddress).StakeDifferLp(
            _differLptoken,
            _userAccount,
            _factoryAddress,
            _amount,
            _month,
            _VASDtokenAddress
        );
    }

    function differLpWithdraw(address _userAccount) public {}
}

// function USDTpoolLv(uint256 _level) external {
//     USDTPoolLevel = _level;
// }
