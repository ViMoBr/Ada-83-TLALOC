-- A29002E.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECKS KEYWORDS BEGINNING WITH G - K.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002E IS

     USE REPORT;

     GE             : INTEGER;  -- ALGOL68, TACPOL
     GENERATE       : INTEGER;  -- COBOL
     GET            : INTEGER;  -- PL/I, PLC
     GIVING         : INTEGER;  -- COBOL
     GO             : INTEGER;  -- COBOL, PLC
  -- GOTO           : INTEGER;  -- ALGOL68, ALGOL60, CMS-2, FORTRAN,
                                -- J3B, J73, J73/I, PASCAL, PLC, PL/I,
                                -- TACPOL
     GREATER        : INTEGER;  -- COBOL
     GROUP          : INTEGER;  -- COBOL
     GT             : INTEGER;  -- ALGOL68, CMS-2, TACPOL
     GTEQ           : INTEGER;  -- CMS-2
     HBOUND         : INTEGER;  -- PL/I
     HEADING        : INTEGER;  -- COBOL
     HEAP           : INTEGER;  -- ALGOL68
     HIGH           : INTEGER;  -- PL/I
     HIGH_VALUE     : INTEGER;  -- COBOL
     HIGH_VALUES    : INTEGER;  -- COBOL
     I              : INTEGER;  -- ALGOL68
     I_O            : INTEGER;  -- COBOL
     I_O_CONTROL    : INTEGER;  -- COBOL
     IDENTIFICATION : INTEGER;  -- COBOL
  -- IF             : INTEGER;  -- ALGOL68, ALGOL60, CMS-2, COBOL,
                                -- FORTRAN, J3B, J73, J73/I, PASCAL,
                                -- PL/I, PLC, TACPOL
     IGNORE         : INTEGER;  -- TACPOL
     IM             : INTEGER;  -- ALGOL68
     IMAG           : INTEGER;  -- PL/I
     IMPLEMENTATION : INTEGER;  -- PASCAL
     IMPLICIT       : INTEGER;  -- FORTRAN
  -- IN             : INTEGER;  -- ALGOL68, COBOL, J73/I, PASCAL, PL/I
     INCLUDE        : INTEGER;  -- PL/I
     INDEX          : INTEGER;  -- COBOL, PL/I
     INDEXED        : INTEGER;  -- COBOL
     INDICATE       : INTEGER;  -- COBOL
     INDR_ALLOC     : INTEGER;  -- CMS-2
     INIT           : INTEGER;  -- TACPOL
     INITIAL        : INTEGER;  -- PL/I, COBOL
     INITIATE       : INTEGER;  -- COBOL
     INLINE         : INTEGER;  -- J3B, J73
     INOUT          : INTEGER;  -- SPL/I
     INPUT_OUTPUT   : INTEGER;  -- COBOL, CMS-2, COBOL, PL/I, SPL/I,
                                -- TACPOL
     INQUIRE        : INTEGER;  -- FORTRAN
     INSERT         : INTEGER;  -- SPL/I
     INSPECT        : INTEGER;  -- COBOL
     INSTALLATION   : INTEGER;  -- COBOL
     INSTANCE       : INTEGER;  -- J73
     INT            : INTEGER;  -- ALGOL68, J73/I, SPL/I
  -- INTEGER        : INTEGER;  -- ALGOL60, PASCAL, FORTRAN
     INTERFACE      : INTEGER;  -- PASCAL
     INTERNAL       : INTEGER;  -- PL/I
     INTGR          : INTEGER;  -- J3B
     INTO           : INTEGER;  -- COBOL, PL/I, TACPOL
     INTR           : INTEGER;  -- J3B
     INTRINSIC      : INTEGER;  -- FORTRAN
     INVALID        : INTEGER;  -- CMS-2, COBOL
     IO             : INTEGER;  -- SPL/I
  -- IS             : INTEGER;  -- ALGOL68, COBOL
     ISC            : INTEGER;  -- SPL/I
     ISIZE          : INTEGER;  -- J73/I
     ISNT           : INTEGER;  -- ALGOL68
     ITEM           : INTEGER;  -- J3B, J73, J73/I
     ITERATIVE      : INTEGER;  -- PL/I
     JOVIAL         : INTEGER;  -- J73/I
     JUST           : INTEGER;  -- COBOL
     JUSTIFIED      : INTEGER;  -- COBOL
     KEEP           : INTEGER;  -- TACPOL
     KEY            : INTEGER;  -- COBOL, PL/I, TACPOL
     KEYED          : INTEGER;  -- PL/I
     KEYFROM        : INTEGER;  -- PL/I
     KEYTO          : INTEGER;  -- PL/I
     
BEGIN
     TEST ("A29002E", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002E;
