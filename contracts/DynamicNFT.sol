// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DynamicNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    // Constants for different NFT types
    string private constant BASE_URI_FIRST_NFT = "https://gateway.pinata.cloud/ipfs/QmUzY8icfRVAQbePaLWUPfwdJNB7rAsUTdED14XoymxyP3";
    string private constant BASE_URI_BODY_FAT = "https://gateway.pinata.cloud/ipfs/QmVHh4fCDcqa4MGjYnJP4n4kyKFy4v4RavefGDfg7er237";
    string private constant BASE_URI_MUSCLE_MASS = "https://gateway.pinata.cloud/ipfs/QmPqqvsyi7L3R3JF3RZGX3S25UtFWC27763S5HPr8EHWxX";
    
    // Supply limits for each type of NFT
    uint256 public constant MAX_SUPPLY_FIRST_NFT = 20;
    uint256 public constant MAX_SUPPLY_BODY_FAT = 20;
    uint256 public constant MAX_SUPPLY_MUSCLE_MASS = 20;
    
    // Current supply counters
    uint256 private currentSupplyFirstNFT;
    uint256 private currentSupplyBodyFat;
    uint256 private currentSupplyMuscleMass;
    
    // Mapping to track the token type //ERC721("MyFitnessNFT", "MFN")
    mapping(uint256 => string) private tokenTypes;

    constructor(address initialOwner) 
        ERC721("DynamicNFT", "MTK")
        Ownable(0x1B04132D7F2427cB160AB57d0829C48D93e3fc91) 
    {}

    function safeMint(address to, uint256 tokenId, string memory tokenType) public onlyOwner {
        require(keccak256(bytes(tokenType)) == keccak256(bytes("firstNFT")) && currentSupplyFirstNFT < MAX_SUPPLY_FIRST_NFT ||
                keccak256(bytes(tokenType)) == keccak256(bytes("bodyFat")) && currentSupplyBodyFat < MAX_SUPPLY_BODY_FAT ||
                keccak256(bytes(tokenType)) == keccak256(bytes("muscleMass")) && currentSupplyMuscleMass < MAX_SUPPLY_MUSCLE_MASS,
                "Max supply reached for this type");

        _safeMint(to, tokenId);
        tokenTypes[tokenId] = tokenType;
        
        if (keccak256(bytes(tokenType)) == keccak256(bytes("firstNFT"))) {
            _setTokenURI(tokenId, BASE_URI_FIRST_NFT);
            currentSupplyFirstNFT++;
        } else if (keccak256(bytes(tokenType)) == keccak256(bytes("bodyFat"))) {
            _setTokenURI(tokenId, BASE_URI_BODY_FAT);
            currentSupplyBodyFat++;
        } else if (keccak256(bytes(tokenType)) == keccak256(bytes("muscleMass"))) {
            _setTokenURI(tokenId, BASE_URI_MUSCLE_MASS);
            currentSupplyMuscleMass++;
        }
    }

    // Override functions required by Solidity
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
