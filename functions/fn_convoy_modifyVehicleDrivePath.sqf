/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_modifyVehicleDrivePath

Description:
	Changes the drive path of a given convoy vehicle.

    The drive path will be overwritten from the _lastIndexToModify (inclusive) backwards 
     until all of the _pointsToAdd have been placed in the array. This means that 
     this function is not capable of appending to the end of an array, but only adding 
     to the front.
    
Parameters:
    0: _vehicle <OBJECT> - The vehicle to modify the drive path of
    1: _lastIndexToModify <NUMBER> - The (inclusive) index to stop the modification at
    2: _pointsToAdd <PositionATL[]> - The array of ATL positions to set to

Returns:
    NOTHING

Examples:
    (begin example)
		// overwrite array entirely
		[
            _vehicle,
            -1, // without deleting any points in current drive path, add positions to the front of path
            [
                [12,34,56],
                [12,34,58]
            ]
        ] call KISKA_TEST_fnc_convoy_modifyVehicleDrivePath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_modifyVehicleDrivePath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_lastIndexToModify",0,[123]],
    ["_pointsToAdd",[],[[]]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null"] call KISKA_fnc_log;
    nil
};


private _modificationRange = count _pointsToAdd;
private _vehicleDrivePath = [_vehicle] call KISKA_TEST_fnc_convoy_getVehicleDrivePath;
if (_vehicleDrivePath isEqualTo []) then {
    _vehicleDrivePath insert [0,_pointsToAdd];

} else {
    private _vehiclesDrivePathCount = count _vehicleDrivePath;
    private _startIndex = _lastIndexToModify - _modificationRange;
    if (_startIndex < 0) then {
        _modificationRange = _modificationRange + _startIndex;
        _startIndex = 0;
    };


    if (_modificationRange >= 0) then {
        _vehicleDrivePath deleteRange [_startIndex, _modificationRange];
    };
    _vehicleDrivePath insert [_startIndex, _pointsToAdd];

};


if ([_vehicle] call KISKA_TEST_fnc_convoy_shouldVehicleDriveOnPath) then {
    _vehicle setDriveOnPath _vehicleDrivePath;
};
