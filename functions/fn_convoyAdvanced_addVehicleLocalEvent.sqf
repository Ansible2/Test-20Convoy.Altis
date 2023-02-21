/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_addVehicleLocalEvent

Description:
    Adds the local event handlers to a given vehicle in a convoy.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to add the local eventhandler to

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] call KISKA_fnc_convoyAdvanced_addVehicleLocalEvent;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_addVehicleLocalEvent";

params [
    ["_vehicle",objNull,[objNull]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null",true] call KISKA_fnc_log;
    nil
};


private _localEventId = _vehicle addEventHandler ["Local", {
    params ["_vehicle", "_isLocal"];

    if ((alive _vehicle) AND (!_isLocal)) then {
        [_vehicle] call KISKA_fnc_convoyAdvanced_removeVehicleKilledEvent;
        [_vehicle] remoteExecCall ["KISKA_fnc_convoyAdvanced_addVehicleLocalEvent",_vehicle];
        [_vehicle] remoteExecCall ["KISKA_fnc_convoyAdvanced_addVehicleKilledEvent",_vehicle];
        [_vehicle] call KISKA_fnc_convoyAdvanced_removeVehicleLocalEvent;
    };
}];
_vehicle setVariable ["KISKA_convoyAdvanced_vehicleLocalEventID",_localEventId];
