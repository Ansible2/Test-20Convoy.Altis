#define FOLLOW_DISTANCE 20
#define CLEARANCE_TO_QUEUED_POINT 0.5
#define SPEED_LIMIT_MODIFIER 10
#define DISTANCE_TO_DELETE_POINT 10

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
// Follow vehicles receieve a less and less precise 
// path to follow with each follow vehicle in the convoy
// this causes them to run into walls and such
// There are two ways to potentially influence this: 
// 1. improve the pathing of every vehicle such that they do not deviate from
/// the path of the vehicle ahead enough to cause issues
// 2. The path that all vehicle follow ultimately comes from the lead vehicle
/// This can either be by every vehicle treating it as though they are following the lead vehicle in terms of the path being given
/// Or doing a "pass down" approach where in when a vehicle completes a waypoint, they provide that waypoint to the next vehicle in the chain

// TODO: Keeping vehicles from running into each other
// 1. if the vehicle ahead is stationary, and the vehicle behind is within the follow distance
/// delete the rest of the drive path.
// 2. Only create points that are behind the lead vehicle

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
        // Debug
        _currentVehicleDrivePath_debug = [];
        _currentVehicle setVariable ["KISKA_convoyDrivePath_debug",_currentVehicleDrivePath_debug];
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
    private _vehicleAhead_speed = speed _vehicleAhead;
    private _vehiclesAreWithinBoundary = _distanceBetweenVehicles < FOLLOW_DISTANCE;
    if (_vehiclesAreWithinBoundary) then {
        private _modifier = ((FOLLOW_DISTANCE - _distanceBetweenVehicles) * 2.5) max 5;
        private _speedLimit = (_vehicleAhead_speed - _modifier) max 5;
        hint str ["limit speed",_speedLimit,_distanceBetweenVehicles];
        _currentVehicle limitSpeed _speedLimit;
    } else {
        hint "un limit";
        private _speed = -1;
        if (_distanceBetweenVehicles < (FOLLOW_DISTANCE * 1.25)) then {
            hint "un limit small";
            _speed = _vehicleAhead_speed;
        };
        _currentVehicle limitSpeed _speed;
    };


    /* ----------------------------------------------------------------------------
        Delete old points
    ---------------------------------------------------------------------------- */
    private _currentVehiclePosition = getPosATLVisual _currentVehicle;
    private _deleteStartIndex = -1;
    private _numberToDelete = 0;
    private _followVehicleShouldStop = _vehicleAhead_speed <= 0 AND _vehiclesAreWithinBoundary;

    if (_followVehicleShouldStop) then {
        _deleteStartIndex = 0;
        _numberToDelete = count _currentVehicleDrivePath;

    } else {
        {
            private _pointReached = (_currentVehiclePosition vectorDistance _x) <= DISTANCE_TO_DELETE_POINT;

            if !(_pointReached) then { break };
            _numberToDelete = _numberToDelete + 1;

            private _deleteStartIndexDefined = _deleteStartIndex isNotEqualTo -1;
            if (_deleteStartIndexDefined) then { continue };
            _deleteStartIndex = _forEachIndex;

        } forEach _currentVehicleDrivePath;

    };
    
    if ((_deleteStartIndex >= 0) AND (_numberToDelete > 0)) then {
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


    if (_followVehicleShouldStop) exitWith {
        _currentVehicle setDriveOnPath [_currentVehiclePosition,_currentVehiclePosition];
    };

    /* ----------------------------------------------------------------------------
        create new from queued point
    ---------------------------------------------------------------------------- */
    private _queuedPoint = _currentVehicle getVariable ["KISKA_convoy_queuedPoint",[]];
    private _continue = false;
    if (_queuedPoint isNotEqualTo []) then {
        // private _vehicleAhead_distanceToQueuedPoint = _vehicleAheadPosition vectorDistance _queuedPoint;
        // private _vehicleAhead_hasMovedFromQueuedPoint = _vehicleAhead_distanceToQueuedPoint >= (CLEARANCE_TO_QUEUED_POINT + (abs (_vehicleAhead_relativeRear select 1)));
        // if (!_vehicleAhead_hasMovedFromQueuedPoint) exitWith {_continue = true};

        _currentVehicle setVariable ["KISKA_convoy_queuedPoint",nil];
        
        // Debug
        private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _queuedPoint, [], 0, "CAN_COLLIDE"];
        _currentVehicleDrivePath_debug pushBack _debugObject;
        // Debug //

        private _indexInserted = _currentVehicleDrivePath pushBack _queuedPoint;
        if (_indexInserted >= 1) then {
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


    /* ----------------------------------------------------------------------------
        Only Queue points that aren't too close together
    ---------------------------------------------------------------------------- */
    _currentVehicle setVariable ["KISKA_convoy_queuedTime",_time];

    private _currentVehiclePathCount = count _currentVehicleDrivePath;
    private _lastIndexInCurrentPath = (_currentVehiclePathCount - 1) max 0;
    private _lastestPointToDriveTo = _currentVehicleDrivePath param [_lastIndexInCurrentPath,[]];

    if (_lastestPointToDriveTo isEqualTo []) exitWith {
        _currentVehicle setVariable ["KISKA_convoy_queuedPoint",_vehicleAheadPosition];
    };

    private _vehicleAhead_distanceToLastDrivePoint = _vehicleAheadPosition vectorDistance _lastestPointToDriveTo;
    private _minBufferBetweenPoints = 1;
    if (_vehicleAhead_distanceToLastDrivePoint <= _minBufferBetweenPoints) exitWith {};
    
    _currentVehicle setVariable ["KISKA_convoy_queuedPoint",_vehicleAheadPosition];
};



private _mainState = [
    _stateMachine,
    _onEachFrame
] call CBA_stateMachine_fnc_addState;

_stateMachine 
