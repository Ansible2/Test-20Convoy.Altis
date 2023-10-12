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

// debug completion area of vehicle
// addMissionEventHandler ["DRAW3D",{
// 	_thisArgs params ["_vic"];
// 	private _color = [0,1,0,1];

// 	private _dimensions = [_vic] call KISKA_fnc_getBoundingBoxDimensions;
// 	_dimensions params ["_length","_width","_height"];
// 	private _halfLength = _length / 2;
// 	private _halfHeight = _height;

// 	private _heightOffset = [0,0,_halfHeight];
// 	private _frontCenter = (_vic getRelPos [_halfLength,0]) vectorAdd _heightOffset;
// 	private _sideOffset = [_width,0,0];
// 	private _frontLeft = _frontCenter vectorDiff (_vic vectorModelToWorldVisual _sideOffset);
// 	private _frontRight = _frontCenter vectorAdd (_vic vectorModelToWorldVisual _sideOffset);
	
// 	private _rearCenter = (_vic getRelPos [_halfLength,180]) vectorAdd _heightOffset;
// 	private _rearLeft = _rearCenter vectorDiff (_vic vectorModelToWorldVisual _sideOffset);
// 	private _rearRight = _rearCenter vectorAdd (_vic vectorModelToWorldVisual _sideOffset);

// 	private _frontTopLeft = _frontLeft vectorAdd _heightOffset;
// 	private _frontTopRight = _frontRight vectorAdd _heightOffset;
// 	private _frontBottomLeft = _frontLeft vectorDiff _heightOffset;
// 	private _frontBottomRight = _frontRight vectorDiff _heightOffset;

// 	private _rearTopLeft = _rearLeft vectorAdd _heightOffset;
// 	private _rearTopRight = _rearRight vectorAdd _heightOffset;
// 	private _rearBottomLeft = _rearLeft vectorDiff _heightOffset;
// 	private _rearBottomRight = _rearRight vectorDiff _heightOffset;


// 	// length
// 	drawLine3D [_frontTopLeft, _rearTopLeft, _color];
// 	drawLine3D [_frontTopRight, _rearTopRight, _color];
// 	drawLine3D [_frontBottomLeft, _rearBottomLeft, _color];
// 	drawLine3D [_frontBottomRight, _rearBottomRight, _color];
	
// 	// width
// 	drawLine3D [_frontTopLeft, _frontTopRight, _color];
// 	drawLine3D [_rearTopLeft, _rearTopRight, _color];
// 	drawLine3D [_frontBottomLeft, _frontBottomRight, _color];
// 	drawLine3D [_rearBottomLeft, _rearBottomRight, _color];

// 	// height
// 	drawLine3D [_frontTopLeft, _frontBottomLeft, _color];
// 	drawLine3D [_frontTopRight, _frontBottomRight, _color];
// 	drawLine3D [_rearTopLeft, _rearBottomLeft, _color];
// 	drawLine3D [_rearTopRight, _rearBottomRight, _color];
// },[vic2]];

sleep 5;

// vic2 setDamage 1;
// (driver vic2) setDamage 1;

// vic2 setHitPointDamage["hitengine",1];
// vic2 setHitPointDamage["hitrtrack",1];

// [
// 	_convoyHashMap
// ] call KISKA_TEST_fnc_convoy_delete;


};
