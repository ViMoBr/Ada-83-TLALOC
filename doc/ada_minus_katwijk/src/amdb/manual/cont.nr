.mP "CONT"
.NM "cont"
.MO "main , run"
.DC
The 'cont' command executes the program one event or exception
at the time.
In this way it is very similar to the 'step' command.
The 'cont' command differs with the 'step' command when a statement
has been executed.
The 'step' command displays only the source of the statement while the
'cont' command displays also the context of the statement.
Context means here the lines textually preceding and following the
executed statement.
The executed line itself is typed bold.
.ED
.ER
'cont' only allowed when program has been given.
.SE "context , step , after , run"
