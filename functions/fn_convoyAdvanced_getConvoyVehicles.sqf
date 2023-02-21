/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getConvoyVehicles

Description:
    Returns the list of vehicles in a convoy. This is not a copy of the array used
     for certain internal operations of the convoy. Make a copy if you intend to modify
     the contents of the array (see example 2).

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap get vehicles from

Returns:
    <OBJECT[]> - an array containing each vehicle (in there convoy order)

Examples:
    (begin example)
        private _convoyVehicles = [
            SomeConvoyHashMap
        ] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
    (end)

    (begin example)
        private _convoyVehiclesCopy = +([
            SomeConvoyHashMap
        ] call KISKA_fnc_convoyAdvanced_getConvoyVehicles);
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getConvoyVehicles";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    []
};

params ["_convoyHashMap"];


_convoyHashMap getOrDefault ["_convoyVehicles",[]]
