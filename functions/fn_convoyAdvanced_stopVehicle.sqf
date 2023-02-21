/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_stopVehicle

Description:
    Used in the process of KISKA's advanced convoy to stop a given vehicle.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to stop

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] call KISKA_fnc_convoyAdvanced_stopVehicle;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_stopVehicle";

params [
    ["_vehicle",objNull,[objNull]]
];


if (isNull _vehicle) exitWith {
    ["_vehicle is null",false] call KISKA_fnc_log;
    nil
};

if !(local _vehicle) exitWith {
    [["_vehicle ",_vehicle," is not local!"],true] call KISKA_fnc_log;
    nil
};

_vehicle limitSpeed 1;
// Limiting the speed is not enough for some vehicles (armor)
// They will either not stop fast enough in close follow distances
// Or they start to move around and find random places to go
(driver _vehicle) disableAI "path";
