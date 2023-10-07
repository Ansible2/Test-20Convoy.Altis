/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_addVehicle

Description:
    Adds a given vehicle to a convoy. The index returned will be a key to the
     _convoyHashMap that can be used to get the vehicle for that index in the convoy.

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to add to
    1: _vehicle <OBJECT> - The vehicle to add
    2: _insertIndex <NUMBER> - The index to insert the vehicle into the convoy at. 
        Negative value means the back.
        (0 is lead vehicle, 1 is vehicle directly behind leader, etc.)

    3: _convoySeperation <NUMBER> - How far the vehicle should keep from the 
        vehicle in front (min of 10)

Returns:
    <NUMBER> - The index the vehicle was inserted into the convoy at

Examples:
    (begin example)
        private _convoyMap = [] call KISKA_TEST_fnc_convoy_create;
        private _spotInConvoy = [
            _convoyMap,
            vic
        ] call KISKA_TEST_fnc_convoy_addVehicle;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_addVehicle";

#define MAX_ARRAY_LENGTH 1E7


if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};


params [
    ["_convoyHashMap",nil,[createHashMap]],
    ["_vehicle",objNull,[objNull]],
    ["_insertIndex",-1,[123]],
    ["_convoySeperation",-1,[123]]
];


if (isNil "_convoyHashMap") exitWith {
    ["nil _convoyHashMap passed",true] call KISKA_fnc_log;
    -1
};

if (isNull _vehicle) exitWith {
    ["_vehicle is null",true] call KISKA_fnc_log;
    -1
};

private _driver = driver _vehicle;
if !(alive _driver) exitWith {
    [["_vehicle ",_vehicle," does not have an alive driver"],false] call KISKA_fnc_log;
    -1
};

private _convoyStatemachine = _convoyHashMap get "_stateMachine";
if (isNil "_convoyStatemachine") exitWith {
    [["_stateMachine is not defined in map: ",_convoyHashMap],true] call KISKA_fnc_log;
    -1
};

private _convoyLead = [_convoyHashMap] call KISKA_TEST_fnc_convoy_getConvoyLeader;
if ((speed _convoyLead) > 0) exitWith {
    [["_convoyLead ",_convoyLead," is moving, must be stopped to add vehicles to the convoy"]] call KISKA_fnc_log;
    -1
};

private _convoyVehicles = [_convoyHashMap] call KISKA_TEST_fnc_convoy_getConvoyVehicles;
if (_vehicle in _convoyVehicles) exitWith {
    [["_vehicle ",_vehicle," is already in _convoyHashMap ",_convoyHashMap],true] call KISKA_fnc_log;
    [_vehicle] call KISKA_TEST_fnc_convoy_getVehicleIndex
};



private _convoyCount = count _convoyVehicles;
private _indexToCopyFrom = -1;
private "_convoyIndex";
if (_insertIndex < 0) then {
    _convoyIndex = _convoyVehicles pushBack _vehicle;
    _convoyHashMap set [_convoyIndex,_vehicle];

    if (_convoyIndex isEqualTo 1) exitWith {};

    _indexToCopyFrom = _convoyIndex - 1;

} else {
    private _vehiclesToChangeIndex = _convoyVehicles select [_insertIndex,MAX_ARRAY_LENGTH];
    
    _convoyVehicles resize _insertIndex;
    _convoyIndex = _convoyVehicles pushBack _vehicle;
    _convoyVehicles append _vehiclesToChangeIndex;
    _convoyHashMap set [_convoyIndex,_vehicle];

    _vehiclesToChangeIndex apply {
        private _currentIndex = [_x] call KISKA_TEST_fnc_convoy_getVehicleIndex;
        if (_currentIndex isEqualTo -1) then {
            [["Could not find 'KISKA_convoy_index' in namespace of ", _x," to change"],true] call KISKA_fnc_log;
            continue
        };

        private _newIndex = _currentIndex + 1;
        _convoyHashMap set [_newIndex,_x];
        _x setVariable ["KISKA_convoy_index",_newIndex];
    };

    _indexToCopyFrom = _insertIndex;

}; 

_vehicle setVariable ["KISKA_convoy_drivePath",[]];
if (_indexToCopyFrom isNotEqualTo -1) then {
    private _vehicleToCopyPathFrom = [
        _convoyHashMap,
        _indexToCopyFrom
    ] call KISKA_TEST_fnc_convoy_getVehicleAtIndex;


    [
        _vehicle,
        -1,
        [_vehicleToCopyPathFrom] call KISKA_TEST_fnc_convoy_getVehicleDrivePath
    ] call KISKA_TEST_fnc_convoy_modifyVehicleDrivePath;

    private _lastAddedPointInDrivePath = [_vehicleToCopyPathFrom] call KISKA_TEST_fnc_convoy_getVehicleLastAddedPoint;
    // if vehicles are added at a convoy inception, this point is often not defined yet for some vehicles
    if !(isNil "_lastAddedPointInDrivePath") then {
        _vehicle setVariable ["KISKA_convoy_lastAddedPoint",_lastAddedPointInDrivePath];
    };

} else {
    _vehicle setVariable ["KISKA_convoy_drivePath",[]];
};


[_vehicle,true] call KISKA_TEST_fnc_convoy_setVehicleDriveOnPath;
[_vehicle,false] call KISKA_TEST_fnc_convoy_clearVehicleDebugFollowedPath;
[_vehicle,false] call KISKA_TEST_fnc_convoy_clearVehicleDebugFollowPath;


_vehicle setVariable ["KISKA_convoy_hashMap",_convoyHashMap];
_vehicle setVariable ["KISKA_convoy_index",_convoyIndex];
if (_convoySeperation < 0) then {
    _convoySeperation = [
        _convoyHashMap
    ] call KISKA_TEST_fnc_convoy_getDefaultSeperation;
};

[
    _vehicle,
    _convoySeperation
] call KISKA_TEST_fnc_convoy_setVehicleSeperation;


[_vehicle] call KISKA_TEST_fnc_convoy_addVehicleKilledEvent;

_vehicle setVariable ["KISKA_convoy_unitGetOutTimesHashMap",createHashMap];
private _getOutEventHandlerId = _vehicle addEventHandler ["GetOut",{
    params ["_vehicle", "", "_unit"];

    private _unitGetOutTimeHashMap = _vehicle getVariable "KISKA_convoy_unitGetOutTimesHashMap";
    if !(isNil "_getOutTimeHashMap") then {
        [
            _unitGetOutTimeHashMap,
            _unit,
            time
        ] call KISKA_fnc_hashmap_set;
    };
}];

_vehicle setVariable ["KISKA_convoy_getOutEventHandlerId",_getOutEventHandlerId];


_convoyIndex
