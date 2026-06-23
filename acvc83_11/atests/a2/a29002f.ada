-- A29002F.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECKS KEYWORDS BEGINNING WITH L - N.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002F IS

     USE REPORT;

     L              : INTEGER;  -- TACPOL
     LABEL          : INTEGER;  -- ALGOL60, COBOL, J3B, J73, PL/I,
                                -- PASCAL, TACPOL
     LAST           : INTEGER;  -- COBOL, J73
     LBOUND         : INTEGER;  -- J3B, J73, PL/I
     LE             : INTEGER;  -- ALGOL68, TACPOL
     LEADING        : INTEGER;  -- COBOL
     LEFT           : INTEGER;  -- COBOL
     LENG           : INTEGER;  -- ALGOL68
     LENGTH         : INTEGER;  -- PL/I, COBOL
     LESS           : INTEGER;  -- COBOL
     LETTER         : INTEGER;  -- TACPOL
     LEVEL          : INTEGER;  -- ALGOL68
     LIBRARY        : INTEGER;  -- SPL/I
     LIKE           : INTEGER;  -- J73, PL/I
     LIMIT          : INTEGER;  -- COBOL
     LIMITS         : INTEGER;  -- COBOL
     LINAGE         : INTEGER;  -- COBOL
     LINAGE_COUNTER : INTEGER;  -- COBOL
     LINE           : INTEGER;  -- COBOL, J3B, PL/I
     LINE_COUNTER   : INTEGER;  -- COBOL
     LINENO         : INTEGER;  -- PL/I
     LINES          : INTEGER;  -- COBOL
     LINKAGE        : INTEGER;  -- COBOL
     LINKEROFF      : INTEGER;  -- SPL/I
     LIST           : INTEGER;  -- PL/I
     LN             : INTEGER;  -- TACPOL
     LOAD           : INTEGER;  -- TACPOL
     LOC            : INTEGER;  -- ALGOL68, J73, J73/I
     LOCAL          : INTEGER;  -- PL/I
     LOCALIZE       : INTEGER;  -- CMS-2
     LOCATE         : INTEGER;  -- PL/I
     LOCDDPOOL      : INTEGER;  -- CMS-2
     LOCK           : INTEGER;  -- COBOL
     LOCSINWORD     : INTEGER;  -- J73/I
     LOG            : INTEGER;  -- PL/I, TACPOL
     LOG10          : INTEGER;  -- PL/I
     LOG2           : INTEGER;  -- PL/I
     LOGICAL        : INTEGER;  -- FORTRAN
     LONG           : INTEGER;  -- ALGOL68, TACPOL
     LOW            : INTEGER;  -- PL/I
     LOW_VALUE      : INTEGER;  -- COBOL
     LOW_VALUES     : INTEGER;  -- COBOL
     LT             : INTEGER;  -- ALGOL68, CMS-2, TACPOL
     LTEQ           : INTEGER;  -- CMS-2
     LWB            : INTEGER;  -- ALGOL68
     MACHINE        : INTEGER;  -- CMS-2
     MAIN           : INTEGER;  -- SPL/I
     MAPOP          : INTEGER;  -- SPL/I
     MAPSIZE        : INTEGER;  -- SPL/I
     MAX            : INTEGER;  -- PL/I, TACPOL
     MEDIUM         : INTEGER;  -- CMS-2
     MEMORY         : INTEGER;  -- COBOL
     MERGE          : INTEGER;  -- COBOL
     MESSAGE        : INTEGER;  -- COBOL
     MIN            : INTEGER;  -- PL/I, TACPOL
     MINUSAB        : INTEGER;  -- ALGOL68
  -- MOD            : INTEGER;  -- ALGOL68, J73, PASCAL, PL/I
     MODAB          : INTEGER;  -- ALGOL68
     MODE           : INTEGER;  -- ALGOL68, COBOL
     MODULE         : INTEGER;  -- SPL/I
     MODULES        : INTEGER;  -- COBOL
     MOVE           : INTEGER;  -- COBOL, TACPOL
     MULTIPLE       : INTEGER;  -- COBOL
     MULTIPLY       : INTEGER;  -- PL/I, COBOL
     NAME           : INTEGER;  -- J73/I, PL/I
     NATIVE         : INTEGER;  -- COBOL
     NE             : INTEGER;  -- ALGOL68, TACPOL
     NEGATIVE       : INTEGER;  -- COBOL
     NENT           : INTEGER;  -- J3B
     NEXT           : INTEGER;  -- COBOL, J3B, J73
     NIL            : INTEGER;  -- ALGOL68, PASCAL, SPL/I
     NITEMS         : INTEGER;  -- CMS-2
     NO             : INTEGER;  -- COBOL, PLC
     NOALLOC        : INTEGER;  -- SPL/I
     NOCHECK        : INTEGER;  -- PLC
     NOENABLE       : INTEGER;  -- SPL/I
     NOERROPS       : INTEGER;  -- SPL/I
     NOFLOW         : INTEGER;  -- PLC
     NOHISTORY      : INTEGER;  -- SPL/I
     NOIO           : INTEGER;  -- SPL/I
     NOISC          : INTEGER;  -- SPL/I
     NOKEY          : INTEGER;  -- TACPOL
     NOMULTIPROC    : INTEGER;  -- SPL/I
     NONE           : INTEGER;  -- CMS-2
     NONREENTRANT   : INTEGER;  -- SPL/I
     NONVARYING     : INTEGER;  -- PL/I
     NOOPSYS        : INTEGER;  -- SPL/I
     NOPART         : INTEGER;  -- TACPOL
     NOPERPROC      : INTEGER;  -- SPL/I
     NORESVAR       : INTEGER;  -- SPL/I
     NORMAL         : INTEGER;  -- SPL/I
     NOSELEV        : INTEGER;  -- SPL/I
     NOSEM          : INTEGER;  -- SPL/I
     NOSIGVAR       : INTEGER;  -- SPL/I
     NOSOURCE       : INTEGER;  -- PLC
     NOSTATUS       : INTEGER;  -- SPL/I
     NOSUSPEND      : INTEGER;  -- SPL/I
  -- NOT            : INTEGER;  -- ALGOL68, CMS-2, COBOL, J3B, J73,
                                -- J73/I, PASCAL, SPL/I, TACPOL
     NOTERMIN       : INTEGER;  -- SPL/I
     NOTFOUND       : INTEGER;  -- CMS-2
     NOTIMES        : INTEGER;  -- SPL/I
  -- NULL           : INTEGER;  -- J3B, J73, PL/I
     NULLO          : INTEGER;  -- PL/I
     NUMBER         : INTEGER;  -- COBOL
     NUMERIC        : INTEGER;  -- COBOL
     NWDSEN         : INTEGER;  -- J3B, J73
     
BEGIN
     TEST ("A29002F", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002F;
