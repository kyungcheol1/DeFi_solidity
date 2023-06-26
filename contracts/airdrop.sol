// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop {
    address owner;
    address factory;

    constructor(address _owner, address _factory){
        owner = _owner;
        factory = _factory;
    }

    function airdrop(address _token)public {
        require(msg.sender == owner, "only Gov");
        require(IERC20(_token).balanceOf(address(this)) > 0);

        //factory 에서 계정 정보들 받아오기
        // for (uint256 i = 1; i <= n; i++) {
        //     IERC20(_token).transfer();
        // }
    }



}
