--
-- package get_args gives a clean interface to the C routines,
-- that makes access to command line parameters possible
--
package GetArgs is
--
    function NumArgs return integer;

--
    procedure GetArg (NumArg	: in integer;
		      Argument	: out string;
		      ArgLength	: out integer);
end GetArgs;

package body GetArgs is



    function NumArgs return integer is
	function $num_pars return long;
    begin
	return integer ($num_pars);
    end;

    procedure GetArg	(NumArg		: in integer;
			 Argument	: out string;
			 ArgLength	: out integer) is

	procedure $get_par (numarg	: long;
			    arg		: out string;
			    length	: out long);
    begin
	$get_par (long (NumArg), Argument, long (ArgLength));
    end;

begin
    null;
end;
