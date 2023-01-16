private _convoyInfo = [
    BLUFOR,
    [
        vic1,
        vic2,
        vic3,
        vic4,
        vic5
    ]
] call KISKA_fnc_configureConvoy_test;

(_convoyInfo select 1) apply {
    _x engineOn true;
    _x setConvoySeparation 12;
};

vic1 limitSpeed 50;

_convoyInfo spawn KISKA_fnc_startConvoyFollow_basic;

// sleep 5;

private _group = _convoyInfo select 0;
hint str _group;
_group move (getPosATL movePos);



// [[["ToolKit"],[1]],[["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1],["RPG32_F",1]],[],[["B_Carryall_cbr"],[1]],[]]