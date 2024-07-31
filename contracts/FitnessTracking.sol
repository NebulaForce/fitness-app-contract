// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./DynamicNFT.sol"; // Import your DynamicNFT contract

contract FitnessTracking {

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
        uint8 targetBodyFatPercentage;
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

    // events
    event CoachAssigned(address indexed user, address indexed coach);
    event MeasurementLogged(address indexed user, Measurement measurement);
    event GoalCreated(address indexed user, Goal goal);
    event NFTMinted(address indexed user, string tokenURI);

    // contract owner
    address public owner;
    // DynamicNFT private nftContract; // Reference to the DynamicNFT contract

    constructor() {
        owner = msg.sender;
        // nftContract = DynamicNFT(_nftContractAddress);
    }

    // Register new coach
    function addCoach(address _coachAddress, string memory _name, string memory _email) external {
      require(msg.sender == owner, "You are not owner!!");
      coaches[_coachAddress] = Coach(_name, _email);
    }

    // Register user
    function register(string memory _name, string memory _email) external {
      users[msg.sender] = User(_name, _email);

      // Mint initial NFT for the user
    //   string memory initialTokenURI = "ipfs://<initial-metadata-uri>";
    //   nftContract.mint(msg.sender, initialTokenURI);
    }

    // Assign coach to user
    function assignCoach(address _user, address _coach) external {
        require(msg.sender == owner, "You are not owner!!");
        require(
            bytes(coaches[_coach].name).length > 0,
            "Only registered coaches can be assigned."
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
            date: block.timestamp
        });

        userMeasurements[_user].push(newMeasurement);
        emit MeasurementLogged(_user, newMeasurement);
        
        // Check and update NFT based on user goals
        // checkAndUpdateNFT(_user);
    }

    // Check if the user has achieved their goals and mint an NFT
    // function checkAndUpdateNFT(address _user) internal {
    //     Goal memory goal = userGoals[_user];
    //     Measurement[] memory measurements = userMeasurements[_user];
    //     Measurement memory latestMeasurement = measurements[measurements.length - 1];

    //     // Check for body fat percentage goal achievement
    //     if (latestMeasurement.bodyFat <= goal.targetBodyFatPercentage) {
    //         nftContract.safeMint(_user, 1, "https://gateway.pinata.cloud/ipfs/QmVHh4fCDcqa4MGjYnJP4n4kyKFy4v4RavefGDfg7er237");
    //         emit NFTMinted(_user, "https://gateway.pinata.cloud/ipfs/QmVHh4fCDcqa4MGjYnJP4n4kyKFy4v4RavefGDfg7er237");

    //         // Update the NFT metadata
    //         // nftContract.updateTokenURI(0, updatedTokenURI);
    //     }

    //     // Check for muscle mass percentage goal achievement
    //     if (latestMeasurement.muscleMass >= goal.targetMuscleMass) {
    //         nftContract.safeMint(_user, 2, "https://gateway.pinata.cloud/ipfs/QmPqqvsyi7L3R3JF3RZGX3S25UtFWC27763S5HPr8EHWxX");
    //         emit NFTMinted(_user, "https://gateway.pinata.cloud/ipfs/QmPqqvsyi7L3R3JF3RZGX3S25UtFWC27763S5HPr8EHWxX");
    //     }
    // }

    // Create user goal
    function setGoal(
        uint8 _targetBodyFatPercentage,
        uint8 _targetMuscleMass,
        address _user
    ) external {
        require(userToCoach[_user] == msg.sender);
        require(
            _targetBodyFatPercentage > 0 && _targetMuscleMass > 0,
            "Invalid goal values."
        );
        require(
            userMeasurements[_user].length > 0,
            "User must have logged measurements before setting a goal."
        );
        userGoals[_user] = Goal({
            targetBodyFatPercentage: _targetBodyFatPercentage,
            targetMuscleMass: _targetMuscleMass
        });
        emit GoalCreated(
            _user,
            Goal(_targetBodyFatPercentage, _targetMuscleMass)
        );
    }

    // Get user measurements
    function getMeasurements(
        address _user
    ) external view returns (Measurement[] memory) {
        require(userToCoach[_user] == msg.sender || _user == msg.sender);
        return userMeasurements[_user];
    }
}
