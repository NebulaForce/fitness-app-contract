// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the combined contract
contract FitnessMerged is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
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
    
    // Mapping to track the token type
    mapping(uint256 => string) private tokenTypes;
    
    // User measurements
    struct Measurement {
        uint8 weight;
        uint8 BMI;
        uint8 bodyFat;
        uint8 visceralFat;
        uint8 bodyWater;
        uint8 muscleMass;
        uint8 metabolicAge;
        uint256 date;
    }

    // User goals
    struct Goal {
        uint8 targetBodyFatPercent;
        uint8 targetMuscleMassPercent;
    }

    // Coach data
    struct Coach {
        address coachAddress;
        uint8 coachId;
    }

    // Users and coaches mappings
    mapping(address => Coach) public coaches;
    mapping(address => address) public userToCoach;
    mapping(address => Measurement[]) public userMeasurements;
    mapping(address => Goal) public userGoals;

    address[] public users; // Track all users

    // events
    event CoachAssigned(address indexed user, address indexed coach);
    event MeasurementLogged(address indexed user, Measurement measurement);
    event GoalCreated(address indexed user, Goal goal);
    event NFTMinted(address indexed user, string tokenURI);

    constructor(address initialOwner) 
        ERC721("FitnessMerged", "MFN") 
        Ownable(0x1B04132D7F2427cB160AB57d0829C48D93e3fc91) 
    {}


    // Register user
        function register() external {
        users.push(msg.sender);
        userToCoach[msg.sender] = address(0);
    }

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

    function logMeasurement(
        uint8 _weight,
        uint8 _BMI,
        uint8 _bodyFat,
        uint8 _visceralFat,
        uint8 _bodyWater,
        uint8 _muscleMass,
        uint8 _metabolicAge,
        address _user
    ) external {
        require(userToCoach[_user] == msg.sender, "Unauthorized");
        Measurement memory newMeasurement = Measurement({
            weight: _weight,
            BMI: _BMI,
            bodyFat: _bodyFat,
            visceralFat: _visceralFat,
            bodyWater: _bodyWater,
            muscleMass: _muscleMass,
            metabolicAge: _metabolicAge,
            date: block.timestamp
        });

        userMeasurements[_user].push(newMeasurement);
        emit MeasurementLogged(_user, newMeasurement);
        
        // Check if the user has achieved their goals and mint an NFT
        checkAndMintNFT(_user);
    }

    function setGoal(
        uint8 _targetBodyFatPercent,
        uint8 _targetMuscleMassPercent,
        address _user
    ) external {
        require(userToCoach[_user] == msg.sender, "Unauthorized");
        userGoals[_user] = Goal({
            targetBodyFatPercent: _targetBodyFatPercent,
            targetMuscleMassPercent: _targetMuscleMassPercent
        });
        emit GoalCreated(
            _user,
            Goal(_targetBodyFatPercent, _targetMuscleMassPercent)
        );
    }

function checkAndMintNFT(address _user) internal {
    Goal memory goal = userGoals[_user];
    Measurement[] memory measurements = userMeasurements[_user];
    Measurement memory latestMeasurement = measurements[measurements.length - 1];

    uint256 tokenId;

    // Check for body fat percentage goal achievement
    if (latestMeasurement.bodyFat <= goal.targetBodyFatPercent) {
        tokenId = currentSupplyBodyFat + 1; // Generate a new token ID
        require(tokenId <= MAX_SUPPLY_BODY_FAT, "Max supply reached for bodyFat");
        safeMint(_user, tokenId, "bodyFat");
        emit NFTMinted(_user, BASE_URI_BODY_FAT);
        currentSupplyBodyFat++;
    }

    // Check for muscle mass percentage goal achievement
    if (latestMeasurement.muscleMass >= goal.targetMuscleMassPercent) {
        tokenId = currentSupplyMuscleMass + 1; // Generate a new token ID
        require(tokenId <= MAX_SUPPLY_MUSCLE_MASS, "Max supply reached for muscleMass");
        safeMint(_user, tokenId, "muscleMass");
        emit NFTMinted(_user, BASE_URI_MUSCLE_MASS);
        currentSupplyMuscleMass++;
    }
}

    function addCoach(address _coachAddress, uint8 _coachId) external onlyOwner {
        coaches[_coachAddress] = Coach(_coachAddress, _coachId);
    }

    //Once the coach is assigned to the user, the firstNFT is minted to the user
    function assignCoach(address _user, address _coach) external onlyOwner {
    require(
        coaches[_coach].coachAddress != address(0),
        "Only registered coaches can be assigned."
    );
    
    userToCoach[_user] = _coach;
    emit CoachAssigned(_user, _coach);
    
    // Mint the first NFT for the user
    uint256 tokenId = currentSupplyFirstNFT + 1; // Generate a new token ID
    require(tokenId <= MAX_SUPPLY_FIRST_NFT, "Max supply reached for firstNFT");

    safeMint(_user, tokenId, "firstNFT");
    emit NFTMinted(_user, BASE_URI_FIRST_NFT);
}

    function getMeasurements(address _user) external view returns (Measurement[] memory) {
        require(userToCoach[_user] == msg.sender || _user == msg.sender, "Unauthorized");
        return userMeasurements[_user];
    }

    function getGoal(address _user) external view returns (Goal memory) {
        require(userToCoach[_user] == msg.sender || _user == msg.sender, "Unauthorized");
        return userGoals[_user];
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
