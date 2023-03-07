/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getVehicleDoDriveOnPath

Description:
    Gets whether or not the vehicle will initiate new `setDriveOnPath`'s whenever
     queued points are available to add to the actual current drive path.
    
    While false, a vehicle will continue to queue points from the vehicle ahead of it
     given it meets the normal criteria to do so.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to check the value of

Returns:
    <BOOL> - The vehicle's state of `KISKA_convoyAdvanced_doDriveOnPath`

Examples:
    (begin example)
        private _doDriveOnPath = [_vehicle] call KISKA_fnc_convoyAdvanced_getVehicleDoDriveOnPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getVehicleDoDriveOnPath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    false
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoyAdvanced_doDriveOnPath",false]
