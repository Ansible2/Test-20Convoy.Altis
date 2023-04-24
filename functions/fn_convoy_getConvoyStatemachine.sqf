/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoy_getConvoyStatemachine

Description:
    Returns the CBA statemachine used to control convoy movement and speed. 

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap get the statemachine from

Returns:
    <LOCATION> - The CBA statemachine

Examples:
    (begin example)
        private _convoyStatemachine = [
            SomeConvoyHashMap
        ] call KISKA_fnc_convoy_getConvoyStatemachine;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoy_getConvoyStatemachine";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    locationNull
};

params ["_convoyHashMap"];


_convoyHashMap getOrDefault ["_stateMachine",locationNull]
