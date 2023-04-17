//SPDX-License-Identifier:MIT
pragma solidity ^0.8.14;

contract BuyMeACoffee {

    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    struct info {
        address payable from;
        address payable to;
        string name;
        string message;
        uint256 timestamp;
    }

    info[] information;

    function buyCoffee(address payable _to, string calldata _name, string calldata _message) public payable{
        require(msg.value > 0, "Please enter a value greater than 0." );
        _to.transfer(msg.value);
        information.push(info(payable(msg.sender), _to, _name, _message, block.timestamp));
    }

    function getInfo() public view returns(info[] memory){
        return information;
    }
}
