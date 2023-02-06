#define FOLLOW_DISTANCE 10
#define CLEARANCE_TO_QUEUED_POINT 0.5
#define SPEED_LIMIT_MODIFIER 10
#define DISTANCE_TO_DELETE_POINT 10
#define MIN_VEHICLE_SPEED_LIMIT_MODIFIER 5
#define MIN_VEHICLE_SPEED_LIMIT 5
#define VEHICLE_SPEED_LIMIT_MULTIPLIER 2.5
#define SMALL_SPEED_LIMIT_DISTANCE_MODIFIER 1.25
#define FOLLOW_VEHICLE_MAX_SPEED_TO_HALT 5
#define LEAD_VEHICLE_MAX_SPEED_TO_HALT_FOLLOW 2

KISKA_fnc_selectLastIndex = {
    params [
        ["_array",[],[[]]],
        ["_defaultValue",nil,[]]
    ];

    private _arrayCount = count _array;
    _array param [(_arrayCount - 1),_defaultValue];
};

KISKA_fnc_convoy_haltVehicle = {
    params ["_vehicle"];

    systemChat "halt";
    _vehicle limitSpeed 1;
    (driver _vehicle) disableAI "path";
};

KISKA_fnc_getBumperPosition = {
    params [
        "_vehicle",
        ["_isRearBumper",false,[true]]
    ];

    private ["_hashMapId","_boundingBoxIndex"];
    if (_isRearBumper) then {
        _hashMapId = "KISKA_convoy_vehicleRelativeRearHashMap";
        _boundingBoxIndex = 0;
    } else {
        _hashMapId = "KISKA_convoy_vehicleRelativeFrontHashMap";
        _boundingBoxIndex = 1;
    };

    private _relativePointHashMap = localNamespace getVariable _hashMapId;
    if (isNil "_relativePointHashMap") then {
        _relativePointHashMap = createHashMap;
        _relativePointHashMap = localNamespace setVariable [_hashMapId,_relativePointHashMap];
    };


    private _vehicleType = typeOf _vehicle;
    private _relativeBumperPosition = _relativePointHashMap getOrDefault [_vehicleType,[]];
    if (_relativeBumperPosition isEqualTo []) then {
        private _vehicleBoundingBoxes = 0 boundingBoxReal _vehicle;
        private _boundingBox = _vehicleBoundingBoxes select _boundingBoxIndex;
        
        _relativeBumperPosition = [0,_boundingBox select 1,0];
        _relativePointHashMap set [_vehicleType,_relativeBumperPosition];
    };
    
    
    _vehicle modelToWorldVisualWorld _relativeBumperPosition;
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
_convoyHashMap set ["_debug",false];
_convoyHashMap set ["_minBufferBetweenPoints",1];

localNamespace setVariable ["KISKA_convoy_vehicleRelativeRear",createHashMap];
localNamespace setVariable ["KISKA_convoy_vehicleRelativeFront",createHashMap];



{
    _x setVariable ["KISKA_convoy_hashMap",_convoyHashMap];
    if (_forEachIndex isEqualTo 0) then { continue };

    _x setVariable ["KISKA_convoy_vehicleAhead",_vics select (_forEachIndex - 1)];
} forEach _vics;



private _onEachFrame = {
    private _currentVehicle = _this;
    private _convoyHashMap = _currentVehicle getVariable "KISKA_convoy_hashMap";
    private _debug = _convoyHashMap get "_debug";
    private _convoyLead = _convoyHashMap get "_convoyLead";
    // private _stateMachine = _convoyHashMap get "_stateMachine";

    if (_currentVehicle isEqualTo _convoyLead) exitWith {};

    /* ----------------------------------------------------------------------------
        Setup
    ---------------------------------------------------------------------------- */
    private "_currentVehicleDrivePath_debug";
    if (_debug) then {
        _currentVehicleDrivePath_debug = _currentVehicle getVariable "KISKA_convoyDrivePath_debug";
    };

    private _currentVehicleDrivePath = _currentVehicle getVariable "KISKA_convoyDrivePath";
    if (isNil "_currentVehicleDrivePath") then {
        _currentVehicleDrivePath = [];
        _currentVehicle setVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];

        if (_debug) then {
            _currentVehicleDrivePath_debug = [];
            _currentVehicle setVariable ["KISKA_convoyDrivePath_debug",_currentVehicleDrivePath_debug];
        };
    };
    
    /* ----------------------------------------------------------------------------
        Handle speed
    ---------------------------------------------------------------------------- */
    private _currentVehicle_frontBumperPosition = [_currentVehicle,false] call KISKA_fnc_getBumperPosition;
    private _vehicleAhead = _currentVehicle getVariable ["KISKA_convoy_vehicleAhead",objNull];
    private _vehicleAhead_rearBumperPosition = [_vehicleAhead,true] call KISKA_fnc_getBumperPosition;
    private _distanceBetweenVehicles = _currentVehicle_frontBumperPosition vectorDistance _vehicleAhead_rearBumperPosition;

    private _vehicleAhead_speed = speed _vehicleAhead;
    private _vehiclesAreWithinBoundary = _distanceBetweenVehicles < FOLLOW_DISTANCE;

    private _vehicleAhead_isHalted = _vehicleAhead_speed <= LEAD_VEHICLE_MAX_SPEED_TO_HALT_FOLLOW;
    private _currentVehicle_shouldStop = _vehicleAhead_isHalted AND _vehiclesAreWithinBoundary;
    private _currentVehicle_speed = speed _currentVehicle;
    if (_currentVehicle_shouldStop) exitWith {
        if (_debug) then {
            hint str ["In Halt",_currentVehicle_speed,_distanceBetweenVehicles];
        };

        if (
            !(_currentVehicle getVariable ["KISKA_convoy_vehicleAheadStopped",false])
        ) then {
            _currentVehicle setVariable ["KISKA_convoy_vehicleAheadStopped",true];
            [_currentVehicle] call KISKA_fnc_convoy_haltVehicle;
        };
        
    };

    _currentVehicle setVariable ["KISKA_convoy_vehicleAheadStopped",false];
    private _currentVehicle_driver = driver _currentVehicle;
    if !(_currentVehicle_driver checkAIFeature "path") then {
        _currentVehicle_driver enableAI "path";
    };


    /* ---------------------------------
        limit speed based on distance
    --------------------------------- */
    if (_vehiclesAreWithinBoundary) then {
        private _modifier = ((FOLLOW_DISTANCE - _distanceBetweenVehicles) * VEHICLE_SPEED_LIMIT_MULTIPLIER) max MIN_VEHICLE_SPEED_LIMIT_MODIFIER;
        private _speedLimit = (_vehicleAhead_speed - _modifier) max MIN_VEHICLE_SPEED_LIMIT;
        _currentVehicle limitSpeed _speedLimit;
        
        if (_debug) then {
            hint str ["limit speed",_currentVehicle_speed,_speedLimit,_distanceBetweenVehicles];
        };

    } else {
        private _distanceToLimitToVehicleAheadSpeed = FOLLOW_DISTANCE * SMALL_SPEED_LIMIT_DISTANCE_MODIFIER;
        if (_distanceBetweenVehicles < _distanceToLimitToVehicleAheadSpeed) exitWith {
            if (_debug) then {
                hint "un limit small";
            };

            private _speedToLimitTo = _vehicleAhead_speed;
            if (_vehicleAhead_isHalted) then {
                _speedToLimitTo = 5;
            };

            _currentVehicle limitSpeed _speedToLimitTo;
        };

        if (_distanceBetweenVehicles > 100) exitWith { 
            if (_debug) then {
                hint "un limit";
            };
            _currentVehicle limitSpeed -1 
        };
        
        // If the vehicle is far away, then un limit the speed
        // If the vehicle is somewhat close to the boundary, make them just as fast
        // A follow vehicle will progressively decrease its speed as it gets closer to the vehicle ahead

        private _speedDifferential = abs (_currentVehicle_speed - _vehicleAhead_speed);
        if (_speedDifferential > 20) exitWith {
            private _limit = _distanceBetweenVehicles - 0;
            
            if (_debug) then {
                hint str ["Limit by differential",_currentVehicle_speed,_limit];
            };

            _currentVehicle limitSpeed _limit;
        };
        
        if (_debug) then {
            hint str ["un limit generic",_distanceBetweenVehicles];
        };
        _currentVehicle limitSpeed -1;
    };


    /* ----------------------------------------------------------------------------
        Delete old points
    ---------------------------------------------------------------------------- */
    private _currentVehiclePosition = getPosATLVisual _currentVehicle;
    private _deleteStartIndex = -1;
    private _numberToDelete = 0;
    {
        private _pointReached = (_currentVehiclePosition vectorDistance _x) <= DISTANCE_TO_DELETE_POINT;

        if !(_pointReached) then { break };
        _numberToDelete = _numberToDelete + 1;

        private _deleteStartIndexDefined = _deleteStartIndex isNotEqualTo -1;
        if (_deleteStartIndexDefined) then { continue };
        _deleteStartIndex = _forEachIndex;

    } forEach _currentVehicleDrivePath;
    
    private _pointsCanBeDeleted = (_deleteStartIndex >= 0) AND (_numberToDelete > 0);
    if (_pointsCanBeDeleted) then {
        _currentVehicleDrivePath deleteRange [_deleteStartIndex,_numberToDelete];

        if (_debug) then {
            private _lastIndexToDelete = _deleteStartIndex + (_numberToDelete - 1);
            createVehicle ["Sign_Arrow_Large_blue_F", _currentVehiclePosition, [], 0, "CAN_COLLIDE"];
            for "_i" from _deleteStartIndex to _lastIndexToDelete do { 
                deleteVehicle (_currentVehicleDrivePath_debug select _i);
            };
            _currentVehicleDrivePath_debug deleteRange [_deleteStartIndex,_numberToDelete];
        };
    };


    /* ----------------------------------------------------------------------------
        create new from queued point
    ---------------------------------------------------------------------------- */
    private _queuedPoint = _currentVehicle getVariable ["KISKA_convoy_queuedPoint",[]];
    private _continue = false;
    if (_queuedPoint isNotEqualTo []) then {
        _currentVehicle setVariable ["KISKA_convoy_queuedPoint",nil];
        
        if (_debug) then {
            private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _queuedPoint, [], 0, "CAN_COLLIDE"];
            _currentVehicleDrivePath_debug pushBack _debugObject;

        };

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

    private _convoyLeadPosition = getPosATLVisual _convoyLead;
    private _lastestPointToDriveTo = [_currentVehicleDrivePath] call KISKA_fnc_selectLastIndex;
    if (isNil "_lastestPointToDriveTo") exitWith {
        _currentVehicle setVariable ["KISKA_convoy_queuedPoint",_convoyLeadPosition];
    };

    private _vehicleAhead_distanceToLastDrivePoint = _convoyLeadPosition vectorDistance _lastestPointToDriveTo;
    private _minBufferBetweenPoints = 1;
    if (_vehicleAhead_distanceToLastDrivePoint <= _minBufferBetweenPoints) exitWith {};
    
    _currentVehicle setVariable ["KISKA_convoy_queuedPoint",_convoyLeadPosition];
};



private _mainState = [
    _stateMachine,
    _onEachFrame
] call CBA_stateMachine_fnc_addState;

_stateMachine 
