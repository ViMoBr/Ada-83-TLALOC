-- A29002I.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECKS KEYWORDS BEGINNING WITH S.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002I IS

     USE REPORT;

     S              : INTEGER;  -- J73, J73/I, TACPOL
     SA             : INTEGER;  -- CMS-2
     SAME           : INTEGER;  -- COBOL
     SAVE           : INTEGER;  -- FORTRAN
     SAVING         : INTEGER;  -- CMS-2
     SCALE          : INTEGER;  -- J3B, TACPOL
     SCRATCH        : INTEGER;  -- CMS-2
     SD             : INTEGER;  -- COBOL
     SEARCH         : INTEGER;  -- PL/I, COBOL
     SECTION        : INTEGER;  -- COBOL
     SECURITY       : INTEGER;  -- COBOL
     SEGMENT        : INTEGER;  -- COBOL, PASCAL
     SEGMENT_LIMIT  : INTEGER;  -- COBOL
  -- SELECT         : INTEGER;  -- COBOL
     SELEV          : INTEGER;  -- SPL/I
     SEMA           : INTEGER;  -- ALGOL68
     SEND           : INTEGER;  -- COBOL
     SENTENCE       : INTEGER;  -- COBOL
  -- SEPARATE       : INTEGER;  -- COBOL, PASCAL
     SEQUENCE       : INTEGER;  -- COBOL
     SEQUENTIAL     : INTEGER;  -- PL/I, COBOL
     SET            : INTEGER;  -- CMS-2, COBOL, PASCAL, PL/I
     SGN            : INTEGER;  -- J73, J73/I
     SHARE          : INTEGER;  -- TACPOL
     SHIFT          : INTEGER;  -- J73/I
     SHIFTL         : INTEGER;  -- J3B, J73
     SHIFTR         : INTEGER;  -- J3B, J73
     SHL            : INTEGER;  -- ALGOL68
     SHORT          : INTEGER;  -- ALGOL68, TACPOL
     SHORTEN        : INTEGER;  -- ALGOL68
     SHR            : INTEGER;  -- ALGOL68
     SIG            : INTEGER;  -- J73/I
     SIGN           : INTEGER;  -- ALGOL68, COBOL, PL/I, TACPOL
     SIGNAL         : INTEGER;  -- SPL/I, PLC, PL/I
     SIGNED         : INTEGER;  -- J73/I
     SIGVAR         : INTEGER;  -- SPL/I
     SIN            : INTEGER;  -- PL/I, TACPOL
     SIND           : INTEGER;  -- PL/I
     SINH           : INTEGER;  -- PL/I
     SIZE           : INTEGER;  -- COBOL, PL/I, SPL/I
     SKIP           : INTEGER;  -- ALGOL68, PL/I
     SNAP           : INTEGER;  -- CMS-2, PL/I
     SORT           : INTEGER;  -- COBOL
     SORT_MERGE     : INTEGER;  -- COBOL
     SOURCE         : INTEGER;  -- CMS-2, PLC, COBOL
     SOURCE_COMPUTER : INTEGER;  -- COBOL
     SP_SWITCH      : INTEGER;  -- CMS-2
     SPACE          : INTEGER;  -- COBOL, TACPOL
     SPACES         : INTEGER;  -- COBOL
     SPECIAL_NAMES  : INTEGER;  -- COBOL
     SPILL          : INTEGER;  -- CMS-2
     SQR            : INTEGER;  -- TACPOL
     SQRT           : INTEGER;  -- PL/I
     STAC           : INTEGER;  -- PL/I
     STANDARD       : INTEGER;  -- COBOL
     STANDARD_1     : INTEGER;  -- COBOL
     START          : INTEGER;  -- COBOL, J3B, J73, PL/I
     STATIC         : INTEGER;  -- J73, PL/I
     STATISTICAL    : INTEGER;  -- PL/I
     STATUS         : INTEGER;  -- J73, J73/I, SPL/I, COBOL
     STEP           : INTEGER;  -- ALGOL60
     STOP           : INTEGER;  -- COBOL, FORTRAN, J73, J73/I, PLC
     STORAGE        : INTEGER;  -- PL/I
     STREAM         : INTEGER;  -- PL/I
     STRING         : INTEGER;  -- SPL/I, ALGOL68, ALGOL60, PL/I, COBOL,
                                -- PASCAL
     STRINGSIZE     : INTEGER;  -- PL/I
     STRUCT         : INTEGER;  -- ALGOL68
     STRUCTURE      : INTEGER;  -- SPL/I
     SUB_QUEUE_1    : INTEGER;  -- COBOL
     SUB_QUEUE_2    : INTEGER;  -- COBOL
     SUB_QUEUE_3    : INTEGER;  -- COBOL
     SUBROUTINE     : INTEGER;  -- FORTRAN
     SUBSCRIPTRANGE : INTEGER;  -- PL/I
     SUBSR          : INTEGER;  -- TACPOL
     SUBSTR         : INTEGER;  -- PL/I
     SUBTRACT       : INTEGER;  -- PL/I, COBOL
     SUM            : INTEGER;  -- COBOL, PL/I
     SUPPRESS       : INTEGER;  -- COBOL
     SUSPEND        : INTEGER;  -- SPL/I
     SWAP           : INTEGER;  -- CMS-2
     SWITCH         : INTEGER;  -- J3B, J73/I, TACPOL, ALGOL60
     SY             : INTEGER;  -- CMS-2
     SYMBOLIC       : INTEGER;  -- COBOL
     SYNC           : INTEGER;  -- COBOL
     SYNCHRONIZED   : INTEGER;  -- COBOL
     SYSGEN         : INTEGER;  -- SPL/I
     SYSIN          : INTEGER;  -- PL/I
     SYSMON         : INTEGER;  -- SPL/I
     SYSPRINT       : INTEGER;  -- PL/I
     SYSTEM         : INTEGER;  -- PL/I
     
BEGIN
     TEST ("A29002I", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002I;
