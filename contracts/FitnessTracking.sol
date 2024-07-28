// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DynamicNFT.sol"; // Import your DynamicNFT contract

contract FitnessTracking {
    // User measurements parameters
    struct MeasurementParams {
        uint8 weight;
        uint8 BMI;
        uint8 bodyFat;
        uint8 fatFreeBodyWeight;
        uint8 subcutaneousFat;
        uint8 visceralFat;
        uint8 bodyWater;
        uint8 skeletalMuscle;
        uint8 muscleMass;
        uint8 boneMass;
        uint8 protein;
        uint8 BMR;
        uint8 metabolicAge;
    }

    // User measurements
    struct Measurement {
        uint8 weight;
        uint8 BMI;
        uint8 bodyFat;
        uint8 fatFreeBodyWeight;
        uint8 subcutaneousFat;
        uint8 visceralFat;
        uint8 bodyWater;
        uint8 skeletalMuscle;
        uint8 muscleMass;
        uint8 boneMass;
        uint8 protein;
        uint8 BMR;
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

    // Events
    event CoachAssigned(address indexed user, address indexed coach);
    event MeasurementLogged(address indexed user, Measurement measurement);
    event GoalCreated(address indexed user, Goal goal);
    event NFTMinted(address indexed user, string tokenURI);

    // Contract owner
    address public owner;
    DynamicNFT public nftContract; // Reference to the DynamicNFT contract

    constructor(address _nftContractAddress) {
        owner = msg.sender;
        nftContract = DynamicNFT(_nftContractAddress);
    }

    // Register new coach
    function addCoach(address _coachAddress, uint8 _coachId) external {
        require(msg.sender == owner, "You are not owner!!");
        coaches[_coachAddress] = Coach(_coachAddress, _coachId);
    }

    // Assign coach to user
    function assignCoach(address _user, address _coach) external {
        require(msg.sender == owner, "You are not owner!!");
        require(
            coaches[_coach].coachAddress != address(0),
            "Only registered coaches can be assigned."
        );
        userToCoach[_user] = _coach;
        emit CoachAssigned(_user, _coach);
    }

    // Register new measurement
    function logMeasurement(
        MeasurementParams memory params,
        address _user
    ) external {
        require(userToCoach[_user] == msg.sender);
        Measurement memory newMeasurement = Measurement({
            weight: params.weight,
            BMI: params.BMI,
            bodyFat: params.bodyFat,
            fatFreeBodyWeight: params.fatFreeBodyWeight,
            subcutaneousFat: params.subcutaneousFat,
            visceralFat: params.visceralFat,
            bodyWater: params.bodyWater,
            skeletalMuscle: params.skeletalMuscle,
            muscleMass: params.muscleMass,
            boneMass: params.boneMass,
            protein: params.protein,
            BMR: params.BMR,
            metabolicAge: params.metabolicAge,
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
