-- A29002J.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECKS KEYWORDS THAT BEGIN WITH T - Z.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002J IS

     USE REPORT;

     TABLE          : INTEGER;  -- COBOL, J3B, J73, J73/I
     TABLEPOOL      : INTEGER;  -- CMS-2
     TALLYING       : INTEGER;  -- COBOL
     TAN            : INTEGER;  -- PL/I
     TAND           : INTEGER;  -- PL/I
     TANH           : INTEGER;  -- PL/I
     TAPE           : INTEGER;  -- COBOL
     TERM           : INTEGER;  -- J3B, J73
     TERMIN         : INTEGER;  -- SPL/I
     TERMINAL       : INTEGER;  -- COBOL
  -- TERMINATE      : INTEGER;  -- CMS-2, COBOL
     TEXT           : INTEGER;  -- COBOL
     THAN           : INTEGER;  -- COBOL
  -- THEN           : INTEGER;  -- ALGOL68, ALGOL60, CMS-2, J3B, J73,
                                -- J73/I, PASCAL, PLC, PL/I, TACPOL
     THROUGH        : INTEGER;  -- COBOL
     THRU           : INTEGER;  -- CMS-2, COBOL, SPL/I
     TIME           : INTEGER;  -- COBOL, PL/I
     TIMERHISTORY   : INTEGER;  -- SPL/I
     TIMES          : INTEGER;  -- COBOL, SPL/I
     TIMESAB        : INTEGER;  -- ALGOL68
     TITLE          : INTEGER;  -- PL/I
     TO             : INTEGER;  -- ALGOL68, CMS-2, COBOL, PASCAL, PLC,
                                -- SPL/I, TACPOL
     TOP            : INTEGER;  -- COBOL
     TRACE          : INTEGER;  -- CMS-2
     TRAILING       : INTEGER;  -- COBOL
     TRANSLATE      : INTEGER;  -- PL/I
     TRANSMIT       : INTEGER;  -- PL/I
     TRUE           : INTEGER;  -- ALGOL68, ALGOL60, J3B, J73, SPL/I
     TRUNC          : INTEGER;  -- PL/I, TACPOL
  -- TYPE           : INTEGER;  -- COBOL, J3B, J73, J73/I, PASCAL
     U              : INTEGER;  -- J73, J73/I
     UBOUND         : INTEGER;  -- J3B, J73
     UNALIGNED      : INTEGER;  -- PL/I
     UNDEFINEDFILE  : INTEGER;  -- PL/I
     UNDERFLOW      : INTEGER;  -- PL/I
     UNION          : INTEGER;  -- ALGOL68
     UNIT           : INTEGER;  -- COBOL, PASCAL
     UNSPEC         : INTEGER;  -- PL/I
     UNSTRING       : INTEGER;  -- COBOL
     UNTIL          : INTEGER;  -- ALGOL60, COBOL, PASCAL
     UNWIND         : INTEGER;  -- TACPOL
     UP             : INTEGER;  -- ALGOL68, COBOL
     UPB            : INTEGER;  -- ALGOL68
     UPDATE         : INTEGER;  -- TACPOL, PL/I
     UPON           : INTEGER;  -- COBOL
     USAGE          : INTEGER;  -- COBOL
     USASE          : INTEGER;  -- TACPOL
  -- USE            : INTEGER;  -- COBOL
     USER           : INTEGER;  -- SPL/I
     USER_IO        : INTEGER;  -- PL/I
     USING          : INTEGER;  -- CMS-2, COBOL
     VALID          : INTEGER;  -- CMS-2, PL/I
     VALUE          : INTEGER;  -- ALGOL60, COBOL, SPL/I, TACPOL
     VALUES         : INTEGER;  -- COBOL
     VAR            : INTEGER;  -- PASCAL, SPL/I
     VARIABLE       : INTEGER;  -- PL/I
     VARY           : INTEGER;  -- CMS-2
     VARYING        : INTEGER;  -- CMS-2, PL/I, COBOL
     VERIFY         : INTEGER;  -- PL/I
     VOID           : INTEGER;  -- ALGOL68
     WAIT           : INTEGER;  -- TACPOL
  -- WHEN           : INTEGER;  -- COBOL
  -- WHILE          : INTEGER;  -- ALGOL68, ALGOL60, J3B, J73, J73/I,
                                -- PLC, PL/I, PASCAL, TACPOL
  -- WITH           : INTEGER;  -- COBOL, PASCAL, SPL/I
     WITHIN         : INTEGER;  -- CMS-2
     WORDS          : INTEGER;  -- COBOL
     WORDSIZE       : INTEGER;  -- J73, J73/I
     WORKING_STORAGE : INTEGER;  -- COBOL
     WRITE          : INTEGER;  -- COBOL, FORTRAN, PLC, PL/I, TACPOL
  -- XOR            : INTEGER;  -- J3B, J73, J73/I, SPL/I
     XRAD           : INTEGER;  -- J73/I
     ZAP            : INTEGER;  -- J73/I
     ZDIV           : INTEGER;  -- TACPOL
     ZERO           : INTEGER;  -- CMS-2, COBOL
     ZEROES         : INTEGER;  -- COBOL
     ZEROS          : INTEGER;  -- COBOL
     
BEGIN
     TEST ("A29002J", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002J;
