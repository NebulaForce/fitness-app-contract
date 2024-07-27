// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FitnessTracking {

    // Estructura para los datos del usuario
    struct Measurement {
        uint256 weight;
        uint256 BMI;
        uint256 bodyFat;
        uint256 fatFreeBodyWeight;
        uint256 subcutaneousFat;
        uint256 visceralFat;
        uint256 bodyWater;
        uint256 skeletalMuscle;
        uint256 muscleMass;
        uint256 boneMass;
        uint256 protein;
        uint256 BMR;
        uint256 metabolicAge;
        uint256 date;
    }

    // Estructura para los objetivos del usuario
    struct Goal {
        uint256 targetBodyFatPercent;
        uint256 targetMuscleMassPercent;
    }

    // Estructura para el coach
    struct Coach {
        address coachAddress;
        uint256 coachId;
    }

    // Mappings para usuarios y coaches
    mapping(address => Coach) public coaches;
    mapping(address => address) public userToCoach;
    mapping(address => Measurement[]) public userMeasurements;
    mapping(address => Goal) public userGoals;

    // Eventos para registrar cambios
    event CoachAssigned(address indexed user, address indexed coach);
    event MeasurementLogged(address indexed user, Measurement measurement);
    event GoalUpdated(address indexed user, Goal goal);
    
    // Agregar un coach
    function addCoach(address _coachAddress, uint256 _coachId) external {
      //
        coaches[_coachAddress] = Coach(_coachAddress, _coachId);
    }

    // Asignar un coach a un usuario
    function assignCoach(address _user) external {
        require(coaches[msg.sender].coachAddress != address(0), "Only registered coaches can assign.");
        userToCoach[_user] = msg.sender;
        emit CoachAssigned(_user, msg.sender);
    }

    // Registrar mediciones del usuario
    function logMeasurement(
        uint256 _weight,
        uint256 _BMI,
        uint256 _bodyFat,
        uint256 _fatFreeBodyWeight,
        uint256 _subcutaneousFat,
        uint256 _visceralFat,
        uint256 _bodyWater,
        uint256 _skeletalMuscle,
        uint256 _muscleMass,
        uint256 _boneMass,
        uint256 _protein,
        uint256 _BMR,
        uint256 _metabolicAge
    ) external {
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

        userMeasurements[msg.sender].push(newMeasurement);
        emit MeasurementLogged(msg.sender, newMeasurement);
    }

    // Actualizar el objetivo del usuario
    function setGoal(uint256 _targetBodyFatPercent, uint256 _targetMuscleMassPercent) external {
      //require
        userGoals[msg.sender] = Goal({
            targetBodyFatPercent: _targetBodyFatPercent,
            targetMuscleMassPercent: _targetMuscleMassPercent
        });
        emit GoalUpdated(msg.sender, Goal(_targetBodyFatPercent, _targetMuscleMassPercent));
    }

    // Función para obtener mediciones del usuario
    function getMeasurements(address _user) external view returns (Measurement[] memory) {
        return userMeasurements[_user];
    }

    // Función para obtener el objetivo del usuario
    function getGoal(address _user) external view returns (Goal memory) {
        return userGoals[_user];
    }
}
