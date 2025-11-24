.mP "TRACE"
.NM "trace"
.MO "main , run , print , break , delete"
.DC
The 'trace' command will change the current mode to trace mode.
In the trace mode there are commands that allow you to set
trace points at subprogram calls and subprogram exits,
the start and end of the elaboration of package bodies and
exceptions.
.br
.br
The commands used in the trace mode to set trace points on events and
exceptions all need the name of a subprogram or package.
The notation used to enter these names is the selected component notation.
.sp
.DS
EXAMPLE :
.in +7

PPROCEDURE test IS
	PROCEDURE black IS
		PACKAGE box IS
			-- types and objects of box;
		END box;
		PACKAGE BODY box IS
		BEGIN
			-- statements of box;
		END box;
	BEGIN
		-- statements of black;
	END black;
BEGIN
	-- statements of test;
END test;
.in -7
.DE
.sp
The name of package box in selected component notation is 'test.black.box' .
The name of procedure black would be 'test.black' while that of procedure test
is simply 'test'.
.sp
In this simple example we can easily name all subprogram and packages but
in real life the DAS programs are not so simple.
With most DAS programs it would thus take a long time to name all subprograms and packages.
.sp
To prevent this long and boring task a number of shorthands are available to
be able to shorten typing of names and to include
all the subprograms and packages declared in the
declarative part of the explicitly named subprogram or package.
.sp
There are four special characters that can be used.
These characters can be seen as macro's.
The four characters are:
.AL
.LI
!
.br
the exclaim character will expand to the unit name given after
.B use
in the status region.
This unit name may be changed by the 'use' command.
.LI
#
.br
the immediate character will expand to the active library unit name.
For packages and subprograms that are not subunits the active
 library unit is the first (or perhaps only) component in the
selected component name displayed after the word
.B in
on the status region.
For subunits it is the selected component name of the subunit.
.LI
$
.br
the dollar character expands to the selected component name given after
the word
.B in
on the status region.
In effect this is the active subprogram or package.
.LI
*
.br
when the star character is used as the first and only component in the name
the effect of its use is to set trace or break points in all subprograms and
packages of the DAS program.
.br
When the star is used as the last component of a name,not only the name up to
the star is used to set trace or breakpoints but also each subprogram 
or package declared in the declarative part of the named subprogram or package
is used, recursively.So the complete subtree of the named subprogram or
package is used to set trace or breakpoints.
.LE
.ED
.ER
     none
.SE "break , delete , use"
