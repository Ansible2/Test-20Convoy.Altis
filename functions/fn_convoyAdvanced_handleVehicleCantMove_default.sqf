/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_handleVehicleCantMove_default

Description:
	The default behaviour that happens when a vehicle in the convoy is disabled.

Parameters:
    0: _disabledVehicle <OBJECT> - The vehicle that has been disabled
    1: _convoyHashMap <HASHMAP> - The hashmap used for the convoy
    2: _convoyLead <OBJECT> - The lead vehicle of the convoy

Returns:
    NOTHING

Examples:
    (begin example)
        SHOULD NOT BE CALLED DIRECTLY
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_handleVehicleCantMove_default";

#define X_AREA_BUFFER 5
#define Y_AREA_BUFFER 10
#define MOVING_POSITIONS_BUFFER 2
#define LEFT_AZIMUTH_RELATIVE_NORTH 270
#define RIGHT_AZIMUTH_RELATIVE_NORTH 90

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_disabledVehicle",objNull,[objNull]],
    ["_convoyHashmap",nil],
    ["_convoyLead",objNull,[objNull]]
];

[[_disabledVehicle," can't move handler called"]] call KISKA_fnc_log;

/* ----------------------------------------------------------------------------
	Parameter check
---------------------------------------------------------------------------- */
if (isNull _disabledVehicle) exitWith {
    [
        [
            "null _disabledVehicle was passed, _convoyHashMap is: ",
            _convoyHashMap
        ],
        true
    ] call KISKA_fnc_log;

    nil
};

if (isNil "_convoyHashMap") exitWith {
    [   
        [
            "nil _convoyHashMap was passed, _disabledVehicle is: ",
            _disabledVehicle
        ],
        true
    ] call KISKA_fnc_log;

    nil
};

if (isNull _convoyLead) exitWith {
    [   
        [
            "null _convoyLead was passed, _disabledVehicle is: ",
            _disabledVehicle,
			" and _convoyHashMap is: ",
			_convoyHashMap
        ],
        true
    ] call KISKA_fnc_log;

    nil
};


/* ----------------------------------------------------------------------------
	Function Defintions
---------------------------------------------------------------------------- */
private _getBlockedPositions = {
    params ["_vehicleBehind_drivePath","_disabledVehicle","_disabledVehicle_boundingBox"];

    private _disabledVehicle_boundingBoxMins = _disabledVehicle_boundingBox select 0;
    private _disabledVehicle_boundingBoxMaxes = _disabledVehicle_boundingBox select 1;

    // Adding buffers to X and Y because points that are too close to the _disabledVehicle
    // will result in _vehicleBehind crashing into it.
    private _xMin = _disabledVehicle_boundingBoxMins select 0;
    private _xMax = _disabledVehicle_boundingBoxMaxes select 0;
    private _areaX = ((abs (_xMax - _xMin)) / 2) + X_AREA_BUFFER;
    
    private _yMin = _disabledVehicle_boundingBoxMins select 1;
    private _yMax = _disabledVehicle_boundingBoxMaxes select 1;
    private _areaY = ((abs (_yMax - _yMin)) / 2) + Y_AREA_BUFFER;

    private _zMin = _disabledVehicle_boundingBoxMins select 2;
    private _zMax = _disabledVehicle_boundingBoxMaxes select 2;
    private _areaZ = (abs (_zMax - _zMin)) / 2;

    private _areaCenter = ASLToAGL (getPosASLVisual _disabledVehicle);
    private _lastIndex = (count _vehicleBehind_drivePath) - 1;

    private _blockedPositions_ATL = [];
    private _lastBlockedIndex = _lastIndex;
    {
        if (_forEachIndex isEqualTo _lastIndex) then { break };

        private _nextPointInPath = _vehicleBehind_drivePath select (_forEachIndex + 1);
        private _azimuthToNextPoint = _x getDir _nextPointInPath;

        private _currentPointIsInArea = _x inArea [
            _areaCenter,
            _areaX,
            _areaY,
            _azimuthToNextPoint,
            true,
            _areaZ
        ];

        private _aBlockedPositionWasAlreadyFound = _blockedPositions_ATL isNotEqualTo [];
        if (_aBlockedPositionWasAlreadyFound AND (!_currentPointIsInArea)) then { break };

        if (_currentPointIsInArea) then {
            _blockedPositions_ATL pushBack _x;
            _lastBlockedIndex = _forEachIndex;
        };
    } forEach _vehicleBehind_drivePath;


    [_blockedPositions_ATL, _lastBlockedIndex]
};


private _findClearSide = {
    params ["_blockedPositions_ATL","_disabledVehicle","_requiredSpace"];

    private _firstBlockedPosition = _blockedPositions_ATL select 0;

    private _blockedPositionsCount = count _blockedPositions_ATL;
    private _middleIndex = (round (_blockedPositionsCount / 2)) - 1;
    private _middleBlockedPosition = _blockedPositions_ATL select _middleIndex;

    private _lastIndex = _blockedPositionsCount - 1;
    private _lastBlockedPosition = _blockedPositions_ATL select _lastIndex;

    private _disabledVehicle_dir = getDirVisual _disabledVehicle;
    private _leftAzimuth = LEFT_AZIMUTH_RELATIVE_NORTH + _disabledVehicle_dir;
    private _rightAzimuth = RIGHT_AZIMUTH_RELATIVE_NORTH + _disabledVehicle_dir;

    private _clearSide = -1;
    private _clearLeft = true;
    private _clearRight = true;

    [
        _firstBlockedPosition,
        _middleBlockedPosition,
        _lastBlockedPosition
    ] apply {
        
        private _positionASL = ATLToASL _x;

        if (_clearLeft) then {
            private _positionLeftASL = AGLToASL (_positionASL getPos [_requiredSpace, _leftAzimuth]);
            private _objectsToDisabledVehiclesLeft = lineIntersectsObjs [
                _positionASL, 
                _positionLeftASL, 
                _disabledVehicle,
                objNull,
                true,
                32
            ];
            private _objectsAreOnTheLeft = _objectsToDisabledVehiclesLeft isNotEqualTo [];

            if (_objectsAreOnTheLeft) then { _clearLeft = false };
        };

        if (_clearRight) then {
            private _positionRightASL = AGLToASL (_positionASL getPos [_requiredSpace, _rightAzimuth]);
            private _objectsToDisabledVehiclesRight = lineIntersectsObjs [
                _positionASL, 
                _positionRightASL, 
                _disabledVehicle,
                objNull,
                true,
                32
            ];
            private _objectsAreOnTheRight = _objectsToDisabledVehiclesRight isNotEqualTo [];
            
            if (_objectsAreOnTheRight) then { _clearRight = false };
        };

        if ((!_clearLeft) AND (!_clearRight)) then { break };
    };

    if (_clearLeft) then {
        _clearSide = 0;
    } else {
        if (_clearRight) then { _clearSide = 1; };
    };


    _clearSide
};



/* ----------------------------------------------------------------------------
	Drive around disabled vehicles
---------------------------------------------------------------------------- */
private _disabledVehicle_index = [_disabledVehicle] call KISKA_fnc_convoyAdvanced_getVehicleIndex;
private _vehicleBehind_index = _disabledVehicle_index + 1;
private _vehicleBehind = [_convoyHashMap, _vehicleBehind_index] call KISKA_fnc_convoyAdvanced_getVehicleAtIndex;


[_disabledVehicle] call KISKA_fnc_convoyAdvanced_removeVehicle;
if (isNull _vehicleBehind) exitWith {
    [["No _vehicleBehind found at index: ",_vehicleBehind_index]] call KISKA_fnc_log;
    nil
};


[_convoyHashMap] call KISKA_fnc_convoyAdvanced_syncLatestDrivePoint;

private _disabledVehicle_boundingBox = 0 boundingBoxReal _disabledVehicle;
private _vehicleBehind_currentDrivePath = [_vehicleBehind] call KISKA_fnc_convoyAdvanced_getVehicleDrivePath;
private _blockedPositionsResult = [
    _vehicleBehind_currentDrivePath,
    _disabledVehicle,
    _disabledVehicle_boundingBox
] call _getBlockedPositions;


private _positionsBlockedByDisabledVehicle_ATL = _blockedPositionsResult select 0;
if (_positionsBlockedByDisabledVehicle_ATL isEqualTo []) exitWith {
    [[
        "Did not find any blocked drive path positions: _vehicleBehind: ",
        _vehicleBehind,
        " _disabledVehicle: ",
        _disabledVehicle
    ]] call KISKA_fnc_log;
    nil
};


private _vehicleBehind_boundingBox = 0 boundingBoxReal _vehicleBehind;
private _vehicleBehind_xMin = (_vehicleBehind_boundingBox select 0) select 0;
private _vehicleBehind_xMax = (_vehicleBehind_boundingBox select 1) select 0;
private _vehicleBehind_width = abs (_vehicleBehind_xMax - _vehicleBehind_xMin);

private _disbaledVehicle_xMin = (_disabledVehicle_boundingBox select 0) select 0;
private _disbaledVehicle_xMax = (_disabledVehicle_boundingBox select 1) select 0;
private _disabledVehicle_halfWidth = (abs (_disbaledVehicle_xMax - _disbaledVehicle_xMin)) / 2;

private _requiredSpace = _vehicleBehind_width + _disabledVehicle_halfWidth;
private _clearSide = [
    _positionsBlockedByDisabledVehicle_ATL,
    _disabledVehicle,
    _requiredSpace
] call _findClearSide;


private _noSideIsClear = _clearSide isEqualTo -1;
if (_noSideIsClear) exitWith {
    [_vehicleBehind] call KISKA_fnc_convoyAdvanced_stopVehicle;
    [_vehicleBehind, false] call KISKA_fnc_convoyAdvanced_setVehicleDoDriveOnPath;

    [[
        "Could not find clear side for: _vehicleBehind: ",
        _vehicleBehind,
        " _disabledVehicle: ",
        _disabledVehicle
    ]] call KISKA_fnc_log;


    nil
};


private _distanceToMovePositions = _vehicleBehind_width + _disabledVehicle_halfWidth + MOVING_POSITIONS_BUFFER;
private _disabledVehicle_dir = getDirVisual _disabledVehicle;

private _movementDirectionBase = [LEFT_AZIMUTH_RELATIVE_NORTH, RIGHT_AZIMUTH_RELATIVE_NORTH] select _clearSide;
private _movePositionAzimuth = _movementDirectionBase + _disabledVehicle_dir;

private _firstPositionToMove = _positionsBlockedByDisabledVehicle_ATL select 0;
private _firstPositionAdjusted_AGL = _firstPositionToMove getPos [_distanceToMovePositions, _movePositionAzimuth];
private _firstPositionAdjusted_ATL = ASLToATL (AGLToASL _firstPositionAdjusted_AGL);
private _movedPositionVectorOffset = _firstPositionToMove vectorDiff _firstPositionAdjusted_ATL;

private _positionsBlockedByDisabledVehicle_ATL = _blockedPositionsResult select 0;
private _adjustedPositions = _positionsBlockedByDisabledVehicle_ATL apply {_x vectorDiff _movedPositionVectorOffset};

private _deletionRange = count _adjustedPositions;
private _vehicleBehind_lastIndexToBeAdjustedInPath = _blockedPositionsResult select 1;
private _lastIndexOffset = (count _vehicleBehind_currentDrivePath) - (_vehicleBehind_lastIndexToBeAdjustedInPath + 1);

private _convoyVehicles = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
{
    // don't need to adjust convoy lead
    if (_forEachIndex isEqualTo 0) then { continue };

    private _vehiclesDrivePath = _x getVariable "KISKA_convoyAdvanced_drivePath";
    private _vehiclesDrivePathCount = count _vehiclesDrivePath;
    private _endIndex = _vehiclesDrivePathCount - _lastIndexOffset;
    private _startIndex = _endIndex - _deletionRange;
    
    if (_startIndex < 0) then {
        _deletionRange = _deletionRange + _startIndex;
        _startIndex = 0;
    };

    _vehiclesDrivePath deleteRange [_startIndex, _deletionRange];
    _vehiclesDrivePath insert [_startIndex max 0, _adjustedPositions];
} forEach _convoyVehicles;



/* ----------------------------------------------------------------------------
	Handle units that dismount disabled vehicle

    // units may dismount in the path of the vehicle behind attempting to drive past
    // the driving AI will try to avoid driving over friendlies and will
    /// run into the back of the disabled vehicle in some cases
---------------------------------------------------------------------------- */
private _unitsToAdjustDismountPosition = crew _disabledVehicle;

private _timeVehicleWasDiscoveredDisabled = time;
private _unitGetOutTimeHashMap = _disabledVehicle getVariable "KISKA_convoyAdvanced_unitGetOutTimesHashMap";
if !(isNil "_unitGetOutTimeHashMap") then {
    _unitGetOutTimeHashMap apply {  
        private _timeSinceUnitGotOut = _timeVehicleWasDiscoveredDisabled - _y;
        private _unitGotOutMoreThanASecondAgo = _timeSinceUnitGotOut >= 1;
        if (_unitGotOutMoreThanASecondAgo) then { continue };

        private _unit = [
            _x
        ] call KISKA_fnc_hashmap_getObjectOrGroupFromRealKey;
        _unitsToAdjustDismountPosition pushBackUnique _unit;
    };
};

// TODO: dismount position is not quite right, too far back
private _disabledVehicle_boundingBoxMins = _disabledVehicle_boundingBox select 0;
private _disabledVehicle_boundingBoxMaxes = _disabledVehicle_boundingBox select 1;
private _xOffset = [
    _disabledVehicle_boundingBoxMaxes select 0,
    _disabledVehicle_boundingBoxMins select 0
] select _clearSide;
private _relativeDismountPosition = [
    _xOffset + 2,
    _disabledVehicle_boundingBoxMins select 1,
    _disabledVehicle_boundingBoxMins select 2
];

private _dismountPosition = _disabledVehicle modelToWorldVisualWorld _relativeDismountPosition;
_unitsToAdjustDismountPosition apply {
    _x setPosWorld _dismountPosition
};


nil
