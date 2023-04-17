// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";


contract NFTMarketPlace is ERC721URIStorage {
   using Counters for Counters.Counter;

   Counters.Counter private _tokenId;
   Counters.Counter private _itemsSold;

   address manager;
    constructor() ERC721("Gems","gms"){
        manager = msg.sender;
    }

    struct token{
        uint256 tokenId;
        uint256 price;
        address payable seller;
        address payable owner;
        bool sold;
    }
    
    mapping(uint256 => token) private idToToken;

    event tokenEvent (
        uint256 indexed tokenId,
        uint256 price,
        address seller,
        address owner,
        bool sold
    );

    //Function to Mint Tokens
    function mintToken(uint256 price, string memory tokenURI ) public payable returns(uint256){
        require(price > 0, "Price must be greater than 0 inorder to list the token.");

        _tokenId.increment();
        uint256 currentId = _tokenId.current();

        _mint(msg.sender, currentId);
        _setTokenURI(currentId, tokenURI);
        createToken(currentId, price);

        return currentId;
    }

    //function to assign the data
    function createToken(uint256 price, uint256 tokenId) private {
        idToToken[tokenId] = token(tokenId,price,payable(msg.sender),payable(address(this)),false);

        _transfer(msg.sender, address(this), tokenId);

        emit tokenEvent(tokenId,price,msg.sender,address(this),false);
    }

    //function to resell the existing token
    function resell(uint256 tokenId, uint256 _price) public payable {
        require(idToToken[tokenId].owner == msg.sender,"Only the token owner can resell the tokens");
        require(_price > 0,"Price must be greater tha 0.");

        idToToken[tokenId].owner = payable(address(this));
        idToToken[tokenId].seller = payable(msg.sender);
        idToToken[tokenId].price = _price;
        idToToken[tokenId].sold = false;

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    //function to Buy tokens
    function buytokens(uint256 tokenId) public payable {
        require(msg.value == idToToken[tokenId].price,"Must pay sufficient price to buy the token");
        
        idToToken[tokenId].owner = payable(msg.sender);
        idToToken[tokenId].seller = payable(address(this));
        idToToken[tokenId].sold = true;
        
        _itemsSold.increment();

        _transfer(address(this),msg.sender, tokenId);
    
        payable(idToToken[tokenId].seller).transfer(msg.value);
    }

    //function to get all nfts
    function getAllNfts() public view returns(token[] memory){
        uint256 itemCount = _itemsSold.current();
        token[] memory items = new token[](itemCount);

        uint256 currentIndex = 0;

        for(uint i=0; i < itemCount; i++){

            uint currentId = i + 1;
            token storage currentItem = idToToken[currentId];
            items[currentIndex] = currentItem;
            currentIndex +=1;
        }
        return items;
    }

    //function to get the purchased NFTs
    function getMyNFT()public view returns(token[] memory){
        uint totalItemCount = _tokenId.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i=0; i < totalItemCount;i++){

            if(idToToken[i + 1].owner == msg.sender){
                itemCount += 1;
            }
        }

        token[] memory items = new token[](itemCount);
        for(uint i=0; i < totalItemCount; i++){

            if(idToToken[i+1].owner == msg.sender){
                uint currentId = i + 1;
                token storage currentItem = idToToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
