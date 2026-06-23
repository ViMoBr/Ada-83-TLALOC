-- A29002C.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECKS KEYWORDS BEGINNING WITH D.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002C IS

     USE REPORT;

     DATA           : INTEGER;  -- COBOL, FORTRAN
     DATAPOOL       : INTEGER;  -- CMS-2
     DATE           : INTEGER;  -- COBOL, PL/I
     DATE_COMPILED  : INTEGER;  -- COBOL
     DATE_WRITTEN   : INTEGER;  -- COBOL
     DAY            : INTEGER;  -- COBOL
     DB             : INTEGER;  -- PL/I
     DCL            : INTEGER;  -- PLC, PL/I, TACPOL
     DE             : INTEGER;  -- COBOL
     DEADLINE       : INTEGER;  -- SPL/I
     DEBUG          : INTEGER;  -- CMS-2
     DEBUG_CONTENTS : INTEGER;  -- COBOL
     DEBUG_ITEM     : INTEGER;  -- COBOL
     DEBUG_NAME     : INTEGER;  -- COBOL
     DEBUG_SUB_1    : INTEGER;  -- COBOL
     DEBUG_SUB_2    : INTEGER;  -- COBOL
     DEBUG_SUB_3    : INTEGER;  -- COBOL
     DEBUGGING      : INTEGER;  -- COBOL
     DEBUT_LINE     : INTEGER;  -- COBOL
     DECAT          : INTEGER;  -- PL/I
     DECIMAL        : INTEGER;  -- PL/I
     DECIMAL_POINT  : INTEGER;  -- COBOL
     DECLARATIVES   : INTEGER;  -- COBOL
  -- DECLARE        : INTEGER;  -- PLC, PL/I
     DECODE         : INTEGER;  -- CMS-2
     DEF            : INTEGER;  -- J3B, J73, J73/I
     DEFAULT        : INTEGER;  -- J73, J73/I, PL/I
     DEFINE         : INTEGER;  -- J3B, J73, J73/I
     DEFINED        : INTEGER;  -- PL/I
     DELETE         : INTEGER;  -- SPL/I, TACPOL, PL/I, COBOL
     DELETEFILE     : INTEGER;  -- TACPOL
     DELIMITED      : INTEGER;  -- COBOL
     DELIMITER      : INTEGER;  -- COBOL
     DENSE          : INTEGER;  -- CMS-2
     DEP            : INTEGER;  -- CMS-2
     DEPENDING      : INTEGER;  -- COBOL
     DEQUEUE        : INTEGER;  -- TACPOL
     DESCENDING     : INTEGER;  -- COBOL
     DESTINATION    : INTEGER;  -- COBOL
     DETAIL         : INTEGER;  -- COBOL
     DIGIT          : INTEGER;  -- TACPOL
     DIMENSION      : INTEGER;  -- FORTRAN, PL/I
     DINT           : INTEGER;  -- SPL/I
     DIRECT         : INTEGER;  -- J73/I, PL/I
     DISABLE        : INTEGER;  -- COBOL
     DISABLED       : INTEGER;  -- SPL/I
     DISPATCH       : INTEGER;  -- SPL/I
     DISPATCHISTORY : INTEGER;  -- SPL/I
     DISPLAY        : INTEGER;  -- CMS-2, COBOL
     DIV            : INTEGER;  -- PASCAL
     DIVAB          : INTEGER;  -- ALGOL68
     DIVFLT         : INTEGER;  -- CMS-2
     DIVIDE         : INTEGER;  -- PL/I, COBOL
     DIVISION       : INTEGER;  -- COBOL
  -- DO             : INTEGER;  -- ALGOL68, ALGOL60, FORTRAN, PASCAL,
                                -- PL/I, PLC, TACPOL
     DOT            : INTEGER;  -- PL/I
     DOUBLEPRECISION : INTEGER;  -- FORTRAN
     DOWN           : INTEGER;  -- ALGOL68, COBOL
     DOWNTO         : INTEGER;  -- PASCAL
     DSIZE          : INTEGER;  -- J73/I
     DU             : INTEGER;  -- SPL/I
     DUPLICATES     : INTEGER;  -- COBOL
     DYNAMIC        : INTEGER;  -- COBOL
     
BEGIN
     TEST ("A29002C", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002C;
