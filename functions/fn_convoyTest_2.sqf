private _convoyHashMap = [[
	vic1,
	// player
	vic2,
	vic3
	// vic4,
	// vic5
// ]] call KISKA_fnc_startConvoyFollow_advanced;
// ]] call KISKA_fnc_startConvoyFollow_stateMachine;
],10] call KISKA_fnc_convoyAdvanced_create;

// [_convoyHashMap,vic2,1] call KISKA_fnc_convoyAdvanced_addVehicle;

[] spawn {
	sleep 10;
	[vic3] call KISKA_fnc_convoyAdvanced_removeVehicle;
};

// vic1 move [3567.54,13207.9,0];




// myPos = [0,0,0];
// addMissionEventHandler ["Draw3D", {
// 	drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Radar\radar_ca.paa", [1,1,1,1], myPos, 1, 1, 45, "Target", 1, 0.05, "TahomaB"];
// }];

// private _vehicle = vic2;
// private _boundingBox = 0 boundingBoxReal _vehicle;
// private _boundingMins = _boundingBox select 0;
// private _boundingMaxes = _boundingBox select 1;

// private _relativeToFront = [0,_boundingMaxes select 1,0];
// private _vicPosition = _vehicle modelToWorldVisual _relativeToFront;
// myPos = _vicPosition;
// _vicPosition

// private _boundingBox = 0 boundingBoxReal _vehicle;
// private _boundingMins = _boundingBox select 0;
// private _boundingMaxes = _boundingBox select 1;

// private _relativeRear = [0,_boundingMins select 1,0];
// private _vicPosition = _vehicle modelToWorldVisual _relativeRear;
// myPos = _vicPosition;
// _vicPosition









// private _fn_getBumperPos = {
// 	params [
// 		"_vehicle",
// 		["_isRearBumper",false,[true]]
// 	];

// 	private ["_hashMapId","_boundingBoxIndex"];
// 	if (_isRearBumper) then {
// 		_hashMapId = "KISKA_convoy_vehicleRelativeRearHashMap";
// 		_boundingBoxIndex = 0;
// 	} else {
// 		_hashMapId = "KISKA_convoy_vehicleRelativeFrontHashMap";
// 		_boundingBoxIndex = 1;
// 	};

// 	private _relativePointHashMap = localNamespace getVariable _hashMapId;
// 	if (isNil "_relativePointHashMap") then {
// 		_relativePointHashMap = createHashMap;
// 		localNamespace setVariable [_hashMapId,_relativePointHashMap];
// 	};


// 	private _vehicleType = typeOf _vehicle;
// 	private _relativeBumperPosition = _relativePointHashMap getOrDefault [_vehicleType,[]];
// 	if (_relativeBumperPosition isEqualTo []) then {
// 		private _vehicleBoundingBoxes = 0 boundingBoxReal _vehicle;
// 		private _boundingBox = _vehicleBoundingBoxes select _boundingBoxIndex;
		
// 		_relativeBumperPosition = [0,_boundingBox select 1,0];
// 		_relativePointHashMap set [_vehicleType,_relativeBumperPosition];
// 	};
	
	
// 	_vehicle modelToWorldVisual _relativeBumperPosition;
// }; 

// myPos = [vic2] call _fn_getBumperPos;
// addMissionEventHandler ["Draw3D", {
// 	drawIcon3D ["\a3\ui_f\data\IGUI\Cfg\Radar\radar_ca.paa", [1,1,1,1], myPos, 1, 1, 45, "Target", 1, 0.05, "TahomaB"];
// }];
