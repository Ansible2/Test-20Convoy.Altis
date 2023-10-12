/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_removeVehicle

Description:
    Removes a given vehicle from its convoy.

    This will shift the index's of all vehicles in the convoy that are lower
     than the given vehicle to remove. If the vehicle is moving (speed > 0)
     then the vehicle will be told to "stop" via a `move` order.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to remove

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] call KISKA_TEST_fnc_convoy_removeVehicle;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_removeVehicle";

#define MAX_ARRAY_LENGTH 1E7

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];


if (isNull _vehicle) exitWith {
    ["_vehicle is null",false] call KISKA_fnc_log;
    nil
};

private _convoyHashMap = [_vehicle] call KISKA_TEST_fnc_convoy_getConvoyHashMapFromVehicle;
if (isNil "_convoyHashMap") exitWith {
    [[_vehicle," does not have a KISKA_convoy_hashMap in its namespace"],true] call KISKA_fnc_log;
    nil
};


[_vehicle] call KISKA_TEST_fnc_convoy_removeVehicleKilledEvent;
[_vehicle,true] call KISKA_TEST_fnc_convoy_clearVehicleDebugFollowPath;
[_vehicle,true] call KISKA_TEST_fnc_convoy_clearVehicleDebugFollowedPath;


private _getOutEventHandlerId = _vehicle getVariable ["KISKA_convoy_getOutEventHandlerId",-1];
_vehicle removeEventHandler ["GetOut",_getOutEventHandlerId];


private _convoyVehicles = [_convoyHashMap] call KISKA_TEST_fnc_convoy_getConvoyVehicles;
private _vehicleIndex = [_vehicle] call KISKA_TEST_fnc_convoy_getVehicleIndex;
_convoyVehicles deleteAt _vehicleIndex;

private _vehiclesToChangeIndex = _convoyVehicles select [_vehicleIndex, MAX_ARRAY_LENGTH];
_vehiclesToChangeIndex apply {
    private _currentIndex = [_x] call KISKA_TEST_fnc_convoy_getVehicleIndex;
    if (_currentIndex isEqualTo -1) then {
        [["Could not find 'KISKA_convoy_index' in namespace of ", _x," to change"],true] call KISKA_fnc_log;
        continue
    };

    private _newIndex = _currentIndex - 1;
    _convoyHashMap set [_newIndex,_x];
    _x setVariable ["KISKA_convoy_index",_newIndex];
};

[_vehicle,"path"] remoteExecCall ["enableAI",_vehicle];
_vehicle limitSpeed -1;

// `move` will cancel the setDriveOnPath
if ((speed _vehicle) > 0) then {
    [_vehicle, (getPosATLVisual _vehicle)] remoteExecCall ["move",_vehicle];
};


[
    "KISKA_convoy_isStopped",
    "KISKA_convoy_drivePath",
    "KISKA_convoy_debug_followPathObjects",
    "KISKA_convoy_debug_followedPathObjects",
    "KISKA_convoy_debug",
    "KISKA_convoy_hashMap",
    "KISKA_convoy_index",
    "KISKA_convoy_debugMarkerType_followedPath",
    "KISKA_convoy_debugMarkerType_followPath",
    "KISKA_convoy_vehicleKilledEventID",
    "KISKA_convoy_handleUnconsciousDriver",
    "KISKA_convoy_handleDeadDriver",
    "KISKA_convoy_handleVehicleCantMove",
    "KISKA_convoy_handleVehicleKilled",
    "KISKA_convoy_seperation",
    "KISKA_convoy_lastAddedPoint",
    "KISKA_convoy_deadDriverBeingHandled",
    "KISKA_convoy_doDriveOnPath",
    "KISKA_convoy_currentUnconsciousDriver",
    "KISKA_convoy_getOutEventHandlerId",
    "KISKA_convoy_getOutTimesHashMap",
    "KISKA_convoy_vehicleArea"
] apply {
    _vehicle setVariable [_x,nil];
};


nil
