/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_getVehicleDrivePath

Description:
    Gets a given convoy vehicle's current drive path. This will return the reference
     to the actual array used with `setDriveOnPath` for the vehicle's following.
    
    You should not set a vehicle's drive path directly. If you want to overwrite a vehicle's
     current path, use KISKA_TEST_fnc_convoy_modifyVehicleDrivePath.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the drive path of

Returns:
    <PositionATL[]> - An array of the current vehicle's path that it is following

Examples:
    (begin example)
        private _currentDrivePath = [_vehicle] call KISKA_TEST_fnc_convoy_getVehicleDrivePath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_getVehicleDrivePath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    []
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoy_drivePath",[]]
