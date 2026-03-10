PROGRAM main
VAR
	initBlock : P1AM_INIT;
	inputs : P1_16N;
	swTilt : bool;
	swTurn : bool;
	encTilt : bool;
	encTurn : bool;
	motorTiltUp : bool;
	motorTiltDown : bool;
	motorTurnLeft : bool;
	motorTurnRight : bool;
	ledG : bool;
	ledY : bool;
	ledR : bool;
	ledOnline : bool;
	outputs : P1_16TR;
	machineState : int := 0;
	counterTurn : CTU;
	counterTilt : CTU;
	timerProcessing : TON;
	targetTurn : INT := 40;
	targetTilt : INT := 30;
	counterBounce : INT := 1;
END_VAR

initBlock (INIT := TRUE);
inputs (SLOT := 1, I1 => swTilt, I2 => swTurn, I5 => encTilt, I7 => encTurn);
outputs (SLOT := 2,O1 := motorTiltUp,O2 := motorTiltDown,O3 := motorTurnLeft,O4 := motorTurnRight,
    O5 := ledG,O6 := ledY,O7 := ledR,O8 := ledOnline );

//The camera motion should operate to accomplish the following repeatedly:
case machineState of 
0:
  //Home turn and tilt motors
  motorTiltDown := not swTilt;
  motorTurnLeft := not swTurn;
  if swTilt and swTurn then
    machineState := 10;
    counterBounce := 1;
  end_if;
10: 
  //Move to observe the Processing Station Turntable, then observe it for 6 seconds
  counterTurn (CU := encTurn,R := False,PV := 40);
  motorTurnRight := not counterTurn.Q;
  counterTilt (CU := encTilt,R := False,PV := 20);
  motorTiltUp := not counterTilt.Q;
  timerProcessing(IN := counterTurn.Q and counterTilt.Q,PT := T#6000ms);
  if timerProcessing.Q then
    machineState := 20;
    timerProcessing(IN:=False);
  end_if;

20:  
//Move to observe the Sorting Line, then observe it for 4 seconds
  counterTurn (CU := encTurn,R := False,PV := 90);  
  motorTurnRight := not counterTurn.Q;
  counterTilt (CU := encTilt,R := False,PV := 30);
  motorTiltUp := not counterTilt.Q;
  timerProcessing(IN := counterTurn.Q and counterTilt.Q,PT := T#4000ms);
  if timerProcessing.Q then
    machineState := 30;
    timerProcessing(IN:=False);
    targetTurn := 40;
    targetTilt := 30;
    counterTurn (R:=TRUE);
    counterTilt (R:=TRUE);
  end_if;

//Perform the following 3 times
30: 
//Move to observe the Pickup Station, then observe it for 3 seconds
  counterTurn (CU := encTurn,R := False,PV := abs(targetTurn));  
  motorTurnRight := (not counterTurn.Q) and (targetTurn > 0);
  motorTurnLeft := (not counterTurn.Q) and (targetTurn < 0);
  counterTilt (CU := encTilt,R := False,PV := abs(targetTilt));
  motorTiltUp := (not counterTilt.Q) and (targetTilt > 0);
  motorTiltDown := (not counterTilt.Q) and (targetTilt < 0);
  timerProcessing(IN := counterTurn.Q and counterTilt.Q,PT := T#3000ms);
  if timerProcessing.Q then
    machineState := 40;
    timerProcessing(IN:=False);
    counterTurn (R:=TRUE);
    counterTilt (R:=TRUE);
    targetTurn := 60;
    targetTilt := 5;
  end_if;
//Move to observe the Warehouse, then observe it for 2 seconds
40:  
  counterTurn (CU := encTurn,R := False,PV := targetTurn);  
  motorTurnRight := not counterTurn.Q;
  counterTilt (CU := encTilt,R := False,PV := targetTilt);
  motorTiltUp := not counterTilt.Q;
  timerProcessing(IN := counterTurn.Q and counterTilt.Q,PT := T#2000ms);
  if timerProcessing.Q then
    machineState := 30;
    timerProcessing(IN:=False);
    counterTurn (R:=TRUE);
    counterTilt (R:=TRUE);
    counterBounce := counterBounce + 1;
    if counterBounce < 4 then
      targetTurn := -60;
      targetTilt := -5;
      machineState := 30;
    else
      machineState := 0;
    end_if;
  end_if;
//The LEDs should be turned on for the following movements:



end_case;


//Green LED when moving CCW
ledG := motorTurnLeft;
//Yellow LED when moving down
ledY := motorTiltDown;
//Red LED when moving CW OR up
ledR := motorTurnRight or motorTiltUp;
//Online LED when observing
ledOnline := not (motorTurnLeft or motorTurnRight or motorTiltDown or motorTiltUp);

END_PROGRAM