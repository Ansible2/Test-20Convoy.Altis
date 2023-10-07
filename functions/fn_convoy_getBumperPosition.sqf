/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_getBumperPosition

Description:
    Gets the positionWorld of a vehicles front or rear bumper.
    This function caches values in a hashmap for use in the frame by frame calls
     in KISKA's advanced convoy.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the bumper position of
    1: _isRearBumper <BOOL> - True for rear bumper, false for front bumper

Returns:
    <PositionWorld> - The world position of the vehicle's bumper

Examples:
    (begin example)
        private _rearBumperPositionWorld = [vic,true] call KISKA_TEST_fnc_convoy_getBumperPosition;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_getBumperPosition";

params [
    ["_vehicle",objNull,[objNull]],
    ["_isRearBumper",false,[true]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null",false] call KISKA_fnc_log;
    [0,0,0]
};


private _hashMapId = "KISKA_convoy_vehicleRelativeRearHashMap";
if (!_isRearBumper) then {
    _hashMapId = "KISKA_convoy_vehicleRelativeFrontHashMap";
};

private _relativePointHashMap = localNamespace getVariable _hashMapId;
if (isNil "_relativePointHashMap") then {
    _relativePointHashMap = createHashMap;
    localNamespace setVariable [_hashMapId,_relativePointHashMap];
};


private _vehicleType = typeOf _vehicle;
private _relativeBumperPosition = _relativePointHashMap get _vehicleType;

if !(isNil "_relativeBumperPosition") exitWith {
    _vehicle modelToWorldVisualWorld _relativeBumperPosition
};


_relativeBumperPosition = [_vehicle,_isRearBumper] call KISKA_fnc_getBumperPositionRelative;
_relativePointHashMap set [_vehicleType,_relativeBumperPosition];


_vehicle modelToWorldVisualWorld _relativeBumperPosition
