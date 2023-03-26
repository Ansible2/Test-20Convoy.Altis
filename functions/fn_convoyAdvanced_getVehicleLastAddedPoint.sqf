/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getVehicleLastAddedPoint

Description:
    Gets the last position added to the vehicle's drive path from the LEAD VEHICLE.

    This does not include modified positions from KISKA_fnc_convoyAdvanced_modifyVehicleDrivePath.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the drive path of

Returns:
    <PositionATL or NIL> - The last position to be added to the vehicle's drive path
     from the lead vehicles position.

Examples:
    (begin example)
        private _lastAddedPositionFromLead = [
            _vehicle
        ] call KISKA_fnc_convoyAdvanced_getVehicleLastAddedPoint;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getVehicleLastAddedPoint";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    []
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable "KISKA_convoyAdvanced_lastAddedPoint"
