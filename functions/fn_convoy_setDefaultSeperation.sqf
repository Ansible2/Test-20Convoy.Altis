/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_setDefaultSeperation

Description:
    Sets the default seperation between NEWLY added vehicles to a convoy.
    
    This will NOT update the spacing between any vehicles currently in the convoy.

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to set the value in
    1: _seperation <NUMBER> - The default distance between vehicles

Returns:
    NOTHING

Examples:
    (begin example)
        [_convoyHashMap,20] call KISKA_TEST_fnc_convoy_setDefaultSeperation;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_setDefaultSeperation";

#define MIN_CONVOY_SEPERATION 10

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    "_convoyHashMap",
    ["_seperation",20,[123]]
];


if (_seperation < MIN_CONVOY_SEPERATION) then {
    _seperation = MIN_CONVOY_SEPERATION;
};
_convoyHashMap set ["_convoySeperation",_seperation];
