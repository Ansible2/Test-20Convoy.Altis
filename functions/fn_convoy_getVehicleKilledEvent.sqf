/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoy_setVehicleKilledEvent

Description:
    Gets the code that should execute when a vehicle dies in a convoy.
    
    This will by default return KISKA_convoy_handleVehicleKilled_default if
     not explicitly set on the vehicle.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the killed event code of

Returns:
    <CODE> - The code that executes when a vehicle is killed in the convoy

Examples:
    (begin example)
        private _eventCode = [
            vic
        ] call KISKA_fnc_convoy_getVehicleKilledEvent;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoy_getVehicleKilledEvent";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    -1
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable [
    "KISKA_convoy_handleVehicleKilled",
    KISKA_fnc_convoy_handleVehicleKilled_default
]
