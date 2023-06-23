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

    function ETHLpPool() internal {
        ETHLptoken = new SelfToken("ETH LP", "LP");
        USDTaddress = address(ARBLptoken);
    }

    function USDTLpPool() internal {
        USDTLptoken = new SelfToken("USDT LP", "LP");
        ETHaddress = address(USDTLptoken);
    }
}
