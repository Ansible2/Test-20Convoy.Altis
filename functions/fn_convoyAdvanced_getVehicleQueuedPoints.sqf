/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getVehicleQueuedPoints

Description:
    Gets a given convoy vehicle's queued points. Queued points are ATL positions that 
     that the vehicle will attempt to drive (in the order provided). These positions
     have not been added to a vehicle's drive path, but will be the following frame.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the queued points of

Returns:
    <PositionATL[]> - An array of currently queued positions

Examples:
    (begin example)
        private _queuedPoints = [_vehicle] call KISKA_fnc_convoyAdvanced_getVehicleQueuedPoints;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getVehicleQueuedPoints";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    []
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoyAdvanced_queuedPoints",[]]
