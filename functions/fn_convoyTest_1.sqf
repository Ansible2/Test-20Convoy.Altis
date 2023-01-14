#include "..\data.hpp"

private _convoyInfo = [
    BLUFOR,
    [
        vic1,
        vic2,
        vic3
    ]
] call KISKA_fnc_configureConvoy_test;

private _convoyGroup = _convoyInfo select 0;
_convoyGroup setFormation "COLUMN";

{
    _x engineOn true;
    _x setConvoySeparation 10;
    if (_forEachIndex isEqualTo 0) then {
        _x limitSpeed 50;
        continue
    };

    _x forceFollowRoad true;
} forEach (_convoyInfo select 1);

_convoyGroup setBehaviourStrong "SAFE";
// _convoyGroup setCombatBehaviour "SAFE";
_convoyGroup setCombatMode "BLUE";
_convoyGroup move (getPosATL movePos);

_convoyInfo spawn {
    params ["_convoyGroup","_vics"];
    private _leader = leader _convoyGroup;
    
    while {true} do {
        private _updates = [];
        private _stoppedVics = [];
        {
            private _driver = driver _x;
            if (_driver isEqualTo _leader) then {continue};

            private _maxAcceptedDistance = 25 * _forEachIndex;
            private _distanceToLeader = _driver distance2D _leader;
            if (_distanceToLeader > _maxAcceptedDistance) then {
                
                _updates pushBack _driver;
                _stoppedVics pushBack _x;
                _x forceFollowRoad false;
                
                diag_log (str [_distanceToLeader,_maxAcceptedDistance,_driver,_leader]);
                hint str [_distanceToLeader,_maxAcceptedDistance,_driver,_leader];
                
                _x setVariable ["toldToFollow",true];
                continue;
            };

            if (_x getVariable ["toldToFollow",false] AND (isOnRoad _x)) then {
                diag_log (str [_driver,_leader,"reset"]);
                hint str [_driver,_leader,"reset"];
                _x setVariable ["toldToFollow",false];
                _x forceFollowRoad true;
            };
        } forEach _vics;

        if (_updates isNotEqualTo []) then {
            _updates doFollow _leader;
        };

        sleep 1;
    };

};
