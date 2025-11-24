with strings; use strings;
--
package ProgLibConsts is
    FULLNAMESIZE :	constant := 100;
    UNAMESIZE :		constant := 20;

    subtype PathName is RecString (FULLNAMESIZE);

    subtype UnitName is RecString (UNAMESIZE);
end;
