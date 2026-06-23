-- A29002H.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECK KEYOWRDS THAT BEGIN WITH Q - R.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002H IS

     USE REPORT;

     QTRN           : INTEGER;  -- TACPOL
     QUEUE          : INTEGER;  -- COBOL
     QUIT           : INTEGER;  -- PL/I
     QUOTE          : INTEGER;  -- COBOL
     QUOTES         : INTEGER;  -- COBOL
     RANDOM         : INTEGER;  -- COBOL
  -- RANGE          : INTEGER;  -- CMS-2
     RCT            : INTEGER;  -- SPL/I
     RD             : INTEGER;  -- COBOL
     RE             : INTEGER;  -- ALGOL68
     READ           : INTEGER;  -- CMS-2, COBOL, FORTRAN, PLC, PL/I,
                                -- TACPOL
     REAL           : INTEGER;  -- ALGOL68, ALGOL60, FORTRAN, PASCAL,
                                -- PL/I
     REC            : INTEGER;  -- J73
     RECEIVE        : INTEGER;  -- COBOL
  -- RECORD         : INTEGER;  -- PL/I, COBOL, PASCAL
     RECORDS        : INTEGER;  -- COBOL
     RECURSIVE      : INTEGER;  -- PL/I
     REDEFINES      : INTEGER;  -- COBOL
     REEL           : INTEGER;  -- COBOL
     REF            : INTEGER;  -- ALGOL68, J3B, J73, J73/I
     REFER          : INTEGER;  -- PL/I
     REFERENCES     : INTEGER;  -- COBOL
     REL            : INTEGER;  -- PL/I
     RELATIVE       : INTEGER;  -- COBOL
     RELEASE        : INTEGER;  -- PL/I, COBOL
  -- REM            : INTEGER;  -- TACPOL
     REMAINDER      : INTEGER;  -- COBOL
     REMOVAL        : INTEGER;  -- COBOL
     REMQUO         : INTEGER;  -- J73/I
  -- RENAMES        : INTEGER;  -- COBOL
     RENT           : INTEGER;  -- J3B, J73
     REP            : INTEGER;  -- J73, TACPOL
     REPEAT         : INTEGER;  -- PL/I, PASCAL
     REPLACING      : INTEGER;  -- COBOL
     REPORT         : INTEGER;  -- COBOL
     REPORTING      : INTEGER;  -- COBOL
     REPORTS        : INTEGER;  -- COBOL
     REPR           : INTEGER;  -- ALGOL68
     RERUN          : INTEGER;  -- COBOL
     RESERVE        : INTEGER;  -- J73/I, COBOL
     RESET          : INTEGER;  -- COBOL
     RESOURCE       : INTEGER;  -- SPL/I
     RESUME         : INTEGER;  -- CMS-2
     RESVAR         : INTEGER;  -- SPL/I
  -- RETURN         : INTEGER;  -- J3B, J73, J73/I, TACPOL, PLC, PL/I,
                                -- COBOL, FORTRAN
     RETURNS        : INTEGER;  -- PL/I
  -- REVERSE        : INTEGER;  -- PL/I
     REVERSED       : INTEGER;  -- COBOL
     REVERT         : INTEGER;  -- PLC, PL/I
     REWIND         : INTEGER;  -- TACPOL, COBOL, FORTRAN
     REWRITE        : INTEGER;  -- PL/I, COBOL
     RF             : INTEGER;  -- COBOL
     RH             : INTEGER;  -- COBOL
     RIGHT          : INTEGER;  -- COBOL
     ROUND          : INTEGER;  -- ALGOL68, PL/I, TACPOL
     ROUNDED        : INTEGER;  -- COBOL
     ROUNDROBIN     : INTEGER;  -- SPL/I
     RUN            : INTEGER;  -- COBOL
     
BEGIN
     TEST ("A29002H", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002H;
