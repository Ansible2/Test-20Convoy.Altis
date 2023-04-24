/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoy_getVehicleIndex

Description:
    Gets the index in of the provided vehicle in its convoy.

    `0` being the convoy leader and `1` being the vehicle directly behind the convoy
     leader, for example. `-1` indicates the vehicle is not in a convoy.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the convoy index of

Returns:
    <NUMBER> - The index of the vehicle in its convoy

Examples:
    (begin example)
        private _indexOfVehicleInConvoy = [
            _vehicle
        ] call KISKA_fnc_convoy_getVehicleIndex;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoy_getVehicleIndex";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    -1
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoy_index",-1]
