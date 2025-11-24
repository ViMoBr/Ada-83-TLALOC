.mP "ALL"
.NM "all"
.MO "print"
.DC
The 'all' command lists the called subprograms or elaborated packages.
.br
Subprograms not called or packages not elaborated are not listed.
.br
After each subprogram or package name the number of times the subprogram is
called or the package is elaborated is printed.
.sp 
.DS
Example:
.sp 2
.in +20
main-> 1
.br
main.program-> 1
.in -20
.DE
.sp
The example above shows you that for instance package 'main' has been elaborated
once and procedure 'program' within the body of package main has been called once.
.ED
.ER
     none
.SE "last , stack , context"
