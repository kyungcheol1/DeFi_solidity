//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./timelock.sol";

contract Governance {
    address private owner;
    address private govToken;
    uint256 private proposalAmount;
    address public goverAddress;
    address public timelock;

    struct Receipt {
        bool vote;
        bool agree;
    }

    struct Proposal {
        address proposer;
        uint startBlock;
        uint endBlock;
        bytes callData;
        bool canceled;
        bool executed;
        uint256 amountVote;
        mapping(address => Receipt) hasVotes;
    }

    address[] public participants;

    mapping(uint => Proposal) public proposes;
    mapping(uint => address[]) public votes;

    constructor(address _owner) {
        owner = _owner;
        goverAddress = address(this);
    }

    function propose(address _proposer, bytes memory _callData) public {
        require(IERC20(govToken).balanceOf(_proposer) > 0, "Governance : Do not have a vASD token.");

        uint startBlock = block.number;
        uint endBlock = block.number + 17280;
        Proposal storage newProposal = proposes[proposalAmount + 1];
        newProposal.proposer = _proposer;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.callData = _callData;
        newProposal.canceled = false;
        newProposal.executed = false;
        newProposal.amountVote = 0;
        newProposal.hasVotes[_proposer] = Receipt(true, true);
        proposalAmount += 1;

        ERC20(govToken)._burn(_proposer, 1); // burn 시킬 govtoken의 가치에 대해서 ?
    }

    function voting(address _participant, uint _proposal, bool _agree) public {
        require(IERC20(govToken).balanceOf(_participant) > 0, "Governance : Do not have a vASD token.");
        require(proposes[_proposal].hasVotes[_participant].vote == false, "Governance : It is a proposal that has already been voted on.");
        // require(proposes[_proposal].endBlock > block.number, "Governance : It's an overdue vote.");
        proposes[_proposal].hasVotes[_participant] = Receipt(true, _agree);
        votes[_proposal].push(_participant);
        proposes[_proposal].amountVote +=
            uint256(IERC20(govToken).balanceOf(_participant) * 10 ** 18) /
            IERC20(govToken).totalSupply();
    }

    function timelockExecute(uint _proposal) public returns (bool) {
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days."); //3일 > 17,280
        if (proposes[_proposal].amountVote > 0.51 * 10 ** 18) {
            proposes[_proposal].executed = true;
            Timelock(timelock).queueTransaction(proposes[_proposal].callData, block.timestamp);
            return true;
        } else {
            proposes[_proposal].canceled = true;
            return false;
        }
    }
    
    function proposalExecute(uint _proposal) public returns(bool){
        require(msg.sender == owner, "Governance : only owner");
        // require(proposes[_proposal].endBlock < block.number, "Governance : It hasn't been three days.");
        require(proposes[_proposal].executed, "Governance : It's a vote that didn't pass.");
        require(Timelock(timelock).executeTransaction(proposes[_proposal].callData, block.timestamp), "Governance : Timelock is running.");
        require(Timelock(timelock).getTransaction(proposes[_proposal].callData).status);
        //proposes.callData 실행시켜야함
        return true;
    }

    function makeCallData() public pure returns (bytes memory) {
        return abi.encode(msg.data);
    }

    function changeLevel(address token) public {}

    function changeOwner(address _newOwner) private {
        owner = _newOwner;
    }

    function setTokenAddress(address _token) public {
        require(owner == msg.sender);
        govToken = _token;
    }

    function setTimelockAddress(address _timelock) public {
        require(owner == msg.sender);
        timelock = _timelock;
    }

    function getProposal(
        uint _idx
    )
        public
        view
        returns (address, uint, uint, bytes memory, bool, bool, uint)
    {
        Proposal storage proposal = proposes[_idx];
        return (
            proposal.proposer,
            proposal.startBlock,
            proposal.endBlock,
            proposal.callData,
            proposal.canceled,
            proposal.executed,
            proposal.amountVote
        );
    }
}
