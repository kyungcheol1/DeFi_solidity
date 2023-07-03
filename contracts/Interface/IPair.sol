// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IPair {
    function makeLpPool(
        address _token1,
        address _token2,
        address _contractAddress,
        string memory _tokenName
    ) external;

    function getLpAddress()
        external
        view
        returns (address arblp, address usdtlp, address ethlp);
}
