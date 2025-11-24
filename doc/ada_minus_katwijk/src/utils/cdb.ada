with ProgLibConsts; use ProgLibConsts;
with strings; use strings;
package cdb is
    CDBNAME	: PathName;

    type CdbRecord is
	record
	    c_viewname  ,
	    c_username  : string (1 .. UNAMESIZE);
	    c_libname   : string (1 .. FULLNAMESIZE);
	end record;
end;

package body cdb is
--
begin
    CDBNAME := ToRecString ("cdb", CDBNAME. MaxLength);
    ToCstring (CDBNAME);
end;
