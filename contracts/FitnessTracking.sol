// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DynamicNFT.sol"; // Import your DynamicNFT contract

contract FitnessTracking {

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

    // contract owner
    address public owner;
    DynamicNFT private nftContract; // Reference to the DynamicNFT contract

    constructor(address _nftContractAddress) {
        owner = msg.sender;
        nftContract = DynamicNFT(_nftContractAddress);
    }

    // Register new coach
    function addCoach(address _coachAddress, uint8 _coachId) external {
      require(msg.sender == owner, "You are not owner!!");
      coaches[_coachAddress] = Coach(_coachAddress, _coachId);
    }

    // Register user
    function register() external {
      users.push(msg.sender);
      userToCoach[msg.sender] = address(0);
    }

    // Assign coach to user
    function assignCoach(address _user, address _coach) external {
        require(msg.sender == owner, "You are not owner!!");
        require(
            coaches[_coach].coachAddress != address(0),
            "Only registered coaches can be assign."
        );
        userToCoach[_user] = _coach;
        emit CoachAssigned(_user, _coach);
    }

    // Register new measurement
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
        require(userToCoach[_user] == msg.sender);
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

    // Create user goal
    function setGoal(
        uint8 _targetBodyFatPercent,
        uint8 _targetMuscleMassPercent,
        address _user
    ) external {
        require(userToCoach[_user] == msg.sender);
        userGoals[_user] = Goal({
            targetBodyFatPercent: _targetBodyFatPercent,
            targetMuscleMassPercent: _targetMuscleMassPercent
        });
        emit GoalCreated(
            _user,
            Goal(_targetBodyFatPercent, _targetMuscleMassPercent)
        );
    }

    // Check if the user has achieved their goals and mint an NFT
    function checkAndMintNFT(address _user) internal {
        Goal memory goal = userGoals[_user];
        Measurement[] memory measurements = userMeasurements[_user];
        Measurement memory latestMeasurement = measurements[measurements.length - 1];

        // Check for body fat percentage goal achievement
        if (latestMeasurement.bodyFat <= goal.targetBodyFatPercent) {
            nftContract.safeMint(_user, 1, "https://gateway.pinata.cloud/ipfs/QmVHh4fCDcqa4MGjYnJP4n4kyKFy4v4RavefGDfg7er237");
            emit NFTMinted(_user, "https://gateway.pinata.cloud/ipfs/QmVHh4fCDcqa4MGjYnJP4n4kyKFy4v4RavefGDfg7er237");
        }

        // Check for muscle mass percentage goal achievement
        if (latestMeasurement.muscleMass >= goal.targetMuscleMassPercent) {
            nftContract.safeMint(_user, 2, "https://gateway.pinata.cloud/ipfs/QmPqqvsyi7L3R3JF3RZGX3S25UtFWC27763S5HPr8EHWxX");
            emit NFTMinted(_user, "https://gateway.pinata.cloud/ipfs/QmPqqvsyi7L3R3JF3RZGX3S25UtFWC27763S5HPr8EHWxX");
        }
    }

    // Get user measurements
    function getMeasurements(
        address _user
    ) external view returns (Measurement[] memory) {
        require(userToCoach[_user] == msg.sender || _user == msg.sender);
        return userMeasurements[_user];
    }

    // Get user goals
    function getGoal(address _user) external view returns (Goal memory) {
        require(userToCoach[_user] == msg.sender || _user == msg.sender);
        return userGoals[_user];
    }
}
