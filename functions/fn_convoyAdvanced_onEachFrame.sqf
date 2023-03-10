/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_onEachFrame

Description:
    Mananges an individual vehicle's position relative to the vehicle in front of
     it in a convoy. This function is what the statemachine runs each frame/vehicle.

    This function intentionally forgoes the use of several getter/setter functions 
     to reduce overhead because it runs every frame

Parameters:
    _this <OBJECT> - A convoy vehicle to be processed during the current frame

Returns:
    NOTHING

Examples:
    (begin example)
        SHOULD NOT BE CALLED DIRECTLY
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_onEachFrame";

#define POINT_COMPLETE_RADIUS 10
#define MIN_VEHICLE_SPEED_LIMIT_MODIFIER 5
#define MIN_VEHICLE_SPEED_LIMIT 5
#define VEHICLE_SPEED_LIMIT_MULTIPLIER 2.5
#define SMALL_SPEED_LIMIT_DISTANCE_MODIFIER 1.25
#define LEAD_VEHICLE_MAX_SPEED_TO_HALT_FOLLOW 2
#define VEHICLE_SHOULD_CATCH_UP_DISTANCE 100
#define SPEED_DIFFERENTIAL_LIMIT 20
#define MIN_CONVOY_SEPERATION 10

private _currentVehicle = _this;


private _convoyHashMap = _currentVehicle getVariable "KISKA_convoyAdvanced_hashMap";
private _convoyLead = _convoyHashMap get 0;
// private _stateMachine = _convoyHashMap get "_stateMachine";


/* ----------------------------------------------------------------------------
    Exit states
---------------------------------------------------------------------------- */
if !(canMove _currentVehicle) exitWith {
    private _function = _currentVehicle getVariable [
        "KISKA_convoyAdvanced_handleVehicleCantMove",
        KISKA_fnc_convoyAdvanced_handleVehicleCantMove_default
    ];

    [
        _currentVehicle,
        _convoyHashMap,
        _convoyLead
    ] call _function;
};

// TODO: it may make sense to attach this to a killed eventhandler instead
private _currentVehicle_driver = driver _currentVehicle;
if !(alive _currentVehicle_driver) exitWith {
    private _function = _currentVehicle getVariable [
        "KISKA_convoyAdvanced_handleDeadDriver",
        KISKA_fnc_convoyAdvanced_handleDeadDriver_default
    ];

    [
        _currentVehicle,
        _convoyHashMap,
        _convoyLead,
        _currentVehicle_driver
    ] call _function;
};	

if ((lifeState _currentVehicle_driver) == "INCAPACITATED") exitWith {
    private _function = _currentVehicle getVariable [
        "KISKA_convoyAdvanced_handleUnconciousDriver",
        KISKA_fnc_convoyAdvanced_handleUnconciousDriver_default
    ];

    [
        _currentVehicle,
        _convoyHashMap,
        _convoyLead,
        _currentVehicle_driver
    ] call _function;
};	

if ((_currentVehicle isEqualTo _convoyLead) OR !(alive _convoyLead)) exitWith {};




/* ----------------------------------------------------------------------------
    Setup
---------------------------------------------------------------------------- */
private _debug = _currentVehicle getVariable ["KISKA_convoyAdvanced_debug",false];
private ["_currentVehicle_debugDrivePathObjects","_currentVehicle_debugDeletedDrivePathObjects"];
if (_debug) then {
    _currentVehicle_debugDrivePathObjects = _currentVehicle getVariable "KISKA_convoyAdvanced_debug_followPathObjects";
};

// TODO: use the vehicle ahead to queue points off of here
// private _dynamicMovePoint = _currentVehicle getVariable "KISKA_convoyAdvanced_dynamicMovePoint";
// private _currentVehicle_index = _currentVehicle getVariable "KISKA_convoyAdvanced_index";
// private _vehicleAhead = _convoyHashMap get (_currentVehicle_index - 1);
// if !(isNil "_dynamicMovePoint") exitWith {
//     systemChat "Dynamic move point";
//     private _dynamicMovePoint_completionRadius = _currentVehicle getVariable ["KISKA_convoyAdvanced_dynamicMovePoint_completionRadius",5];
//     private _currentVehicle_position = getPosATLVisual _currentVehicle;
//     if ((_currentVehicle_position vectorDistance _dynamicMovePoint) <= _dynamicMovePoint_completionRadius) then {
//         systemChat "KISKA_convoyAdvanced_dynamicMovePoint set to nil";
//         _currentVehicle setVariable ["KISKA_convoyAdvanced_dynamicMovePoint",nil];
//     };

//     private _vehicleAhead_position = getPosATLVisual _vehicleAhead;
//     private _currentVehicle_drivePath = _currentVehicle getVariable "KISKA_convoyAdvanced_drivePath";
//     private _lastestPointToDriveTo = [_currentVehicle_drivePath] call KISKA_fnc_selectLastIndex;
//     if (isNil "_lastestPointToDriveTo") exitWith {
//         _queuedPoints pushBack _vehicleAhead_position;
//     };

//     private _vehicleAhead_distanceToLastDrivePoint = _vehicleAhead_position vectorDistance _lastestPointToDriveTo;
//     private _minBufferBetweenPoints = _convoyHashMap get "_minBufferBetweenPoints";
//     if (_vehicleAhead_distanceToLastDrivePoint <= _minBufferBetweenPoints) exitWith {};

//     _queuedPoints pushBack _vehicleAhead_position;
// };


private _currentVehicle_drivePath = _currentVehicle getVariable "KISKA_convoyAdvanced_drivePath";
if (isNil "_currentVehicle_drivePath") then {
    _currentVehicle_drivePath = [];
    _currentVehicle setVariable ["KISKA_convoyAdvanced_drivePath",_currentVehicle_drivePath];

    if (_debug) then {
        _currentVehicle_debugDeletedDrivePathObjects = [];
        _currentVehicle setVariable ["KISKA_convoyAdvanced_debug_followedPathObjects",_currentVehicle_debugDeletedDrivePathObjects];
        _currentVehicle_debugDrivePathObjects = [];
        _currentVehicle setVariable ["KISKA_convoyAdvanced_debug_followPathObjects",_currentVehicle_debugDrivePathObjects];
    };
};


private _continue = false;
/* ----------------------------------------------------------------------------
    Handle speed
---------------------------------------------------------------------------- */
private _currentVehicle_index = _currentVehicle getVariable "KISKA_convoyAdvanced_index";
private _vehicleAhead = _convoyHashMap get (_currentVehicle_index - 1);

private _currentVehicle_frontBumperPosition = [_currentVehicle,false] call KISKA_fnc_convoyAdvanced_getBumperPosition;
private _vehicleAhead_rearBumperPosition = [_vehicleAhead,true] call KISKA_fnc_convoyAdvanced_getBumperPosition;
private _distanceBetweenVehicles = _currentVehicle_frontBumperPosition vectorDistance _vehicleAhead_rearBumperPosition;

private _vehicleAhead_speed = speed _vehicleAhead;
private _currentVehicle_seperation = (_currentVehicle getVariable ["KISKA_convoyAdvanced_seperation",20]) max MIN_CONVOY_SEPERATION;
private _vehiclesAreWithinBoundary = _distanceBetweenVehicles < _currentVehicle_seperation;

private _currentVehicle_isStopped = _currentVehicle getVariable ["KISKA_convoyAdvanced_isStopped",false];
private _vehicleAhead_isStopped = _vehicleAhead_speed <= LEAD_VEHICLE_MAX_SPEED_TO_HALT_FOLLOW;
private _currentVehicle_shouldBeStopped = _vehicleAhead_isStopped AND _vehiclesAreWithinBoundary;

if (_currentVehicle_isStopped) then {
    if (_currentVehicle_shouldBeStopped) exitWith { _continue = true; };
    
    _currentVehicle setVariable ["KISKA_convoyAdvanced_isStopped",false];
    if !(_currentVehicle_driver checkAIFeature "path") then {
        _currentVehicle_driver enableAI "path";
    };
    
} else {
    if !(_currentVehicle_shouldBeStopped) exitWith {};
        
    if (_debug) then {
        private _currentVehicle_speed = speed _currentVehicle;
        hint str ["In Halt",_currentVehicle_speed,_distanceBetweenVehicles];
    };

    _currentVehicle setVariable ["KISKA_convoyAdvanced_isStopped",true];
    [_currentVehicle] call KISKA_fnc_convoyAdvanced_stopVehicle;

    _continue = true;
};

if (_continue) exitWith {};


/* ---------------------------------
    Force speed based on distance
--------------------------------- */
private _currentVehicle_speed = speed _currentVehicle;
if (_vehiclesAreWithinBoundary) then {
    private _modifier = ((_currentVehicle_seperation - _distanceBetweenVehicles) * VEHICLE_SPEED_LIMIT_MULTIPLIER) max MIN_VEHICLE_SPEED_LIMIT_MODIFIER;
    private _speedLimit = (_vehicleAhead_speed - _modifier) max MIN_VEHICLE_SPEED_LIMIT;
    _currentVehicle limitSpeed _speedLimit;
    
    if (_debug) then {
        hint ([
            "limit speed",endl,
            "Current Vehicle Speed: ", _currentVehicle_speed, endl,
            "Current Speed Limit: ", _speedLimit, endl,
            "Distance between: ", _distanceBetweenVehicles
        ] joinString "");
    };

} else {
    private _distanceToLimitToVehicleAheadSpeed = _currentVehicle_seperation * SMALL_SPEED_LIMIT_DISTANCE_MODIFIER;
    if (_distanceBetweenVehicles < _distanceToLimitToVehicleAheadSpeed) exitWith {
        if (_debug) then {
            hint "un limit small";
        };

        private _speedToLimitTo = [_vehicleAhead_speed,5] select _vehicleAhead_isStopped;
        _currentVehicle limitSpeed _speedToLimitTo;
    };

    if (_distanceBetweenVehicles > VEHICLE_SHOULD_CATCH_UP_DISTANCE) exitWith { 
        if (_debug) then {
            hint "un limit";
        };
        _currentVehicle limitSpeed -1 
    };
    
    private _speedDifferential = abs (_currentVehicle_speed - _vehicleAhead_speed);
    if (_speedDifferential > SPEED_DIFFERENTIAL_LIMIT) exitWith {
        if (_debug) then {
            hint str ["Limit by differential",_currentVehicle_speed,_distanceBetweenVehicles];
        };

        _currentVehicle limitSpeed _distanceBetweenVehicles;
    };
    
    if (_debug) then {
        hint str ["un limit generic",_distanceBetweenVehicles];
    };
    _currentVehicle limitSpeed -1;
};


/* ----------------------------------------------------------------------------
    Delete old points
---------------------------------------------------------------------------- */
private _currentVehicle_position = getPosATLVisual _currentVehicle;
private _deleteStartIndex = -1;
private _numberToDelete = 0;
{
    private _pointReached = (_currentVehicle_position vectorDistance _x) <= POINT_COMPLETE_RADIUS;

    if !(_pointReached) then { break };
    _numberToDelete = _numberToDelete + 1;

    private _deleteStartIndexDefined = _deleteStartIndex isNotEqualTo -1;
    if (_deleteStartIndexDefined) then { continue };
    _deleteStartIndex = _forEachIndex;

} forEach _currentVehicle_drivePath;

private _pointsCanBeDeleted = (_deleteStartIndex >= 0) AND (_numberToDelete > 0);
if (_pointsCanBeDeleted) then {
    _currentVehicle_drivePath deleteRange [_deleteStartIndex,_numberToDelete];

    if (_debug) then {
        private _lastIndexToDelete = _deleteStartIndex + (_numberToDelete - 1);
        private _debugObjectType = _currentVehicle getVariable ["KISKA_convoyAdvanced_debugMarkerType_deletedPoint","Sign_Arrow_Large_blue_F"];
        private _deletedPointMarker = createVehicle [_debugObjectType, _currentVehicle_position, [], 0, "CAN_COLLIDE"];
        _currentVehicle_debugDeletedDrivePathObjects pushBack _deletedPointMarker;

        for "_i" from _deleteStartIndex to _lastIndexToDelete do { 
            deleteVehicle (_currentVehicle_debugDrivePathObjects select _i);
        };
        _currentVehicle_debugDrivePathObjects deleteRange [_deleteStartIndex,_numberToDelete];
    };
};


/* ----------------------------------------------------------------------------
    Handle queued points
---------------------------------------------------------------------------- */
private _queuedPoints = _currentVehicle getVariable ["KISKA_convoyAdvanced_queuedPoints",[]];
if (_queuedPoints isNotEqualTo []) exitWith {

    if (_currentVehicle getVariable ["KISKA_convoyAdvanced_doDriveOnPath",true]) then {
        private _indexInserted = -1;
        _queuedPoints apply {
            if ((_currentVehicle_position vectorDistance _x) <= POINT_COMPLETE_RADIUS) then {continue};

            if (_debug) then {
                private _debugObjectType = _currentVehicle getVariable [
                    "KISKA_convoyAdvanced_debugMarkerType_queuedPoint",
                    "Sign_Arrow_Large_Cyan_F"
                ];
                private _debugObject = createVehicle [_debugObjectType, _x, [], 0, "CAN_COLLIDE"];
                _currentVehicle_debugDrivePathObjects pushBack _debugObject;
            };

            _indexInserted = _currentVehicle_drivePath pushBack _x;
        };

        // vehicle need at least two points for setDriveOnPath to work
        if (_indexInserted >= 1) then {
            _currentVehicle setDriveOnPath _currentVehicle_drivePath;
        };

        _currentVehicle setVariable ["KISKA_convoyAdvanced_queuedPoints",[]];

    } else {
        private _vehicleToFollow = _currentVehicle getVariable ["KISKA_convoyAdvanced_vehicleToFollow",_convoyLead];
        private _lastQueuedPoint = [_queuedPoints] call KISKA_fnc_selectLastIndex;
        private _vehicleToFollow_position = getPosATLVisual _vehicleToFollow;
        private _vehicleToFollow_distanceToLastQueuedPoint = _vehicleToFollow_position vectorDistance _lastQueuedPoint;
        private _minBufferBetweenPoints = _convoyHashMap get "_minBufferBetweenPoints";
        if (_vehicleToFollow_distanceToLastQueuedPoint <= _minBufferBetweenPoints) exitWith {};

        _queuedPoints pushBack _vehicleToFollow_position;

    };

};


/* ----------------------------------------------------------------------------
    Add Queued point if needed
---------------------------------------------------------------------------- */
// private _currentVehicle_lastQueuedTime = _currentVehicle getVariable ["KISKA_convoy_queuedTime",-1];
// private _pointHasBeenQueued = _currentVehicle_lastQueuedTime isNotEqualTo -1;
// private _updateFrequency = 0;
// private _time = time;
// if (
//     _pointHasBeenQueued AND 
//     !((_time - _currentVehicle_lastQueuedTime) >= _updateFrequency)
// ) exitWith {};

// _currentVehicle setVariable ["KISKA_convoy_queuedTime",_time];



/* ----------------------------------------------------------------------------
    Only Queue points that aren't too close together
---------------------------------------------------------------------------- */
// Vehicles follow convoy lead by default as following the vehicle directly ahead
/// makes the path precision decrease linearly as the convoy grows.
// Meaning if one vehicle barely clips a building but makes it past, 
/// the next vehicle will run directly into the building

private _vehicleToFollow = _currentVehicle getVariable ["KISKA_convoyAdvanced_vehicleToFollow",_convoyLead];
private _vehicleToFollow_position = getPosATLVisual _vehicleToFollow;
private _lastestPointToDriveTo = [_currentVehicle_drivePath] call KISKA_fnc_selectLastIndex;
if (isNil "_lastestPointToDriveTo") exitWith {
    _queuedPoints pushBack _vehicleToFollow_position;
};

private _vehicleToFollow_distanceToLastDrivePoint = _vehicleToFollow_position vectorDistance _lastestPointToDriveTo;
private _minBufferBetweenPoints = _convoyHashMap get "_minBufferBetweenPoints";
if (_vehicleToFollow_distanceToLastDrivePoint <= _minBufferBetweenPoints) exitWith {};

_queuedPoints pushBack _vehicleToFollow_position;
