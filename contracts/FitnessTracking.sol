// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FitnessTracking {
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

  // events
  event CoachAssigned(address indexed user, address indexed coach);
  event MeasurementLogged(address indexed user, Measurement measurement);
  event GoalCreated(address indexed user, Goal goal);

  // contract owner
  address public owner;

  constructor() {
    owner = msg.sender;
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
    uint8 _fatFreeBodyWeight,
    uint8 _subcutaneousFat,
    uint8 _visceralFat,
    uint8 _bodyWater,
    uint8 _skeletalMuscle,
    uint8 _muscleMass,
    uint8 _boneMass,
    uint8 _protein,
    uint8 _BMR,
    uint8 _metabolicAge,
    address _user
  ) external {
    require(userToCoach[_user] == msg.sender);
    Measurement memory newMeasurement = Measurement({
      weight: _weight,
      BMI: _BMI,
      bodyFat: _bodyFat,
      fatFreeBodyWeight: _fatFreeBodyWeight,
      subcutaneousFat: _subcutaneousFat,
      visceralFat: _visceralFat,
      bodyWater: _bodyWater,
      skeletalMuscle: _skeletalMuscle,
      muscleMass: _muscleMass,
      boneMass: _boneMass,
      protein: _protein,
      BMR: _BMR,
      metabolicAge: _metabolicAge,
      date: block.timestamp
    });

    userMeasurements[_user].push(newMeasurement);
    emit MeasurementLogged(_user, newMeasurement);
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
