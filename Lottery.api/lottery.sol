//SPDX-License-Identifier:MIT
pragma solidity ^0.8.14;

contract lottery {

    address manager;
    constructor() {
        manager = msg.sender;
    }

    address payable[] players;
    address payable winner;
    uint256 LotteryFees = 1 ether;

    function participate() public payable{
        require(msg.value == LotteryFees,"Must pay lottery fees inorder to participate.");
        players.push(payable(msg.sender));
    }

    function randomNo() internal view returns(uint256){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players.length)));
    }

    function pickWinner() public payable {
        require(msg.sender == manager,"Only lottery manager was authorized to do this action.");
        require(players.length >=3, "Players must be greater than 2 inorder to draw the lottery.");
        uint256 No = randomNo();
        uint256 index = No%players.length;

        winner = players[index];
        winner.transfer(address(this).balance);

        players = new address payable[](0);
    }
}
