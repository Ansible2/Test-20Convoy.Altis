/* ----------------------------------------------------------------------------
Function: KISKA_fnc_getBumperPositionRelative

Description:
    Gets the PositionRelative of a vehicles front or rear bumper.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the bumper position of
    1: _isRearBumper <BOOL> - True for rear bumper, false for front bumper

Returns:
    <PositionRelative> - The world position of the vehicle's bumper

Examples:
    (begin example)
        private _rearBumperPositionRelatives = [vic,true] call KISKA_fnc_getBumperPositionRelative;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_getBumperPositionRelative";

params [
    ["_vehicle",objNull,[objNull]],
    ["_isRearBumper",false,[true]]
];

private _boundingBoxIndex = 0;
if (!_isRearBumper) then {
    _boundingBoxIndex = 1;
};

private _vehicleBoundingBoxes = 0 boundingBoxReal _vehicle;
private _boundingBox = _vehicleBoundingBoxes select _boundingBoxIndex;
private _relativeBumperPosition = [0,_boundingBox select 1,0];


_relativeBumperPosition
