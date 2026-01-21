PROGRAM main
VAR
	myFirstDint : int;
	initBlock : P1AM_INIT;
	inputBlock : P1_08N;
	buttonOne : bool;
	outputBlock : P1_08T;
	lightTimer : TON;
	buttonCounter : CTU_DINT;
END_VAR

initBlock (
    INIT := TRUE
);
(* It is this way to add comments 
Add multiple lines

*)
inputBlock (SLOT := 1,I1 => buttonOne);

lightTimer (
    IN := buttonOne,
    PT := T#2000ms
);
buttonCounter (
    CU := buttonOne,
    R := lightTimer.Q,
    PV := 6 
);

outputBlock (
    SLOT := 2,
    O1 := buttonOne,
    O2 := lightTimer.Q,
    O5 := NOT buttonOne,
    O6 := buttonCounter.Q
);

END_PROGRAM