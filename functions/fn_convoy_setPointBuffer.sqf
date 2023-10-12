/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_setPointBuffer

Description:
    Sets the minimum distance that must be between each position added to a vehicles
     drive path. Essentially how often the lead vehicle's position is recorded.
    
Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to get the value from
    1: _minBufferBetweenPoints <NUMBER> - The distance between positions in order for
        them to be added to the convoy drive path

Returns:
    NOTHING

Examples:
    (begin example)
        [_convoyHashMap,1] call KISKA_TEST_fnc_convoy_setPointBuffer;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_setPointBuffer";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    "_convoyHashMap",
    ["_minBufferBetweenPoints",3,[123]]
];

_convoyHashMap set ["_minBufferBetweenPoints",_minBufferBetweenPoints];
