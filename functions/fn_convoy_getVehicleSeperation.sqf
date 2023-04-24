/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoy_getVehicleSeperation

Description:
    Gets the distance that a given vehicle will keep from the vehicle in front
     of it when in a convoy.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the convoy seperation of

Returns:
    <NUMBER> - The distance the vehicle will keep from the vehicle in front
        `-1` indicates that no seperation has been set for the vehicle.

Examples:
    (begin example)
        private _vehicleConvoySeperation = [
            _vehicle
        ] call KISKA_fnc_convoy_getVehicleSeperation;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoy_getVehicleSeperation";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    -1
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoy_seperation",-1]
