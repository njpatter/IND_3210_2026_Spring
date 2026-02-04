PROGRAM main
VAR
	initBlock : P1AM_INIT;
	inputBlock : P1_16N;
	outputBlock : P1_16TR;
	analogInputBlock : P1_04AD;
	thermistor : UINT;
	valveInlet : bool;
	valveOutlet : bool;
	heaterTank : bool;
  pumpMixing : bool;
	machineState : DINT := 0;
	switchValve : bool;
	switchFloat : bool;
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
  if switchValve then
    machineState := 10;
  end_if;
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
  valveOutlet := TRUE;
30:(*Empty*)
  valveInlet := TRUE;
end_case;

END_PROGRAM