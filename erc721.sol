// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Spacebear is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Spacebear", "SBP") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ethereum-blockchain-developer.com/2022-06-nft-truffle-hardhat-foundry/nftdata/";
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    mapping (uint256 => Listing) public listings;
    mapping (address => uint256) public balances;


    struct Listing {
        uint256 price;
        address seller;
    }

    function sellNFT(uint256 tokenId ,uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "You're the not the owner of this NFT");
        listings[tokenId] = Listing(price, msg.sender);
    }

    function buyNFT(uint256 tokenId) public payable{
        balances[msg.sender] += msg.value;
        Listing memory item  = listings[tokenId];
        require(balances[msg.sender] >= item.price , "Insufffucient Funds");
        balances[(item.seller)] += msg.value;
        balances[msg.sender] -= msg.value;
        withdrawMoney(item.seller, tokenId , item);
        safeTransferFrom(item.seller , msg.sender, tokenId ,"");
        listings[tokenId] =Listing(0, address(0));
        

    }

    function withdrawMoney(address destAddress , uint tokenId, Listing memory item) private {
        item = listings[tokenId];
        payable(destAddress).transfer(balances[item.seller]);
       
        
    }



}
