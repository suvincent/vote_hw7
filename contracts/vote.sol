// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Ballot {
   
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal,
        uint proposal; // index of proposal
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to uint  because they are much cheaper
        uint name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    mapping(address => Voter) public voters;
    
    // mapping(uint  => bool) public proposalExist;
    
    Proposal[] public proposals;
    
    // enum State {SETUP , PROPOSE, VOTE , TALLY , FINISH}
    
    // State public state;
    
    uint[2] public times;//投票時間
    /** 
     
     */
    constructor(uint vst,uint vet)public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        times[0] = vst;
        times[1] = vet;
    }
    
    function blockOrTimeReached(uint i)public view returns(bool){
        if(i == 0){//////////////Setting or Propose state
            if(block.timestamp * 1000 < times[0])return true;
            else return false;
        }
        else if(i == 1){/////////Vote
            if((block.timestamp * 1000 < times[1])&& (block.timestamp *1000> times[0]))return true;
            else return false;
        }
        else if(i == 2){/////////Tally(vote end)
            if(block.timestamp * 1000> times[1])return true;
            else return false;
        }
        else return false;
    }
    modifier checkInVoteStage() {
        require(blockOrTimeReached(1));
        _;

    }
    modifier checkInTallyStage() {
        require(blockOrTimeReached(2));
        _;

    }
    
    /*
    
    */
    function setVoteTime(uint vst,uint vet)private{
        require(blockOrTimeReached(0),"Now is not time for Propose or setting!");
        times[0] = vst;
        times[1] = vet;
    }
    
    function Proposed(uint  proposalName)public{
        // require(blockOrTimeReached(0),"Now is not time for Propose or setting!");
        // require(!proposalExist[proposalName], "proposal already exist!");
        // Voter storage sender = voters[msg.sender];
        // require(sender.proposal == 0);// voter還沒proposed過
        // voters[msg.sender].proposal = proposals.length;
        proposals.push(Proposal({
                name: proposalName,
                voteCount: 0
        }));
        // proposalExist[proposalName] = true;
    }
    
    
    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
    function giveRightToVote(address voter, uint newWeight) public {
        require(
            blockOrTimeReached(0),
            "Now is not time for Propose or setting!"
        );
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        voters[voter].weight = newWeight;
    }

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param to address to which vote is delegated
     */
    // function delegate(address to) public {
    //     Voter storage sender = voters[msg.sender];
    //     require(!sender.voted, "You already voted.");
    //     require(to != msg.sender, "Self-delegation is disallowed.");

    //     while (voters[to].delegate != address(0)) {
    //         to = voters[to].delegate;

    //         // We found a loop in the delegation, not allowed.
    //         require(to != msg.sender, "Found loop in delegation.");
    //     }
    //     sender.voted = true;
    //     sender.delegate = to;
    //     Voter storage delegate_ = voters[to];
    //     if (delegate_.voted) {
    //         // If the delegate already voted,
    //         // directly add to the number of votes
    //         proposals[delegate_.vote].voteCount += sender.weight;
    //     } else {
    //         // If the delegate did not vote yet,
    //         // add to her weight.
    //         delegate_.weight += sender.weight;
    //     }
    // }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal) public {
        require(blockOrTimeReached(1),"Now is not time for Votng!");
        // Voter storage sender = voters[msg.sender];
        require(voters[msg.sender].weight != 0, "Has no right to vote");
        require(!voters[msg.sender].voted, "Already voted.");
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += voters[msg.sender].weight;
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view
            returns (uint  winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}
