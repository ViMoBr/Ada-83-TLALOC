--	readable part of package standard
--
--	j van katwijk
--
--	note: to compile this file a special version
--	      of the compiler has to be used, one that
--	      is capable of dealing with a sequence
--	      of declarations
--
--
--	first the exceptions. Note : do not move them,
--	some data is related to the place of the definitions!!!!
$_program_error		: exception;
program_error		: exception renames $_program_error;
$_constraint_error	: exception;
constraint_error	: exception renames $_constraint_error;
$_numeric_error		: exception;
numeric_error		: exception renames $_numeric_error;
$_tasking_error		: exception;
tasking_error		: exception renames $_tasking_error;
$_storage_error		: exception;
storage_error		: exception renames $_storage_error;

subtype integer		is $_integer;
subtype short		is $_short;
subtype long		is $_long;
subtype duration	is $_long;

subtype NATURAL is integer range 0 .. INTEGER 'LAST;
subtype POSITIVE is integer range 1 .. integer 'last;

subtype FLOAT		is $_mach_real;
type character is
   ('\000', '\001', '\002', '\003', '\004', '\005', '\006', '\007',
    '\010', '\011', '\012', '\013', '\014', '\015', '\016', '\017',
    '\020', '\021', '\022', '\023', '\024', '\025', '\026', '\027',
    '\030', '\031', '\032', '\033', '\034', '\035', '\036', '\037',


    ' ', '!', '"', '#', '$', '%', '&', ''', -- let op, moet quote worden
    '(', ')', '*', '+', ',', '-', '.', '/',
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', ':', ';', '<', '=', '>', '?',

    '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
    'X', 'Y', 'Z', '[', '\',']', '^', '_',
    '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
    'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
    'x', 'y', 'z', '{', '|', '}', '~', '');
--  !!! let op, het laatste character is het DELETE character:
--		'\<DEL>'

type string is array (POSITIVE range <>) of character;

package c_functions is
-- dit package bevat de c specificatie van die standard functies
-- die in daslib als c functie zijn geimplementeerd.
--
function $_mods (left, right:	short)	return short;
function $_modi (left, right:	integer)	return integer;
function $_modl (left, right:	long)	return long;

function $_catcc (left, right: character) return string;
function $_catcs (left : character;	right: string	) return string;
function $_catss (left : string;	right: string	) return string;
function $_catsc (left : string;	right : character) return string;
function $_abss  (right:	short)			  return short;
function $_absi  (right:	integer)		  return integer;
function $_absl  (right:	long)			  return long;
function $_absf	 (right:	float)			  return float;
function $_and (Left, right	: $_bool_vector)	return $_bool_vector;
function $_or  (left, right	: $_bool_vector)	return $_bool_vector;
function $_not (left	: $_bool_vector)	return $_bool_vector;
function $_powers (left, right:	short)	return short;
function $_poweri(left, right:	integer) return integer;
function $_powerl(left, right:	long)	return long;
end c_functions;

function "=" (left, right	: $_any_type)	return boolean;

function "<" (left, right	: $_any_scalar)	return boolean;
function "<" (left, right	: $_enum)	return boolean;
function "<" (left, right	: $_any_int)	return boolean;
function "<" (left, right	: float)	return boolean;

function ">" (left, right	: $_any_scalar)	return boolean;
function ">" (left, right	: $_enum)	return boolean;
function ">" (left, right	: $_any_int)	return boolean;
function ">" (left, right	: float)	return boolean;

function "<=" (left, right	: $_any_scalar)	return boolean;
function "<="(left, right	: $_enum)	return boolean;
function "<=" (left, right	: $_any_int)	return boolean;
function "<=" (left, right	: float)	return boolean;

function ">=" (left, right	: $_any_scalar)	return boolean;
function ">="(left, right	: $_enum)	return boolean;
function ">=" (left, right	: $_any_int)	return boolean;
function ">="(left, right	: float)	return boolean;

function "and"(left, right	: $_bool_vector)	 return $_bool_vector
		renames c_functions. $_and;
function "and"(left, right	: boolean)	return boolean;
function "and"(left, right	: $_any_int)	return $_any_int;

function "or"(left, right	: $_bool_vector)	return $_bool_vector
		renames c_functions. $_or;
function "or" (left, right	: boolean)	return boolean;
function "or" (left, right	: $_any_int)	return $_any_int;

function "xor"(left, right	: $_bool_vector)	return $_bool_vector;
function "xor"(left, right	: boolean)	return boolean;
function "xor" (left, right	: $_any_int)	return $_any_int;

function "not" (left      : $_bool_vector)	return $_bool_vector
		renames c_functions. $_not;
function "not" (left       : boolean)		return boolean;
function "not" (left	: $_any_int)		return $_any_int;

function "mod"(left, right	: $_any_int)	return $_any_int;

function "rem"(left, right	: $_any_int)	return $_any_int;

function "+"  (right      : float)		return float;
function "-"  (right      : float)		return float;

function "+"  (left, right	: float)	return float;
function "-"  (left, right	: float)	return float;
function "*"  (left, right	: float)	return float;
function "/"  (left, right	: float)	return float;

function "+"  (right      : $_any_int)		return $_any_int;
function "-"  (right      : $_any_int)		return $_any_int;

function "abs"(right	  : $_any_int)		return $_any_int;
function "abs"(right      : float)		return float renames c_functions.$_absf;

function "+"  (left, right	: $_any_int)	return $_any_int;

function "-"  (left, right	: $_any_int)	return $_any_int;

function "*"  (left, right	: $_any_int)	return $_any_int;

function "/"  (left, right	: $_any_int)	return $_any_int;

function "&" (left : character; right : string) return string;
function "&" (left : string; right : character) return string;
function "&" (left, right : character) return string;

function "&" (left, right : $_any_scalar)	return $_any_scalar;

function "**"	(left, right: $_any_int) return $_any_int;

procedure $deallocate (object: in out $_any_access);

--	package ASCII consists of a number of scalar constant
--	declarations. Note that for such constructs NO code
--	is generated
   package ASCII is

	-- control characters

	NUL:	constant character := character 'val (0);
	SOH:	constant character := character 'val (1);

	STX:	constant character := character 'val (2);
	ETX:	constant character := character 'val (3);
	EOT:	constant character := character 'val (4);
	ENQ:	constant character := character 'val (4);
	ACK:	constant character := character 'val (6);
	BEL:	constant character := character 'val (7);
	BS:	constant character := character 'val (8);
	HT:	constant character := character 'val (9);
	LF:	constant character := character 'val (10);
	VT:	constant character := character 'val (11);
	FF:	constant character := character 'val (12);
	CR:	constant character := character 'val (13);

	DEL:	constant character := character 'val (127);
   end;

