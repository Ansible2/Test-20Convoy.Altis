#define FOLLOW_DISTANCE 20
#define CLEARANCE_TO_QUEUED_POINT 0.5
#define SPEED_LIMIT_MODIFIER 10
#define MIN_BUFFER_BETWEEN_POINTS 0.01

KISKA_fnc_selectLastIndex = {
    params [
        ["_array",[],[[]]],
        ["_defaultValue",nil,[]]
    ];

    private _arrayCount = count _array;
    _array param [(_arrayCount - 1),_defaultValue];
};



params ["_vics"];

if (_vics isEqualTo []) exitWith {
    ["_vics is empty array",true] call KISKA_fnc_log;
    nil
};

private _stateMachine = [
    _vics,
    true
] call CBA_stateMachine_fnc_create;

private _convoyHashMap = createHashMap;
_convoyHashMap set ["_stateMachine",_stateMachine];
_convoyHashMap set ["_convoyLead",_vics select 0];
_convoyHashMap set ["_convoyVehicles",_vics];
localNamespace setVariable ["KISKA_convoy_vehicleRelativeRear",createHashMap];
localNamespace setVariable ["KISKA_convoy_vehicleRelativeFront",createHashMap];

{
    _x setVariable ["KISKA_convoy_hashMap",_convoyHashMap];
    if (_forEachIndex isEqualTo 0) then { continue };

    _x setVariable ["KISKA_convoy_vehicleAhead",_vics select (_forEachIndex - 1)];
} forEach _vics;

// TODO
// Current problem:
// The path a vehicle takes needs more precision
// this can be accomplished with more points in the drive path
// This should be done by allowing more than one point to be queued at any time
// however, ensure that there is still a distance between points enforced
// as not to queue points that are essentially overlapping

private _onEachFrame = {
    private _currentVehicle = _this;
    private _convoyHashMap = _currentVehicle getVariable "KISKA_convoy_hashMap";
    private _convoyLead = _convoyHashMap get "_convoyLead";
    // private _stateMachine = _convoyHashMap get "_stateMachine";

    if (_currentVehicle isEqualTo _convoyLead) exitWith {};

    /* ----------------------------------------------------------------------------
        Setup
    ---------------------------------------------------------------------------- */
    private _vehicleAhead = _currentVehicle getVariable ["KISKA_convoy_vehicleAhead",objNull];
    private _vehicleAheadPosition = getPosATLVisual _vehicleAhead;
    private _currentVehicleDrivePath = _currentVehicle getVariable "KISKA_convoyDrivePath";
    // Debug
    private _currentVehicleDrivePath_debug = _currentVehicle getVariable "KISKA_convoyDrivePath_debug";
    // Debug //
    if (isNil "_currentVehicleDrivePath") then {
        _currentVehicleDrivePath = [];
        _currentVehicle setVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];
        _currentVehicle setVariable ["KISKA_queuedDrivePath",[]];
        // Debug
        _currentVehicleDrivePath_debug = [];
        _currentVehicle setVariable ["KISKA_convoyDrivePath_debug",_currentVehicleDrivePath_debug];
        // Debug //
    };


    /* ----------------------------------------------------------------------------
        Delete old points
    ---------------------------------------------------------------------------- */
    private _currentVehiclePosition = getPosATLVisual _currentVehicle;
    private _deleteStartIndex = -1;
    private _numberToDelete = 0;
    private _distanceToPoint = 10;
    {
        private _withinOneMeter = (_currentVehiclePosition vectorDistance _x) <= _distanceToPoint;

        if !(_withinOneMeter) then { break };
        _numberToDelete = _numberToDelete + 1;

        if (_deleteStartIndex isNotEqualTo -1) then { continue };
        _deleteStartIndex = _forEachIndex;

    } forEach _currentVehicleDrivePath;

    if (_deleteStartIndex >= 0) then {
        _currentVehicleDrivePath deleteRange [_deleteStartIndex,_numberToDelete];
        private _lastIndexToDelete = _deleteStartIndex + (_numberToDelete - 1);
        createVehicle ["Sign_Arrow_Large_blue_F", _currentVehiclePosition, [], 0, "CAN_COLLIDE"];
        // Debug
        for "_i" from _deleteStartIndex to _lastIndexToDelete do { 
            deleteVehicle (_currentVehicleDrivePath_debug select _i);
        };
        _currentVehicleDrivePath_debug deleteRange [_deleteStartIndex,_numberToDelete];
        // Debug //
    };


    
    /* ----------------------------------------------------------------------------
        Handle speed
    ---------------------------------------------------------------------------- */

    /* ---------------------------------
        Get bumper position of vehicle behind
    --------------------------------- */
    private _relativeFrontHashMap = localNamespace getVariable "KISKA_convoy_vehicleRelativeFront";
    private _currentVehicle_type = typeOf _currentVehicle;
    private _currentVehicle_relativeFront = _relativeFrontHashMap getOrDefault [_currentVehicle_type,[]];
    if (_currentVehicle_relativeFront isEqualTo []) then {
        private _boundingBox = 0 boundingBoxReal _currentVehicle;
        private _boundingMaxes = _boundingBox select 1;
        _currentVehicle_relativeFront = [0,_boundingMaxes select 1,0];
        _relativeFrontHashMap set [_currentVehicle_type,_currentVehicle_relativeFront];
    };
    private _currentVehicle_frontBumperPosition = _currentVehicle modelToWorldVisualWorld _currentVehicle_relativeFront;


    /* ---------------------------------
        Get rear bumper position of vehicle ahead
    --------------------------------- */
    private _relativeRearHashMap = localNamespace getVariable "KISKA_convoy_vehicleRelativeRear";
    private _vehicleAhead_type = typeOf _vehicleAhead;
    private _vehicleAhead_relativeRear = _relativeRearHashMap getOrDefault [_vehicleAhead_type,[]];
    if (_vehicleAhead_relativeRear isEqualTo []) then {
        private _boundingBox = 0 boundingBoxReal _vehicleAhead;
        private _boundingMins = _boundingBox select 0;
        _vehicleAhead_relativeRear = [0,_boundingMins select 1,0];
        _relativeRearHashMap set [_vehicleAhead_type,_vehicleAhead_relativeRear];
    };
    private _vehicleAhead_rearBumperPosition = _vehicleAhead modelToWorldVisualWorld _vehicleAhead_relativeRear;


    /* ---------------------------------
        limit speed based on distance
    --------------------------------- */
    private _distanceBetweenVehicles = _currentVehicle_frontBumperPosition vectorDistance _vehicleAhead_rearBumperPosition;
    if (_distanceBetweenVehicles < FOLLOW_DISTANCE) then {
        private _modifier = ((FOLLOW_DISTANCE - _distanceBetweenVehicles) * 2.5) max 5;
        private _speedLimit = ((speed _vehicleAhead) - _modifier) max 5;
        hint str ["limit speed",_speedLimit,_distanceBetweenVehicles];
        _currentVehicle limitSpeed _speedLimit;
    } else {
        hint "un limit";
        private _speed = -1;
        if (_distanceBetweenVehicles < (FOLLOW_DISTANCE * 1.25)) then {
            hint "un limit small";
            _speed = speed _vehicleAhead;
        };
        _currentVehicle limitSpeed _speed;
    };


    /* ----------------------------------------------------------------------------
        create new from queued point
    ---------------------------------------------------------------------------- */
    private _queuedPoints = _currentVehicle getVariable "KISKA_queuedDrivePath";
    private _latestQueuedPoint = [_queuedPoints] call KISKA_fnc_selectLastIndex;
    private _pointsAreQueued = !(isNil "_latestQueuedPoint");
    private _continue = false;
    if (_pointsAreQueued) then {
        private _vehicleAhead_distanceToQueuedPoint = _vehicleAheadPosition vectorDistance _latestQueuedPoint;

        private _vehicleAhead_hasMovedFromQueuedPoint = _vehicleAhead_distanceToQueuedPoint >= (CLEARANCE_TO_QUEUED_POINT + (abs (_vehicleAhead_relativeRear select 1)));
        if (!_vehicleAhead_hasMovedFromQueuedPoint) exitWith {};

        _currentVehicle setVariable ["KISKA_queuedDrivePath",[]];
        
        private _lastInsertedIndex = 0;
        _queuedPoints apply {
            // Debug
            private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _x select [0,3], [], 0, "CAN_COLLIDE"];
            _currentVehicleDrivePath_debug pushBack _debugObject;
            // Debug //

            _lastInsertedIndex = _currentVehicleDrivePath pushBack _x;
        };

        if (_lastInsertedIndex >= 1) then {
            _currentVehicle setDriveOnPath _currentVehicleDrivePath;
        };

        _continue = true;
    };

    if (_continue) exitWith {};

    
    /* ----------------------------------------------------------------------------
        Add Queued point if needed
    ---------------------------------------------------------------------------- */
    private _currentVehicle_lastQueuedTime = _currentVehicle getVariable ["KISKA_convoy_queuedTime",-1];
    private _pointHasBeenQueued = _currentVehicle_lastQueuedTime isNotEqualTo -1;
    private _updateFrequency = 0;
    private _time = time;
    if (
        _pointHasBeenQueued AND 
        !((_time - _currentVehicle_lastQueuedTime) >= _updateFrequency)
    ) exitWith {};

    _currentVehicle setVariable ["KISKA_convoy_queuedTime",_time];


    /* ----------------------------------------------------------------------------
        Only Queue points that aren't too close together
    ---------------------------------------------------------------------------- */
    private _vehicleHasAPath = _currentVehicleDrivePath isNotEqualTo [];
    if (!_vehicleHasAPath AND !_pointsAreQueued) exitWith {
        _queuedPoints pushBack _vehicleAheadPosition;
    };
    
    
    if (_pointsAreQueued) exitWith {
        private _vehicleAhead_distanceToLastQueuedPoint = _vehicleAheadPosition vectorDistance _latestQueuedPoint;
        if (_vehicleAhead_distanceToLastQueuedPoint > MIN_BUFFER_BETWEEN_POINTS) then {
            _queuedPoints pushBack _vehicleAheadPosition;
        };
    };  

    private _lastestPointToDriveTo = [_currentVehicleDrivePath] call KISKA_fnc_selectLastIndex;
    private _vehicleAhead_distanceToLastDrivePoint = _vehicleAheadPosition vectorDistance _lastestPointToDriveTo;
    if (_vehicleAhead_distanceToLastDrivePoint <= MIN_BUFFER_BETWEEN_POINTS) exitWith {};
    
    _queuedPoints pushBack _vehicleAheadPosition;
};



private _mainState = [
    _stateMachine,
    _onEachFrame
] call CBA_stateMachine_fnc_addState;

_stateMachine 
