/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_create

Description:
    Creates an advanced KISKA convoy. Vehicles should be already physically placed in the order
     that they intend to travel in. If creating in an urban setting, ensure vehicles 
     are in a straight line so that they do not initially crash into a building.
    
    This will create a CBA statemachine that processes one vehicle a frame. It manages the speed
     of the vehicle relative to the vehicle in front to keep a desired spacing between them. 
     The space between each vehicle can be customized for that specific vehicle or any 
     individual one.
    
    The first vehicle added to the convoy WILL NOT have its movement managed in any capacity.
     All other vehicles will essentially follow the path of the lead vehicle. You should 
     limit the speed and control the path of the lead vehicle for your specific use case.

    A convoy requires at least one vehicle (the lead vehicle) to be valid at any given moment.
     It will be automatically deleted otherwise.

Parameters:
    0: _vics <OBJECT[]> - An array of convoy vehicles (that are in their travel order)
    1: _convoySeperation <NUMBER> - The distance between each vehicle for the convoy (min of 10)

Returns:
    <HASHMAP> - A hash map containing data pertinent to the convoy's operation

Examples:
    (begin example)
        private _convoyHashMap = [
            [leadVehicle],
            10
        ] call KISKA_TEST_fnc_convoy_create;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_create";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
	["_vics",[],[[]]],
    ["_convoySeperation",20,[123]]
];


if (_convoySeperation < 10) then {
    _convoySeperation = 10;
};

private _stateMachine = [
    [],
    true
] call CBA_stateMachine_fnc_create;


private _convoyHashMap = createHashMap;
// when using skip null in CBA_stateMachine_fnc_create
// a new array will be created and saved in the statemachine's namespace
private _convoyVehicles = _stateMachine getVariable "CBA_statemachine_list";
_convoyHashMap set ["_convoyVehicles",_convoyVehicles];

_convoyHashMap set ["_stateMachine",_stateMachine];
// set to default
[_convoyHashMap] call KISKA_TEST_fnc_convoy_setPointBuffer;
[_convoyHashMap,_convoySeperation] call KISKA_TEST_fnc_convoy_setDefaultSeperation;

_vics apply {
    [
        _convoyHashMap,
        _x
    ] call KISKA_TEST_fnc_convoy_addVehicle;
};


private _mainState = [
    _stateMachine,
    KISKA_TEST_fnc_convoy_onEachFrame
] call CBA_stateMachine_fnc_addState;


_convoyHashMap
