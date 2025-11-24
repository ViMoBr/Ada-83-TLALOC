.mP "AFTER"
.NM "after number"
.MO "main , run"
.DC
The 'after' command (re)starts or continues the DAS program but interrupts the
program after number events are executed.
If less then number events are executed but an exception is raised the
program is also interrupted.
The number entered must be greater than zero.
If the number entered is equal to zero nothing will happen.
.br
The 'after' command has as a side effect that previously set trace or
break points at certain events are ignored (but not deleted).
.ED
.ER
     a negative number will cause an error message.
.SE "run , step , cont"
