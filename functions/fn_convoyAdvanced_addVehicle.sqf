/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_addVehicle

Description:
    Adds a given vehicle to a convoy. The index returned will be a key to the
     _convoyHashMap that can be used to get the vehicle for that index in the convoy.

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to add to
    1: _vehicle <OBJECT> - The vehicle to add
    2: _insertIndex <NUMBER> - The index to insert the vehicle into the convoy at. 
        Negative value means the back.
        (0 is lead vehicle, 1 is vehicle directly behind leader, etc.)

    3: _convoySeperation <NUMBER> - How far the vehicle should keep from the 
        vehicle in front (min of 10)

Returns:
    <NUMBER> - The index the vehicle was inserted into the convoy at

Examples:
    (begin example)
        private _convoyMap = [] call KISKA_fnc_convoyAdvanced_create;
        private _spotInConvoy = [
            _convoyMap,
            vic
        ] call KISKA_fnc_convoyAdvanced_addVehicle;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_addVehicle";

#define MAX_ARRAY_LENGTH 1E7
#define MIN_CONVOY_SEPERATION 10

params [
    ["_convoyHashMap",nil,[createHashMap]],
    ["_vehicle",objNull,[objNull]],
    ["_insertIndex",-1,[123]],
    ["_convoySeperation",-1,[123]]
];


if (isNil "_convoyHashMap") exitWith {
    ["nil _convoyHashMap passed",true] call KISKA_fnc_log;
    -1
};

if (isNull _vehicle) exitWith {
    ["_vehicle is null",true] call KISKA_fnc_log;
    -1
};

private _driver = driver _vehicle;
if !(alive _driver) exitWith {
    [["_vehicle ",_vehicle," does not have an alive driver"],false] call KISKA_fnc_log;
    -1
};

private _convoyStatemachine = _convoyHashMap get "_stateMachine";
if (isNil "_convoyStatemachine") exitWith {
    [["_stateMachine is not defined in map: ",_convoyHashMap],true] call KISKA_fnc_log;
    -1
};

private _convoyLead = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyLeader;
if ((speed _convoyLead) > 0) exitWith {
    [["_convoyLead ",_convoyLead," is moving, must be stopped to add vehicles to the convoy"]] call KISKA_fnc_log;
    nil
};

private _convoyVehicles = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
if (_vehicle in _convoyVehicles) exitWith {
    [["_vehicle ",_vehicle," is already in _convoyHashMap ",_convoyHashMap],true] call KISKA_fnc_log;
    [_vehicle] call KISKA_fnc_convoyAdvanced_getVehicleIndex
};




if (_convoyVehicles isEqualTo []) then {
    _convoyHashMap set ["_convoyLead",_vehicle];
};


private _convoyCount = count _convoyVehicles;
private "_convoyIndex";
if (_insertIndex < 0) then {
    _convoyIndex = _convoyVehicles pushBack _vehicle;
    _convoyHashMap set [_convoyIndex,_vehicle];

} else {
    private _vehiclesToChangeIndex = _convoyVehicles select [_insertIndex,MAX_ARRAY_LENGTH];
    
    _convoyVehicles resize _insertIndex;
    _convoyIndex = _convoyVehicles pushBack _vehicle;
    _convoyVehicles append _vehiclesToChangeIndex;
    _convoyHashMap set [_convoyIndex,_vehicle];
    if (_insertIndex isEqualTo 0) then {
        _convoyHashMap set ["_convoyLead",_vehicle];
    };

    _vehiclesToChangeIndex apply {
        private _currentIndex = [_x] call KISKA_fnc_convoyAdvanced_getVehicleIndex;
        if (_currentIndex isEqualTo -1) then {
            [["Could not find 'KISKA_convoyAdvanced_index' in namespace of ", _x," to change"],true] call KISKA_fnc_log;
            continue
        };

        private _newIndex = _currentIndex + 1;
        _convoyHashMap set [_newIndex,_x];
        _x setVariable ["KISKA_convoyAdvanced_index",_newIndex];
    };
};


_vehicle setVariable ["KISKA_convoyAdvanced_hashMap",_convoyHashMap];
_vehicle setVariable ["KISKA_convoyAdvanced_index",_convoyIndex];

if (_convoySeperation < 0) then {
    _convoySeperation = [
        _convoyHashMap
    ] call KISKA_fnc_convoyAdvanced_getDefaultSeperation;

} else {
    if (_convoySeperation < MIN_CONVOY_SEPERATION) then {
        _convoySeperation = MIN_CONVOY_SEPERATION
    };

};
_vehicle setVariable ["KISKA_convoyAdvanced_seperation",_convoySeperation];


_convoyIndex
