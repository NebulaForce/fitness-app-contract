// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FitnessTracking {

    // Estructura para los datos del usuario
    struct Measurement {
        uint8 weight; //peso
        uint8 BMI; // indice de masa corporal
        uint8 bodyFat; // grasa
        uint8 fatFreeBodyWeight; 
        uint8 subcutaneousFat; //grasa subcutea
        uint8 visceralFat; //visceral grasa
        uint8 bodyWater; //agua corporal
        uint8 skeletalMuscle; // musculo esqueletico
        uint8 muscleMass; //masa muscular
        uint8 boneMass; // masa osea
        uint8 protein; // proteina
        uint8 BMR; // cantidad de energia que el cuerpo necesita
        uint8 metabolicAge; // edad metabolica
        uint8 date; // fecha 
    }

    // Estructura para los objetivos del usuario
    struct Goal {
        uint8 targetBodyFatPercent;
        uint8 targetMuscleMassPercent;
    }

    // Estructura para el coach
    struct Coach {
        address coachAddress;
        uint8 coachId;
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
   
    address public owner;

     constructor(){
        owner = msg.sender;
    }
    //Inicio de funciones
    // Agregar un coach
    function addCoach(address _coachAddress, uint8 _coachId) external {
        require(msg.sender == owner, "You are not owner!!");
        coaches[_coachAddress] = Coach(_coachAddress, _coachId);
    }

    // Asignar un coach a un usuario
    function assignCoach(address _user, address _coach) external {
        require(msg.sender == owner, "You are not owner!!");
        require(coaches[_coach].coachAddress != address(0), "Only registered coaches can be assign.");
        userToCoach[_user] = _coach;
        emit CoachAssigned(_user, _coach);
    }

    // Registrar mediciones del usuario
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
        address  _user
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

    // Actualizar el objetivo del usuario
    function setGoal(uint8 _targetBodyFatPercent, uint8 _targetMuscleMassPercent, address _user) external {
       require(userToCoach[_user] == msg.sender);
        userGoals[_user] = Goal({
            targetBodyFatPercent: _targetBodyFatPercent,
            targetMuscleMassPercent: _targetMuscleMassPercent
        });
        emit GoalUpdated(_user, Goal(_targetBodyFatPercent, _targetMuscleMassPercent));
    }

    // Función para obtener mediciones del usuario
    function getMeasurements(address _user) external view returns (Measurement[] memory) {
        require(userToCoach[_user] == msg.sender || _user == msg.msg.sender);
        return userMeasurements[_user];
    }

    // Función para obtener el objetivo del usuario
    function getGoal(address _user) external view returns (Goal memory) {
        require(userToCoach[_user] == msg.sender || _user == msg.msg.sender);
        return userGoals[_user];
    }
}
