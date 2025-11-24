.mP "CONTROLS"
.NM "control characters ^d, ^l and ^c"
.MO "main , run , print , trace , break , delete"
.DC
The control character ^d (control-d) will exit the debugger and return to
your DAPSE.
The ^d command is similar to the 'exit' command but is available
in all modes while the 'exit' command is not available in all modes.
.sp 2
The control character ^c (control-c) interrupts a running DAS program
as soon as an event or exception is executed.
An interrupted program has state 'interrupted'.
.sp 2
The control character ^l (control-l) clears the output region of the
terminal screen and is available in all modes.
.ED
.ER
     ^c is an illegal command when the DAS program is not running.
.SE "exit , break"
