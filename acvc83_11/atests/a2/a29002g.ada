-- A29002G.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECK KEYWORDS BEGINNING WITH 0 - P.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002G IS

     USE REPORT;

     OBJECT_COMPUTER : INTEGER;  -- COBOL
     OCCURS         : INTEGER;  -- COBOL
     OCM            : INTEGER;  -- CMS-2
     OD             : INTEGER;  -- ALGOL68
     ODD            : INTEGER;  -- ALGOL68
  -- OF             : INTEGER;  -- ALGOL68, COBOL, PASCAL, SPL/I
     OFF            : INTEGER;  -- COBOL
     OFFSET         : INTEGER;  -- PL/I
     OLD            : INTEGER;  -- TACPOL
     OMITTED        : INTEGER;  -- COBOL
     ON             : INTEGER;  -- COBOL, PL/I, PLC, SPL/I, TACPOL
     ONCHAR         : INTEGER;  -- PL/I
     ONCODE         : INTEGER;  -- PL/I
     ONFIELD        : INTEGER;  -- PL/I
     ONFILE         : INTEGER;  -- PL/I
     ONKEY          : INTEGER;  -- PL/I
     ONLOC          : INTEGER;  -- PL/I
     ONSOURCE       : INTEGER;  -- PL/I
     OP             : INTEGER;  -- ALGOL68
     OPEN           : INTEGER;  -- CMS-2, COBOL, FORTRAN, PLC, PL/I,
                                -- TACPOL
     OPTIONAL       : INTEGER;  -- COBOL
     OPTIONS        : INTEGER;  -- CMS-2, PL/I
  -- OR             : INTEGER;  -- ALGOL68, CMS-2, COBOL, J3B, J73,
                                -- J73/I, PASCAL, SPL/I, TACPOL
     ORGANIZATION   : INTEGER;  -- COBOL
     OUSE           : INTEGER;  -- ALGOL68
  -- OUT            : INTEGER;  -- ALGOL68
     OUTPUT         : INTEGER;  -- CMS-2, TACPOL, PL/I, COBOL
     OVER           : INTEGER;  -- ALGOL68
     OVERAB         : INTEGER;  -- ALGOL68
     OVERFLOW       : INTEGER;  -- PL/I, COBOL
     OVERLAY        : INTEGER;  -- J3B, J73, J73/I
     OWN            : INTEGER;  -- ALGOL60
     P              : INTEGER;  -- J73
     P_SWITCH       : INTEGER;  -- CMS-2
     PACKED         : INTEGER;  -- TACPOL, PASCAL
     PAGE           : INTEGER;  -- COBOL, PL/I
     PAGE_COUNTER   : INTEGER;  -- COBOL
     PAGENO         : INTEGER;  -- PL/I
     PAR            : INTEGER;  -- ALGOL68
     PARALLEL       : INTEGER;  -- J73
     PARAMETER      : INTEGER;  -- PL/I, FORTRAN
     PARTTEST       : INTEGER;  -- TACPOL
     PASS           : INTEGER;  -- TACPOL
     PAUSE          : INTEGER;  -- FORTRAN
     PERFORM        : INTEGER;  -- COBOL
     PERIOD         : INTEGER;  -- SPL/I
     PERPROC        : INTEGER;  -- SPL/I
     PF             : INTEGER;  -- COBOL
     PH             : INTEGER;  -- COBOL
     PIC            : INTEGER;  -- COBOL
     PICTURE        : INTEGER;  -- PL/I, COBOL
     PLUS           : INTEGER;  -- COBOL
     PLUSAB         : INTEGER;  -- ALGOL68
     PLUSTO         : INTEGER;  -- ALGOL68
     POINT          : INTEGER;  -- J3B
     POINTER        : INTEGER;  -- SPL/I, PL/I, COBOL
     POS            : INTEGER;  -- J73
     POSITION       : INTEGER;  -- PL/I, COBOL
     POSITIVE       : INTEGER;  -- COBOL
     PR             : INTEGER;  -- ALGOL68
     PRAGMAT        : INTEGER;  -- ALGOL68
     PRECISION      : INTEGER;  -- PL/I
     PRINT          : INTEGER;  -- CMS-2, FORTRAN, PL/I
     PRINTING       : INTEGER;  -- COBOL
     PRINT_ATTACH_TABLE : INTEGER;  -- PL/I
     PRIO           : INTEGER;  -- ALGOL68
     PRIORITY       : INTEGER;  -- SPL/I
     PROC           : INTEGER;  -- ALGOL68, J3B, J73, J73/I, PL/I,
                                -- TACPOL
  -- PROCEDURE      : INTEGER;  -- ALGOL60, PLC, PL/I, COBOL, PASCAL
     PROCEDURES     : INTEGER;  -- COBOL
     PROCEED        : INTEGER;  -- COBOL
     PROCESS        : INTEGER;  -- SPL/I
     PROCPUT        : INTEGER;  -- PLC
     PROD           : INTEGER;  -- PL/I
     PRODUCE        : INTEGER;  -- PL/I
     PROGRAM        : INTEGER;  -- J73, J73/I, COBOL, PASCAL, FORTRAN
     PROGRAM_ID     : INTEGER;  -- COBOL
     PROGRAM_INTERRUPT : INTEGER;  -- PL/I
     PS_SWITCH      : INTEGER;  -- CMS-2
     PTRACE         : INTEGER;  -- CMS-2
     PU             : INTEGER;  -- SPL/I
     PUNCH          : INTEGER;  -- CMS-2
     PUT            : INTEGER;  -- PL/I
     
BEGIN
     TEST ("A29002G", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002G;
