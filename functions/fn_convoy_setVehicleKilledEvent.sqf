/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_setVehicleKilledEvent

Description:
    Sets the code that should execute when a vehicle dies in a convoy.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to set the killed event on
    1: _eventCode <CODE> - The code to execute when the vehicle dies in a convoy
        
        Parameters:
        - 0: _vehicle <OBJECT> - The vehicle that died
        - 1: _convoyHashMap <OBJECT> - The hashmap used for the convoy
        - 2: _convoyLead <OBJECT> - The lead vehicle of the convoy

Returns:
    NOTHING

Examples:
    (begin example)
        [
            vic,
            {hint str _this}
        ] call KISKA_TEST_fnc_convoy_setVehicleKilledEvent;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_setVehicleKilledEvent";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_eventCode",{},[{}]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null"] call KISKA_fnc_log;
    nil
};


_vehicle setVariable [
    "KISKA_convoy_handleVehicleKilled",
    _eventCode
];
