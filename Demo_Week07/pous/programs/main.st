PROGRAM main
VAR
	initBlock : P1AM_INIT;
	inputBlock : P1_16N;
	outputBlock : P1_16TR;
	convFwd : bool;
	convBack : bool;
	hBack : bool;
	hFwd : bool;
	vDown : bool;
	vUp : bool;
	armFwd : bool;
	armBack : bool;
	bH : bool;
	lbIn : bool;
	lbOut : bool;
	bV : bool;
	encH : bool;
	encV : bool;
	bArmF : bool;
	bArmB : bool;
	signalFromPickupStation : bool;
	machineState : int := 0;
	futureState : int := 10;
	hCounter : CTU;
	vCounter : CTU;
	targetV : int ;
	targetConveyorVertical :INT := 200;
	targetH : int ;
	incV : int := 50;
	incH : int := 10;
	initialV : int := 10;
	initialH : int := 140;
	delta : int := 15;
	isCrateFilled : ARRAY[0..8] of bool;
	i : INT := 0;
END_VAR

initBlock (INIT := TRUE);
inputBlock (SLOT := 1, I1 => bH, I2 => lbIn, I3 => lbOut, I4 => bV,
            I5 => encH, I7 => encV, I9 => bArmf, I10 => bArmB, 
            I11 => signalFromPickupStation);
outputBlock (SLOT := 2,O1 := convFwd,O2 := convBack,O3 := hFwd,O4 := hBack,
    O5 := vDown,O6 := vUp,O7 := armFwd,O8 := armBack);


// customBoolArray : ARRAY[0..7] OF BOOL;


case machineState of
0:
// Home machine
//      Retract arm
//      Horizontal home
//      Vertical home
// Set targets when appropriate!
  armBack := not bArmB;
  if bArmB then
    hBack := not bH;
    vUp := not bV;  
  end_if;
  if bArmB and bH and bV then
    machineState := futureState;
    if futureState = 10 then
      for i:=0 to 8 do
        if not isCrateFilled[i] then
          exit;
        end_if;
      end_for;
      targetH := initialH + incH * MOD (IN1 := i,IN2 := 3);
      targetV := initialV + incV * i / 3;
    end_if;
  end_if;

10: 
// Deliver first empty crate to conveyor
//      Move to horiz pos
  hFwd := True;
  hCounter (CU := encH,R := FALSE,PV := targetH);
  if hCounter.Q then
    hFwd := FALSE;
    machineState := 20;
    hCounter ( R := True );
  end_if;

20:
//      Move to vert pos
  vDown := True;
  vCounter (CU := encV,R := FALSE,PV := targetV);
  if vCounter.Q then
    vDown := False;
    vCounter ( R := True);
    machineState := 30;
  end_if;
30:
  //      Extend arm
  armFwd := not bArmF;
  if bArmF then
    //      Move up small amt
    vUp := True;
    vCounter (CU := encV,R := FALSE,PV := delta);
    if vCounter.Q then
      vUp := False;
      vCounter ( R := True);
      //      Retract arm 
      //      Home horiz
      //      Home vert
      futureState := 40;
      machineState := 0;
    end_if;
  end_if;
40: 
//      Move down to conveyor and out
  armFwd := not bArmF;
  vDown := True;
  vCounter(CU:= encV, R:=False, PV:= targetConveyorVertical);
  if vCounter.Q then
    vDown := False;
  end_if;
  if vCounter.Q and bArmF then
    machineState := 50;
    vCounter(R:= True);
  end_if;

50:
//      Move conveyor fwd
  convFwd := lbOut;
  // Wait for robot arm
  if not lbOut  then //and signalFromPickupStation
    machineState := 60;
  end_if;
60:
  //      Move conveyor back
  convBack := lbIn;
  if not lbIn then
    machineState := 70;
  end_if; 
70:
  // Return filled crate to prev pos
  // Move up a little to pick up crate
  //      Retract arm
  //      Home vert
  vUp := True;
  vCounter(CU:= encV, R:= False, PV := targetConveyorVertical - 10);
  if vCounter.Q then
    vUp := False;
    vCounter(R:= True);
    machineState := 0;
    futureState:= 80;
  end_if;
80: 
//      Move to horiz pos
  hFwd := True;
  hCounter (CU := encH,R := FALSE,PV := targetH);
  if hCounter.Q then
    hFwd := FALSE;
    machineState := 90;
    hCounter ( R := True );
  end_if;
90: 
//      Move to vert pos 
  vDown := True;
  vCounter (CU := encV,R := FALSE,PV := targetV - delta);
  if vCounter.Q then
    vDown := False;
    vCounter ( R := True);
    machineState := 100;
  end_if;
100:
//      Extend arm
//      Move down a little
  armFwd := not bArmF;
  if bArmF then
    vDown := not vCounter.Q;
    vCounter (CU := encV,R := FALSE,PV := delta);
    if vCounter.Q then
      vDown := False;
      vCounter ( R := True);
      isCrateFilled[i] := True;
      machineState := 0;
      futureState := 10;
    end_if;
  end_if; 
end_case;




//      Retract arm
// Home again

END_PROGRAM