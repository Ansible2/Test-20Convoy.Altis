/* ----------------------------------------------------------------------------
Function: KISKA_fnc_selectLastIndex

Description:
    Returns the last index of an array or a spcified default value

Parameters:
    0: _array <ARRAY> - The vehicle to use setDriveOnPath command on
    1: _defaultValue <ANY> - The default value to return if the array is empty (defaults to nil)

Returns:
    <ANY> - The last index of the array value or _defaultValue

Examples:
    (begin example)
        private _array = [1,2,3];
        private _value = [_array] call KISKA_fnc_selectLastIndex;
        // hint 3
        hint str _value;
    (end)
    
    (begin example)
        private _array = [];
        private _value = [_array] call KISKA_fnc_selectLastIndex;
        // hint true
        hint str (isNil "_value");
    (end)
    
    (begin example)
        private _array = [];
        private _value = [_array,-1] call KISKA_fnc_selectLastIndex;
        // hint -1
        hint str _value;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_selectLastIndex";

params [
    ["_array",[],[[]]],
    ["_defaultValue",nil]
];

private _lastIndex = (count _array) - 1;
_array param [_lastIndex,_defaultValue]
