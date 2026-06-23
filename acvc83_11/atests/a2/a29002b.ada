-- A29002B.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECKS KEYWORDS BEGINNING WITH C.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002B IS

     USE REPORT;

     C              : INTEGER;  -- J73, J73/I
     CALL           : INTEGER;  -- COBOL, FORTRAN, PLC, PL/I, TACPOL
     CANCEL         : INTEGER;  -- COBOL
  -- CASE           : INTEGER;  -- ALGOL68, J73, PASCAL
     CAT            : INTEGER;  -- TACPOL
     CAUSE          : INTEGER;  -- SPL/I
     CD             : INTEGER;  -- COBOL
     CEIL           : INTEGER;  -- PL/I
     CELL           : INTEGER;  -- TACPOL
     CF             : INTEGER;  -- COBOL
     CFLOAT         : INTEGER;  -- SPL/I
     CFRAC          : INTEGER;  -- SPL/I
     CH             : INTEGER;  -- COBOL
     CHANNEL        : INTEGER;  -- ALGOL68
     CHANNELHISTORY : INTEGER;  -- SPL/I
     CHAR           : INTEGER;  -- ALGOL68, J73/I, PASCAL, TACPOL
     CHARACTER      : INTEGER;  -- PL/I, COBOL, FORTRAN
     CHARACTERS     : INTEGER;  -- COBOL
     CHECK          : INTEGER;  -- PLC, TACPOL
     CINT           : INTEGER;  -- SPL/I
     CLEAR          : INTEGER;  -- TACPOL
     CLOCK          : INTEGER;  -- SPL/I
     CLOCK_UNITS    : INTEGER;  -- COBOL
     CLOSE          : INTEGER;  -- CMS-2, COBOL, FORTRAN, PLC, PL/I,
                                -- TACPOL
     CO             : INTEGER;  -- ALGOL68
     COBOL          : INTEGER;  -- COBOL
     CODE           : INTEGER;  -- COBOL, TACPOL
     CODE_SET       : INTEGER;  -- COBOL
     COLLATE        : INTEGER;  -- PL/I
     COLLATING      : INTEGER;  -- COBOL
     COLUMN         : INTEGER;  -- PL/I, COBOL
     COMMA          : INTEGER;  -- COBOL
     COMMENT        : INTEGER;  -- ALGOL68
     COMMON         : INTEGER;  -- FORTRAN
     COMMUNICATION  : INTEGER;  -- COBOL
     COMP           : INTEGER;  -- COBOL
     COMPL          : INTEGER;  -- ALGOL68
     COMPLEX        : INTEGER;  -- PL/I, FORTRAN
     COMPOOL        : INTEGER;  -- J3B, J73, J73/I
     COMPUTATIONAL  : INTEGER;  -- COBOL
     COMPUTE        : INTEGER;  -- COBOL
     CONDITION      : INTEGER;  -- PL/I
     CONFIGURATION  : INTEGER;  -- SPL/I, COBOL
     CONJ           : INTEGER;  -- ALGOL68
     CONJG          : INTEGER;  -- PL/I
     CONST          : INTEGER;  -- PASCAL
  -- CONSTANT       : INTEGER;  -- J3B, J73, PL/I
     CONTAINS       : INTEGER;  -- COBOL
     CONTINUE       : INTEGER;  -- FORTRAN
     CONTROL        : INTEGER;  -- COBOL
     CONTROLLED     : INTEGER;  -- PL/I
     CONTROLS       : INTEGER;  -- COBOL
     CONVERSION     : INTEGER;  -- PL/I
     CONVERT        : INTEGER;  -- PL/I
     COPY           : INTEGER;  -- COBOL, J3B, PL/I
     CORR           : INTEGER;  -- COBOL
     CORRESPONDING  : INTEGER;  -- COBOL
     COS            : INTEGER;  -- PL/I, TACPOL
     COSD           : INTEGER;  -- PL/I
     COSH           : INTEGER;  -- PL/I
     COUNT          : INTEGER;  -- COBOL
     CR             : INTEGER;  -- PL/I
     CSWITCH        : INTEGER;  -- CMS-2
     CURRENCY       : INTEGER;  -- COBOL
     
BEGIN
     TEST ("A29002B", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002B;
