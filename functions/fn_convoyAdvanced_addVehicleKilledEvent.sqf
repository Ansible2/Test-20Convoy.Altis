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

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];


if (isNull _vehicle) exitWith {
    ["_vehicle is null",true] call KISKA_fnc_log;
    nil
};


private _vehicleKilledEventId = _vehicle addMPEventHandler ["MPKILLED", {
    if (isServer) then {
        _this params ["_vehicle"];

        private _convoyHashMap = [
            _vehicle
        ] call KISKA_fnc_convoyAdvanced_getConvoyHashMapFromVehicle;

        if (isNil "_convoyHashMap") then {
            [["_convoyHashMap was nil, event was for _vehicle: ",_vehicle],true] call KISKA_fnc_log;

        } else {
            private _function = [
                _vehicle
            ] call KISKA_fnc_convoyAdvanced_getVehicleKilledEvent;
            private _convoyLead = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyLeader;

            [
                _vehicle,
                _convoyHashMap,
                _convoyLead
            ] call _function;

        };
    };

}];

_vehicle setVariable ["KISKA_convoyAdvanced_vehicleKilledEventID",_vehicleKilledEventId];
