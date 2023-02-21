/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_executeVehicleKilledEvent

Description:
    Adds a killed event handler to a given vehicle in a convoy.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to add the killed eventhandler to

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] remoteExecCall ["KISKA_fnc_convoyAdvanced_executeVehicleKilledEvent",2];
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_executeVehicleKilledEvent";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null",true] call KISKA_fnc_log;
    nil
};


private _convoyHashMap = _vehicle getVariable "KISKA_convoyAdvanced_hashMap";
if (isNil "_convoyHashMap") exitWith {
    [["_convoyHashMap was nil, event was for _vehicle: ",_vehicle],true] call KISKA_fnc_log;
    nil
};

private _function = [
    _vehicle
] call KISKA_fnc_convoyAdvanced_getVehicleKilledEvent;
private _convoyLead = _convoyHashMap get 0;
[
    _vehicle,
    _convoyHashMap,
    _convoyLead
] call _function;
