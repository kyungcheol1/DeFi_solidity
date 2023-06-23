// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "./SelfToken.sol";

contract LpHandle {
    SelfToken ARBLptoken;
    address ARBaddress;
    SelfToken USDTLptoken;
    address USDTaddress;
    SelfToken ETHLptoken;
    address ETHaddress;

    constructor() {}

    function ARBLpPool() internal {
        ARBLptoken = new SelfToken("ARB LP", "LP");
        ARBaddress = address(ARBLptoken);
    }

    function ARBLpReward(address _userAccount, uint _lpamount) internal {
        ARBLptoken.mint(_lpamount);
        ARBLptoken.approve(_userAccount, _lpamount);
        ARBLptoken.transferFrom(ARBaddress, _userAccount, _lpamount);
    }

    function ETHLpPool() internal {
        ETHLptoken = new SelfToken("ETH LP", "LP");
        USDTaddress = address(ARBLptoken);
    }

    function ETHLpReward(address _userAccount, uint _lpamount) internal {
        ETHLptoken.mint(_lpamount);
        ETHLptoken.approve(_userAccount, _lpamount);
        ETHLptoken.transferFrom(ARBaddress, _userAccount, _lpamount);
    }

    function USDTLpPool() internal {
        USDTLptoken = new SelfToken("USDT LP", "LP");
        ETHaddress = address(USDTLptoken);
    }

    function USDTLpReward(address _userAccount, uint _lpamount) internal {
        USDTLptoken.mint(_lpamount);
        USDTLptoken.approve(_userAccount, _lpamount);
        USDTLptoken.transferFrom(ARBaddress, _userAccount, _lpamount);
    }
}
