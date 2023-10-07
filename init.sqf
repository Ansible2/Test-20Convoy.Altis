player allowDamage false;

[] spawn {

private _convoyHashMap = [
	[
		vic1,
		vic2,
		vic3,
		vic4,
		vic5
	],
	20
] call KISKA_TEST_fnc_convoy_create;


[
	vic1,
	vic2,
	vic3,
	vic4,
	vic5
] apply {
	(driver _x) setBehaviourStrong "CARELESS";
	(crew _x) apply {
		_x allowDamage false;
	};

	_x allowDamage false;
};

// [
// 	_convoyHashMap,
// 	vic1,
// 	0
// ] call KISKA_TEST_fnc_convoy_addVehicle;

// [vic3,true] call KISKA_TEST_fnc_convoy_setVehicleDebug;
[vic2,true] call KISKA_TEST_fnc_convoy_setVehicleDebug;

sleep 5;

// vic2 setDamage 1;
// (driver vic2) setDamage 1;

// vic2 setHitPointDamage["hitengine",1];
// vic2 setHitPointDamage["hitrtrack",1];

// [
// 	_convoyHashMap
// ] call KISKA_TEST_fnc_convoy_delete;


};
