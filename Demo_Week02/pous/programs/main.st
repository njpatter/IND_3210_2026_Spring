PROGRAM main
VAR
	initBlock : P1AM_INIT;
	inputs : P1_08N;
	buttonOn : bool;
	buttonEmergency : bool;
	outputs : P1_16TR;
	lightRed : bool := False;
	pump : bool := False;
	machineState : DINT := 0; 
	timeOn : time := T#1000ms;
	timeOff : time := T#1000ms;
	timeTarget : time := T#1000ms;
	timerPump : TON;
END_VAR

initBlock (INIT := TRUE);
inputs (SLOT := 1, I1 => buttonOn, I2 => buttonEmergency);
outputs (SLOT := 2,O1 := lightRed, O5 := pump);

if buttonEmergency then
    machineState := 20;
end_if;
if buttonOn and not (machineState = 20) then
    machineState := MOD (IN1 := machineState + 10,IN2 := 20); 
end_if;

case machineState of
0: // Idle state
    lightRed := False;
    pump := False;
10: // Run state
    lightRed := False;
    timerPump (IN := TRUE,PT := timeTarget);
    if timerPump.Q then
        timerPump (IN := False );
        if pump then
            timeTarget := timeOff;
            pump := False;
        else 
            timeTarget := timeOn;
            pump := True;
        end_if;
    end_if;

20: // Emergency state
    lightRed := True;
    pump := False;
end_case;

END_PROGRAM