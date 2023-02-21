/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getConvoyHashMapFromVehicle

Description:
    Gets the corresponding hashmap of a convoy for a particular vehicle.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the convoy hashmap of

Returns:
    <HASHMAP> - The hashmap of the convoy this vehicle belongs to 
        (nil in the case of the vehicle not belonging to a convoy)

Examples:
    (begin example)
        private _convoyHashMap = [
            _vehicle
        ] call KISKA_fnc_convoyAdvanced_getConvoyHashMapFromVehicle;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getConvoyHashMapFromVehicle";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable "KISKA_convoyAdvanced_hashMap"
