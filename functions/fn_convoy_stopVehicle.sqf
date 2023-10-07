/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_stopVehicle

Description:
    Used in the process of KISKA's advanced convoy to stop a given vehicle.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to stop

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] call KISKA_TEST_fnc_convoy_stopVehicle;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_stopVehicle";

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

// if !(local _vehicle) exitWith {
//     [["_vehicle ",_vehicle," is not local!"],true] call KISKA_fnc_log;
//     nil
// };

_vehicle limitSpeed 1;
// Limiting the speed is not enough for some vehicles (armor)
// They will either not stop fast enough when follow distances are small
// Or they start to move around and find random places to go
private _driver = driver _vehicle;
// TODO: figure out if an AI changes locality, that this disableAI will persist
// it is not clear which disableAI's are truly Global Effects
[_driver,"path"] remoteExecCall ["disableAI",_driver];
