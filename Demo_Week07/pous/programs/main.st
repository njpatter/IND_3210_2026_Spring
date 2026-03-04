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
	machineState : int := 0;
	futureState : int := 10;
	hCounter : CTU;
END_VAR

initBlock (INIT := TRUE);
inputBlock (SLOT := 1, I1 => bH, I2 => lbIn, I3 => lbOut, I4 => bV,
            I5 => encH, I7 => encV, I9 => bArmf, I10 => bArmB);
outputBlock (SLOT := 2,O1 := convFwd,O2 := convBack,O3 := hFwd,O4 := hBack,
    O5 := vDown,O6 := vUp,O7 := armFwd,O8 := armBack);

convFwd := True;



case machineState of
0:
// Home machine
//      Retract arm
//      Horizontal home
//      Vertical home
  armBack := not bArmB;
  if bArmB then
    hBack := not bH;
    vUp := not bV;  
  end_if;
  if bArmB and bH and bV then
    machineState := futureState;
  end_if;

10: 
// Deliver first empty crate to conveyor
//      Move to horiz pos
  hFwd := True;
  hCounter (CU := encH,R := FALSE,PV := 20);
  if hCounter.Q then
    hFwd := FALSE;
    machineState := 20;
    hCounter ( R := True );
  end_if;
//      Move to vert pos
//      Extend arm
//      Move up small amt
//      Retract arm
//      Home horiz
//      Home vert
//      Move down to conveyor
//      Move conveyor fwd

end_case;




// Wait for robot arm
//      Move conveyor back

// Return filled crate to prev pos
//      Retract arm
//      Home vert
//      Move to horiz pos
//      Move to vert pos
//      Extend arm
//      Move down a little
//      Retract arm
// Home again




END_PROGRAM