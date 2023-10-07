/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_getPointBuffer

Description:
    Gets the minimum distance that must be between each position added to a vehicles
     drive path. Essentially how often the lead vehicle's position is recorded.
    
Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to get the value from

Returns:
    <NUMBER> - The minimum distance between each drive path point

Examples:
    (begin example)
        private _minBufferBetweenPoints = [
            _convoyHashMap
		] call KISKA_TEST_fnc_convoy_getPointBuffer;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_getPointBuffer";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    -1
};

params ["_convoyHashMap"];


_convoyHashMap getOrDefault ["_minBufferBetweenPoints",1]
