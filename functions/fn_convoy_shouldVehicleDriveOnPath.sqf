/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_shouldVehicleDriveOnPath

Description:
    Gets whether or not the vehicle will initiate new `setDriveOnPath`'s whenever
     a new point is added to the vehicle's drive path.
    
    While false, a vehicle will continue to receive new points in the vehicles drive path.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to check the value of

Returns:
    <BOOL> - The vehicle's state of `KISKA_convoy_doDriveOnPath`

Examples:
    (begin example)
        private _doDriveOnPath = [_vehicle] call KISKA_TEST_fnc_convoy_shouldVehicleDriveOnPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_shouldVehicleDriveOnPath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    false
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoy_doDriveOnPath",false]
