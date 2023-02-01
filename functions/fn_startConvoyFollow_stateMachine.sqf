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

{
    _x setVariable ["KISKA_convoy_hashMap",_convoyHashMap];
    if (_forEachIndex isEqualTo 0) then { continue };

    _x setVariable ["KISKA_convoy_vehicleAhead",_vics select (_forEachIndex - 1)];
} forEach _vics;

// Current issue:
// the buffer distance between vehicles is too much
// attaching the speed of the _vehicleAhead to a queued point would be
// a good step to being able to better control the actual problem
// of a vehicle running into the one in front because it's going to fast
// The speed should probably not count when there are <= 2 points in the
// current path as this (likely) means it's just starting 

// if speed is under a certain threshold (but not negative)
// THEN you should be able to add the speed to the

// Current issue:
// the follow vehicle is able to move potentially faster than
// the lead vehicle, instead of smartly maintaining a distance behind
// the follow then catches the lead vehicle and then must brake, wait for it to have two points, and then can move again

// This may be fixable by ensuring that a vehicle always has two points in its que
// Could also have a "speed" for the convoy that can be maintained by the lead vehicle
/// and adjusted as needed for follow vehicles (e.g. if you are witihin this distance
/// of the lead vehicle, you will have a limitSpeed applied but not if you are farther away)


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
        create new from queued point
    ---------------------------------------------------------------------------- */
    private _queuedPoint = _currentVehicle getVariable ["KISKA_convoy_queuedPoint",[]];
    private _vehicleAhead_size = sizeOf (typeOf _vehicleAhead);
    private _vehicleAhead_bufferDistance = _vehicleAhead_size / 2;
    private _continue = false;
    if (_queuedPoint isNotEqualTo []) then {
        private _vehicleAhead_distanceToQueuedPoint = _vehicleAheadPosition vectorDistance _queuedPoint;
        private _vehicleAhead_hasMovedFromQueuedPoint = _vehicleAhead_distanceToQueuedPoint >= _vehicleAhead_bufferDistance;
        if (!_vehicleAhead_hasMovedFromQueuedPoint) exitWith {_continue = true};

        _currentVehicle setVariable ["KISKA_convoy_queuedPoint",nil];
        
        // Debug
        private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _queuedPoint select [0,3], [], 0, "CAN_COLLIDE"];
        _currentVehicleDrivePath_debug pushBack _debugObject;
        // Debug //

        private _indexInserted = _currentVehicleDrivePath pushBack _queuedPoint;
        // // trying to encourage a vehicle to move
        // if (_currentVehicleDrivePath isEqualTo []) then {
        //     _indexInserted = _currentVehicleDrivePath pushBack _vehicleAheadPosition;
        // };
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
    private _vehicleAhead_speed = speed _vehicleAhead;
    if ((_vehicleAhead_speed > 4) AND (_vehicleAhead_speed < 10)) then {
        _vehicleAheadPosition pushBack _vehicleAhead_speed;
    };  

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