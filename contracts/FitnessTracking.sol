// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DynamicNFT.sol";

contract FitnessTracking is Ownable {

    // User measurements
    struct Measurement {
        uint8 weight;
        uint8 BMI;
        uint8 bodyFat;
        uint8 visceralFat;
        uint8 bodyWater;
        uint8 muscleMass;
        uint256 date;
    }

    // User goals
    struct Goal {
        uint8 initialBodyFatPercentage;
        uint8 targetBodyFatPercentage;
        uint8 initialMuscleMass;
        uint8 targetMuscleMass;
    }

    // Coach data
    struct Coach {
        string name;
        string email;
    }

    // User data
    struct User {
        string name;
        string email;
    }

    // Users and coaches mappings
    mapping(address => Coach) public coaches;
    mapping(address => User) public users;
    mapping(address => address) public userToCoach;
    mapping(address => Measurement[]) public userMeasurements;
    mapping(address => Goal) public userGoals;

    // Events
    event CoachAssigned(address indexed user, address indexed coach);
    event MeasurementLogged(address indexed user, Measurement measurement);
    event GoalCreated(address indexed user, Goal goal);
    event NFTMinted(address indexed user, string tokenURI);

    // Reference to the DynamicNFT contract
    DynamicNFT private nftContract;

    // Constructor
    constructor(address _nftContractAddress, address _initialOwner) Ownable(_initialOwner) {
        nftContract = DynamicNFT(_nftContractAddress);
    }

    // Register new coach
    function addCoach(address _coachAddress, string memory _name, string memory _email) external onlyOwner {
        coaches[_coachAddress] = Coach(_name, _email);
    }

    // Register user
    function register(string memory _name, string memory _email) external {
        users[msg.sender] = User(_name, _email);
    }

    // Once the coach is assigned to the user, the firstNFT is minted to the user
    function assignCoach(address _user, address _coach) external onlyOwner {
        require(
            bytes(coaches[_coach].name).length > 0 && bytes(coaches[_coach].email).length > 0,
            "Only registered coaches can be assigned."
        );

        userToCoach[_user] = _coach;
        emit CoachAssigned(_user, _coach);

        // Mint the first NFT for the user
        uint256 tokenId = nftContract.getCurrentSupplyFirstNFT() + 1;
        require(tokenId <= nftContract.MAX_SUPPLY_FIRST_NFT(), "Max supply reached for firstNFT");

        nftContract.safeMint(_user, tokenId, "firstNFT");

        // Emit the NFTMinted event with the correct token URI
        emit NFTMinted(_user, nftContract.tokenURI(tokenId));
    }

    // Log a new measurement and check for NFT minting
    function logMeasurement(
        uint8 _weight,
        uint8 _BMI,
        uint8 _bodyFat,
        uint8 _visceralFat,
        uint8 _bodyWater,
        uint8 _muscleMass,
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
            date: block.timestamp
        });

        userMeasurements[_user].push(newMeasurement);
        emit MeasurementLogged(_user, newMeasurement);

        // Retrieve the user's goals
        Goal memory goal = userGoals[_user];

        // Check for body fat percentage goal achievement
        if (_bodyFat <= goal.targetBodyFatPercentage) {
            uint256 tokenId = nftContract.getCurrentSupplyBodyFat() + 1; // Generate a new token ID
            require(tokenId <= nftContract.MAX_SUPPLY_BODY_FAT(), "Max supply reached for bodyFat");
            nftContract.safeMint(_user, tokenId, "bodyFat");
            emit NFTMinted(_user, nftContract.tokenURI(tokenId));
        }

        // Check for muscle mass percentage goal achievement
        if (_muscleMass >= goal.targetMuscleMass) {
            uint256 tokenId = nftContract.getCurrentSupplyMuscleMass() + 1; // Generate a new token ID
            require(tokenId <= nftContract.MAX_SUPPLY_MUSCLE_MASS(), "Max supply reached for muscleMass");
            nftContract.safeMint(_user, tokenId, "muscleMass");
            emit NFTMinted(_user, nftContract.tokenURI(tokenId));
        }
    }

    // Set user goals
    function setGoal(
        uint8 _targetBodyFatPercentage,
        uint8 _targetMuscleMass,
        address _user
    ) external {
        require(userToCoach[_user] == msg.sender, "Unauthorized");
        require(
            _targetBodyFatPercentage > 0 && _targetMuscleMass > 0,
            "Invalid goal values."
        );

        Measurement[] memory measurements = userMeasurements[_user];

        // Ensure there is at least one measurement
        require(measurements.length > 0, "No measurements available");

        Measurement memory latestMeasurement = measurements[measurements.length - 1];

        userGoals[_user] = Goal({
            initialBodyFatPercentage: latestMeasurement.bodyFat,
            targetBodyFatPercentage: _targetBodyFatPercentage,
            initialMuscleMass: latestMeasurement.muscleMass,
            targetMuscleMass: _targetMuscleMass
        });
        emit GoalCreated(
            _user,
            Goal(latestMeasurement.bodyFat, _targetBodyFatPercentage, latestMeasurement.muscleMass, _targetMuscleMass)
        );
    }

    // Get user measurements
    function getLatestMeasurement(
        address _user
    ) external view returns (Measurement memory) {

        // Retrieve the measurements for the user
        Measurement[] memory measurements = userMeasurements[_user];

        // Ensure there is at least one measurement
        require(measurements.length > 0, "No measurements available");

        // Return the latest measurement
        return measurements[measurements.length - 1];
    }
}
