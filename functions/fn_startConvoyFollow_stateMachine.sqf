#define FOLLOW_DISTANCE 20
#define CLEARANCE_TO_QUEUED_POINT 0.5
#define SPEED_LIMIT_MODIFIER 10

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

// Use bouding box of vehicle and position world to find the front of the rear vic and back of the lead vic
// Do this by gettting the Min-Y boundingBoxReal

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
        // TODO better modifier formula
        // as the distance closes, modifier should increase 
        private _modifier = ((FOLLOW_DISTANCE - _distanceBetweenVehicles) * 2) max 7;

        private _speedLimit = ((speed _vehicleAhead) - _modifier) max 5;
        hint str ["limit speed",_speedLimit];
        _currentVehicle limitSpeed _speedLimit;
    } else {
        hint "un limit";
        _currentVehicle limitSpeed -1;
    };


    /* ----------------------------------------------------------------------------
        create new from queued point
    ---------------------------------------------------------------------------- */
    private _queuedPoint = _currentVehicle getVariable ["KISKA_convoy_queuedPoint",[]];
    private _continue = false;
    if (_queuedPoint isNotEqualTo []) then {
        private _vehicleAhead_distanceToQueuedPoint = _vehicleAheadPosition vectorDistance _queuedPoint;
        // TODO: clearance must include diustance from the center of the vehicle to rear
        private _vehicleAhead_hasMovedFromQueuedPoint = _vehicleAhead_distanceToQueuedPoint >= (CLEARANCE_TO_QUEUED_POINT + (abs (_vehicleAhead_relativeRear select 1)));
        if (!_vehicleAhead_hasMovedFromQueuedPoint) exitWith {_continue = true};

        _currentVehicle setVariable ["KISKA_convoy_queuedPoint",nil];
        
        // Debug
        private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _queuedPoint select [0,3], [], 0, "CAN_COLLIDE"];
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
    // TODO: may not be needed
    // private _vehicleAhead_speed = speed _vehicleAhead;
    // if ((_vehicleAhead_speed > 4) AND (_vehicleAhead_speed < 10)) then {
    //     _vehicleAheadPosition pushBack _vehicleAhead_speed;
    // };  

    if (_lastestPointToDriveTo isEqualTo []) exitWith {
        _currentVehicle setVariable ["KISKA_convoy_queuedPoint",_vehicleAheadPosition];
    };

    private _vehicleAhead_distanceToLastDrivePoint = _vehicleAheadPosition vectorDistance _lastestPointToDriveTo;
    private _minBufferBetweenPoints = 0.01;
    if (_vehicleAhead_distanceToLastDrivePoint <= _minBufferBetweenPoints) exitWith {};
    
    _currentVehicle setVariable ["KISKA_convoy_queuedPoint",_vehicleAheadPosition];
};



private _mainState = [
    _stateMachine,
    _onEachFrame
] call CBA_stateMachine_fnc_addState;

_stateMachine 





// myPos = [0,0,0];
// addMissionEventHandler ["Draw3D", {
// 	drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Radar\radar_ca.paa", [1,1,1,1], myPos, 1, 1, 45, "Target", 1, 0.05, "TahomaB"];
// }];


// private _boundingBox = 0 boundingBoxReal vic1;
// private _boundingMins = _boundingBox select 0;
// private _boundingMaxes = _boundingBox select 1;

// private _relativeToFront = [0,_boundingMaxes select 1,0];
// private _vicPosition = vic1 modelToWorldVisual _relativeToFront;
// myPos = _vicPosition;
// _vicPosition

// private _boundingBox = 0 boundingBoxReal vic1;
// private _boundingMins = _boundingBox select 0;
// private _boundingMaxes = _boundingBox select 1;

// private _relativeRear = [0,_boundingMins select 1,0];
// private _vicPosition = vic1 modelToWorldVisual _relativeToFront;
// myPos = _vicPosition;
// _vicPosition