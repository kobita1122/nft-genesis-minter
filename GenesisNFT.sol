// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GenesisNFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MINT_PRICE = 0.05 ether;
    uint256 public constant MAX_PER_WALLET = 5;

    uint256 public totalSupply;
    bool public isPublicSaleActive = false;
    string public baseURI;
    
    mapping(address => uint256) public walletMints;

    constructor(string memory _name, string memory _symbol, string memory _initBaseURI) 
        ERC721(_name, _symbol) 
    {
        baseURI = _initBaseURI;
    }

    function mint(uint256 quantity) external payable {
        require(isPublicSaleActive, "Sale is not active");
        require(totalSupply + quantity <= MAX_SUPPLY, "Max supply exceeded");
        require(walletMints[msg.sender] + quantity <= MAX_PER_WALLET, "Wallet limit exceeded");
        require(msg.value >= MINT_PRICE * quantity, "Incorrect Ether value");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply + 1;
            totalSupply++;
            _safeMint(msg.sender, tokenId);
        }
        
        walletMints[msg.sender] += quantity;
    }

    function toggleSale() external onlyOwner {
        isPublicSaleActive = !isPublicSaleActive;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
}
