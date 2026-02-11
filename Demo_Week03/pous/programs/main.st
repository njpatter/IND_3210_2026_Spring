PROGRAM main
VAR
	initBlock : P1AM_INIT;
	inputBlock : P1_16N;
	outputBlock : P1_16TR;
	analogInputBlock : P1_04AD;
	thermistor : uint;
	valveInlet : bool;
	valveOutlet : bool;
	heaterTank : bool;
	pumpMixing : bool;
	machineState : dint := 0;
	switchValve : bool;
	switchFloat : bool;
	targetTemp : uint := 8000;
	trackedTemp : uint := 12000;
	timerFill : TON;
	timerTemp : TON;
	countSwitch : CTU;
END_VAR

initBlock (INIT := TRUE);
inputBlock (SLOT := 1, I1 => switchValve, I2 => switchFloat);
outputBlock (SLOT := 2, O1:= valveInlet, O2:= valveOutlet, O3:= heaterTank, O4:= pumpMixing);
analogInputBlock (SLOT := 3, I3 => thermistor);

(*valveInlet := thermistor < 8500;
valveOutlet := thermistor < 8200;
heaterTank := thermistor < 8000;
pumpMixing := thermistor < 7500;*)

case machineState of 
0: (*Idle*)
  valveInlet := False;
  valveOutlet := False;
  heaterTank := False;
  pumpMixing := False;
  countSwitch (CU := switchValve,R := False,PV := 6);
  if countSwitch.Q then
    //countSwitch.R = True; // This won't actually reset the counter right now
    //countSwitch(); // This would finish reseting the counter
    countSwitch (R := TRUE);
    machineState := 10;
  end_if;
  //if switchValve then
  //  machineState := 10;
  //end_if;
10:(*Fill*)
  valveInlet := TRUE;
  timerFill (
      IN := TRUE,
      PT := T#5000ms
  );
  if timerFill.Q then
    timerFill(IN:=False);
    machineState := 20;
    valveInlet := False;
  end_if;
20:(*Mixing*)
  heaterTank := True;
  pumpMixing := True;
  trackedTemp := min(trackedTemp, thermistor);
  timerTemp(IN:=targetTemp > trackedTemp, PT:= T#3s);
  if timerTemp.Q then
    trackedTemp := 12000;
    heaterTank := False;
    pumpMixing := False;
    machineState := 30;
  end_if;

30:(*Empty*)
    valveOutlet := True;
    if switchFloat then
      valveOutlet := False;
      machineState := 0;
    end_if;
end_case;

END_PROGRAM