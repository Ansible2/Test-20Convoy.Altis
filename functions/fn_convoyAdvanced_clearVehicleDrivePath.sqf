/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_clearVehicleDrivePath

Description:
	Clears a vehicle's current drive path, meaning the array that has been
     used with the vehicle to `setDriveOnPath`. This does NOT stop the vehicle's
     current movement on the previous path.

    You should not set a vehicle's drive path directly. If you want to overwrite a vehicle's
     current path, clear the drive path (KISKA_fnc_convoyAdvanced_clearVehicleDrivePath) 
     and then queue the new points (KISKA_fnc_convoyAdvanced_setVehicleQueuedPoints). 
     To add points to the existing path, only queue points and do NOT clear the current drive path.
     
    
Parameters:
    0: _vehicle <OBJECT> - The vehicle to clear the drive path of

Returns:
    NOTHING

Examples:
    (begin example)
		[_vehicle] call KISKA_fnc_convoyAdvanced_clearVehicleDrivePath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_clearVehicleDrivePath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null"] call KISKA_fnc_log;
    nil
};


_vehicle setVariable ["KISKA_convoyAdvanced_drivePath",[]];
