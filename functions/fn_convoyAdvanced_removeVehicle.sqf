/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_removeVehicle

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
        [vic] call KISKA_fnc_convoyAdvanced_removeVehicle;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_removeVehicle";

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

private _convoyHashMap = [_vehicle] call KISKA_fnc_convoyAdvanced_getConvoyHashMapFromVehicle;
if (isNil "_convoyHashMap") exitWith {
    [[_vehicle," does not have a KISKA_convoyAdvanced_hashMap in its namespace"],true] call KISKA_fnc_log;
    nil
};


[_vehicle] call KISKA_fnc_convoyAdvanced_removeVehicleKilledEvent;
[_vehicle,true] call KISKA_fnc_convoyAdvanced_clearVehicleDebugFollowPath;
[_vehicle,true] call KISKA_fnc_convoyAdvanced_clearVehicleDebugFollowedPath;


private _getOutEventHandlerId = _vehicle getVariable ["KISKA_convoyAdvanced_getOutEventHandlerId",-1];
_vehicle removeEventHandler ["GetOut",_getOutEventHandlerId];


private _convoyVehicles = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
private _vehicleIndex = [_vehicle] call KISKA_fnc_convoyAdvanced_getVehicleIndex;
_convoyVehicles deleteAt _vehicleIndex;

private _vehiclesToChangeIndex = _convoyVehicles select [_vehicleIndex, MAX_ARRAY_LENGTH];
_vehiclesToChangeIndex apply {
    private _currentIndex = [_x] call KISKA_fnc_convoyAdvanced_getVehicleIndex;
    if (_currentIndex isEqualTo -1) then {
        [["Could not find 'KISKA_convoyAdvanced_index' in namespace of ", _x," to change"],true] call KISKA_fnc_log;
        continue
    };

    private _newIndex = _currentIndex - 1;
    _convoyHashMap set [_newIndex,_x];
    _x setVariable ["KISKA_convoyAdvanced_index",_newIndex];
};

[_vehicle,"path"] remoteExecCall ["enableAI",_vehicle];
_vehicle limitSpeed -1;

// `move` will cancel the setDriveOnPath
if ((speed _vehicle) > 0) then {
    [_vehicle, (getPosATLVisual _vehicle)] remoteExecCall ["move",_vehicle];
};


[
    "KISKA_convoyAdvanced_isStopped",
    "KISKA_convoyAdvanced_drivePath",
    "KISKA_convoyAdvanced_debug_followPathObjects",
    "KISKA_convoyAdvanced_debug_followedPathObjects",
    "KISKA_convoyAdvanced_debug",
    "KISKA_convoyAdvanced_hashMap",
    "KISKA_convoyAdvanced_index",
    "KISKA_convoyAdvanced_debugMarkerType_deletedPoint",
    "KISKA_convoyAdvanced_debugMarkerType_queuedPoint",
    "KISKA_convoyAdvanced_queuedPoint",
    "KISKA_convoyAdvanced_vehicleKilledEventID",
    "KISKA_convoyAdvanced_seperation",
    "KISKA_convoyAdvanced_dynamicMovePoint",
    "KISKA_convoyAdvanced_dynamicMovePoint_completionRadius",
    "KISKA_convoyAdvanced_doDriveOnPath",
    "KISKA_convoyAdvanced_getOutEventHandlerId",
    "KISKA_convoyAdvanced_getOutTimesHashMap"
] apply {
    _vehicle setVariable [_x,nil];
};
