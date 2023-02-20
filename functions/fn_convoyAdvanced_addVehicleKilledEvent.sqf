/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_addVehicleKilledEvent

Description:
    Adds a killed event handler to a given vehicle in a convoy.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to add the killed eventhandler to

Returns:
    NOTHING

Examples:
    (begin example)
        [vic] call KISKA_fnc_convoyAdvanced_addVehicleKilledEvent;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_addVehicleKilledEvent";

params [
    ["_vehicle",objNull,[objNull]]
];


if (isNull _vehicle) exitWith {
    ["_vehicle is null",true] call KISKA_fnc_log;
    nil
};


private _vehicleKilledEventId = _vehicle addEventHandler ["KILLED", {
    params ["_vehicle"];

    private _function = [
        vic
    ] call KISKA_fnc_convoyAdvanced_getVehicleKilledEvent;
    // TODO: this actually will not be defined anywhere but on the machine where the convoy was started
    private _convoyHashMap = _vehicle getVariable "KISKA_convoyAdvanced_hashMap";
    private _convoyLead = _convoyHashMap get 0;

    [
        _vehicle,
        _convoyHashMap,
        _convoyLead
    ] call _function;

}];
_vehicle setVariable ["KISKA_convoyAdvanced_vehicleKilledEventID",_vehicleKilledEventId];
