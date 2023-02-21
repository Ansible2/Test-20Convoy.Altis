/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_setVehicleDebug

Description:
    Sets whether or not a given vehicle is in debug mode for convoys.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to set the convoy seperation of
    1: _debugMode <BOOL> - `true` to enable, `false` to disable debug

Returns:
    NOTHING

Examples:
    (begin example)
        // debug enabled 
        [
            _vehicle,
            true
        ] call KISKA_fnc_convoyAdvanced_setVehicleDebug;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_setVehicleDebug";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_debug",false,[true]]
];


_vehicle setVariable ["KISKA_convoyAdvanced_debug",_debug];
