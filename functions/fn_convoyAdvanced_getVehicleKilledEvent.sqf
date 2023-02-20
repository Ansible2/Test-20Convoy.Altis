/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_setVehicleKilledEvent

Description:
    Gets the code that should execute when a vehicle dies in a convoy.
    
    This will by default return KISKA_convoyAdvanced_handleVehicleKilled_default if
     not explicitly set on the vehicle.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the killed event code of

Returns:
    NOTHING

Examples:
    (begin example)
        private _eventCode = [
            vic
        ] call KISKA_fnc_convoyAdvanced_getVehicleKilledEvent;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getVehicleKilledEvent";

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable [
    "KISKA_convoyAdvanced_handleVehicleKilled",
    KISKA_convoyAdvanced_handleVehicleKilled_default
]
