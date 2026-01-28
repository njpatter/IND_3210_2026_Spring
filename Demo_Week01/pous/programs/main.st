PROGRAM main
VAR
	myFirstDint : int;
	initBlock : P1AM_INIT;
	inputBlock : P1_08N;
	buttonOne : bool;
	buttonTwo : bool;
	outputBlock : P1_08T;
	lightTimer : TON;
	buttonCounter : CTU_DINT;
	redOne : bool;
	yellowOne : bool;
	greenOne : bool := TRUE;
	whiteOne : bool;
	redTwo : bool := TRUE;
	yellowTwo : bool;
	greenTwo : bool;
	whiteTwo : bool;
	machineState : dint := 0;
	timerTarget : time := T#2000ms;
	timeGreen : time := T#2000ms;
	timeYellow : time := T#1000ms;
END_VAR

initBlock (
    INIT := TRUE
);

inputBlock (SLOT := 1,I1 => buttonOne, I2 => buttonTwo);

lightTimer (
    IN := NOT buttonTwo,
    PT := timerTarget
); 

if lightTimer.Q then
    machineState := machineState + 10;
    if machineState > 10 then
        machineState := 0;
    end_if;
    lightTimer(IN:= FALSE);
end_if;

case machineState of 
0:
    greenOne := True;
    redTwo := True;
    yellowOne := FALSE;
    timerTarget := timeGreen;
10:
    greenOne := FALSE;
    redTwo := FALSE;
    yellowOne := True;
    timerTarget := timeYellow;
end_case;

redOne := lightTimer.Q;

outputBlock (
    SLOT := 2,
    O1 := redOne,
    O2 := yellowOne,
    O3 := greenOne,
    O4 := whiteOne,
    O5 := redTwo,
    O6 := yellowTwo,
    O7 := greenTwo,
    O8 := whiteTwo
);

END_PROGRAM