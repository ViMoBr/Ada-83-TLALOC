.mP "USE"
.NM "use unit_name"
.MO "trace , break , delete"
.DC
The 'use' command changes the library unit name given after the word
.B use
in the status region.
The use of the special character '!' as the first or only component in a
subprogram or package name (see the 'trace' command) will expand the
'!' character to this library unit name.
.br
The entered library unit must be one of the libary units that belong to
the DAS program.
.ED
.ER
     the library unit does not belong to the program.
.SE "list , trace, with"
