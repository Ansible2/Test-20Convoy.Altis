/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getConvoyVehicles

Description:
    Returns the list of vehicles in a convoy. This is not a copy of the array used
     for certain internal operations of the convoy. Make a copy if you intend to modify
     the contents of the array (see example 2).

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap get vehicles from
    1: _fromIndex <NUMBER> - If provided, only the vehicles from (and including) the
        the given index will be returned

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
    
    (begin example)
        private _startingIndex = 1;
        private _allVehiclesButLeader = [
            SomeConvoyHashMap,
            _startingIndex
        ] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getConvoyVehicles";

#define MAX_ARRAY_LENGTH 1E7

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    []
};

params [
    "_convoyHashMap",
    ["_fromIndex",-1,[123]]
];

private _vehicles = _convoyHashMap getOrDefault ["_convoyVehicles",[]];
if (_fromIndex <= 0) exitWith {_vehicles};


_vehicles select [_fromIndex,MAX_ARRAY_LENGTH]
