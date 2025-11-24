.mP "BREAK"
.NM "break"
.MO "main , run , print , trace , delete"
.DC
The 'break' command changes the current mode to break mode.
The commands available in the break mode allow you to set
break points at the entry and exit of subprograms, the start
and ending of the elaboration of package bodies, the execution
of statements and exceptions.
.br
By setting break points at certain events or exceptions the
debugger will prompt for a command 
whenever the event is executed
or an exception is raised during execution of the DAS program.
.br
The executed event or the raising of an exception is displayed in the output region.
.ED
.ER
     none.
.SE     "trace , delete , lines , calls , exception , context"
