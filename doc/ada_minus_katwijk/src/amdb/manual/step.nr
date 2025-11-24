.mP "STEP"
.NM "step"
.MO "main , run"
.DC
The 'step' command  starts or continues the DAS program.
If the state of the DAS program is fetched, terminated, aborted or killed
the program is started, in any other state the program is continued.
.br
As soon as the program has executed an event or an exception is raised
the DAS program is interrupted (state is break), the output region
displays the event or exception and the debugger will be back in control.
.ED
.ER
     no DAS program specified yet.
.SE "run , after , cont"
