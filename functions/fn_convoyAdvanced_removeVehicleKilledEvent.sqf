/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_removeVehicleKilledEvent

Description:
    Removes the "MPKILLED" event handler of a given vehicle in a convoy.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to add the killed eventhandler to

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] call KISKA_fnc_convoyAdvanced_removeVehicleKilledEvent;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_removeVehicleKilledEvent";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null"] call KISKA_fnc_log;
    nil
};


private _eventId = _vehicle getVariable ["KISKA_convoyAdvanced_vehicleKilledEventID",-1];
_vehicle removeMPEventHandler ["MPKILLED",_eventId];
_vehicle setVariable ["KISKA_convoyAdvanced_vehicleKilledEventID",nil];
