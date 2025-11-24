.mP "CALLS"
.NM "calls body_name"
.MO "trace , break , delete"
.DC
The calls command sets trace or break points (depending on the
mode you are in) at the entry and exit of subprogram bodies
or at the start and end of the elaboration of package bodies.
The name entered after the prompt enter name determines if a
subprogram or package is ment.
.br
See the help page for the 'trace' command for the body_name notation.
.ED
.ER
     not an existing body
     unit does not belong to program
     syntax error in body name
.SE "trace , break , delete , lines , exception"
