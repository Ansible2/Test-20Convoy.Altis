/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_removeVehicleLocalEvent

Description:
    Removes the "LOCAL" event handler of a given vehicle in a convoy.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to remove the local eventhandler of

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] call KISKA_fnc_convoyAdvanced_removeVehicleLocalEvent;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_removeVehicleLocalEvent";

params [
    ["_vehicle",objNull,[objNull]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null"] call KISKA_fnc_log;
    nil
};


private _eventId = _vehicle getVariable ["KISKA_convoyAdvanced_vehicleLocalEventID",-1];
_vehicle removeEventHandler ["LOCAL",_eventId];
_vehicle setVariable ["KISKA_convoyAdvanced_vehicleLocalEventID",nil];
