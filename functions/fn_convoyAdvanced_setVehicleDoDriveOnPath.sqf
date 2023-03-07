/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_setVehicleDoDriveOnPath

Description:
    Sets whether or not the vehicle will initiate new `setDriveOnPath`'s whenever
     queued points are available to add to the actual current drive path.
    
    While false, a vehicle will continue to queue points from the vehicle ahead of it
     given it meets the normal criteria to do so.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to set the doDriveOnPath var of
    1: _mode <BOOL> - `true` to enable, `false` to disable driving on newly queued points

Returns:
    NOTHING

Examples:
    (begin example)
        // do-drive-on-path enabled 
        [
            _vehicle,
            true
        ] call KISKA_fnc_convoyAdvanced_setVehicleDoDriveOnPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_setVehicleDoDriveOnPath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_mode",false,[true]]
];


_vehicle setVariable ["KISKA_convoyAdvanced_doDriveOnPath",_mode];
