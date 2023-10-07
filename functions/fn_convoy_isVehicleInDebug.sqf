/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_isVehicleInDebug

Description:
    Gets whether or a given vehicle is in debug mode for a convoy.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the convoy index of

Returns:
    <BOOL> - `true` if the vehicle is in debug mode

Examples:
    (begin example)
        private _isInDebug = [
            _vehicle
        ] call KISKA_TEST_fnc_convoy_isVehicleInDebug;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_isVehicleInDebug";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    false
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoy_debug",false]
