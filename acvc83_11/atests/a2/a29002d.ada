-- A29002D.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECK KEYWORDS BEGINNING WITH E - F.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002D IS

     USE REPORT;

     E              : INTEGER;  -- TACPOL
     EGI            : INTEGER;  -- COBOL
     ELEM           : INTEGER;  -- ALGOL68
     ELIF           : INTEGER;  -- ALGOL68
  -- ELSE           : INTEGER;  -- ALGOL68, ALGOL60, COBOL, FORTRAN,
                                -- J3B, J73, J73/I, PASCAL, PLC, PL/I,
                                -- TACPOL
     ELSEIF         : INTEGER;  -- FORTRAN
     EMI            : INTEGER;  -- COBOL
     EMPTY          : INTEGER;  -- ALGOL68, PL/I
     ENABLE         : INTEGER;  -- SPL/I, COBOL
     ENCODE         : INTEGER;  -- CMS-2
  -- END            : INTEGER;  -- ALGOL68, ALGOL60, CMS-2, COBOL,
                                -- FORTRAN, J3B, J73, J73/I, PASCAL,
                                -- PL/I, PLC, TACPOL
     END_CSWITCH    : INTEGER;  -- CMS-2
     END_FUNCTION   : INTEGER;  -- CMS-2
     END_HEAD       : INTEGER;  -- CMS-2
     END_INDR_ALLOC : INTEGER;  -- CMS-2
     END_LOC_DD     : INTEGER;  -- CMS-2
     END_OF_PAGE    : INTEGER;  -- COBOL
     END_P_SW       : INTEGER;  -- CMS-2
     END_PROC       : INTEGER;  -- CMS-2
     END_SWITCH     : INTEGER;  -- CMS-2
     END_SYS_DD     : INTEGER;  -- CMS-2
     END_SYS_PROC   : INTEGER;  -- CMS-2
     END_SYSTEM     : INTEGER;  -- CMS-2
     END_TABLE      : INTEGER;  -- CMS-2
     END_TRACE      : INTEGER;  -- CMS-2
     ENDFILE        : INTEGER;  -- TACPOL, PL/I, FORTRAN
     ENDIF          : INTEGER;  -- FORTRAN
     ENDMODULE      : INTEGER;  -- SPL/I
     ENDPAGE        : INTEGER;  -- PL/I
     ENQUEUE        : INTEGER;  -- TACPOL
     ENTER          : INTEGER;  -- COBOL, J73/I
     ENTIER         : INTEGER;  -- ALGOL68
  -- ENTRY          : INTEGER;  -- FORTRAN, J3B, PLC, PL/I, TACPOL
     ENVIRONMENT    : INTEGER;  -- PL/I, COBOL
     EOP            : INTEGER;  -- COBOL
     EQ             : INTEGER;  -- ALGOL68, CMS-2, TACPOL
     EQUAL          : INTEGER;  -- COBOL
     EQUIVALENCE    : INTEGER;  -- FORTRAN
     EQV            : INTEGER;  -- J73, J73/I
     ERF            : INTEGER;  -- PL/I
     ERFC           : INTEGER;  -- PL/I
     ERHISTORY      : INTEGER;  -- SPL/I
     ERROPS         : INTEGER;  -- SPL/I
     ERROR          : INTEGER;  -- COBOL, PL/I, SPL/I
     ERRORHISTORY   : INTEGER;  -- SPL/I
     ESAC           : INTEGER;  -- ALGOL68
     ESI            : INTEGER;  -- COBOL
     EVERY          : INTEGER;  -- COBOL
  -- EXCEPTION      : INTEGER;  -- COBOL
     EXCLUSIVE      : INTEGER;  -- TACPOL
     EXECUTE        : INTEGER;  -- SPL/I
  -- EXIT           : INTEGER;  -- ALGOL68, CMS-2, COBOL, J73/I, PLC
     EXP            : INTEGER;  -- PL/I, TACPOL
     EXTEND         : INTEGER;  -- COBOL
     EXTERNAL       : INTEGER;  -- CMS-2, SPL/I, PL/I, FORTRAN
     F              : INTEGER;  -- J73, J73/I
     FALLTHRU       : INTEGER;  -- J73
     FALSE          : INTEGER;  -- ALGOL68, ALGOL60, J3B, J73, SPL/I
     FD             : INTEGER;  -- COBOL
     FI             : INTEGER;  -- ALGOL68
     FIELD          : INTEGER;  -- CMS-2
     FILE           : INTEGER;  -- ALGOL68, CMS-2, COBOL, PASCAL, PL/I,
                                -- TACPOL
     FILE_CONTROL   : INTEGER;  -- COBOL
     FILLER         : INTEGER;  -- COBOL
     FINAL          : INTEGER;  -- COBOL
     FIND           : INTEGER;  -- CMS-2
     FINISH         : INTEGER;  -- PL/I
     FIRST          : INTEGER;  -- COBOL, J73
     FIX            : INTEGER;  -- J3B
     FIXED          : INTEGER;  -- PL/I, TACPOL
     FIXEDOVEFLOW   : INTEGER;  -- PL/I
     FLEX           : INTEGER;  -- ALGOL68
     FLOAT          : INTEGER;  -- J73, J73/I, PL/I, SPL/I
     FLOOR          : INTEGER;  -- PL/I
     FLOW           : INTEGER;  -- PLC
     FOFL           : INTEGER;  -- TACPOL
     FOOTING        : INTEGER;  -- COBOL
  -- FOR            : INTEGER;  -- ALGOL68, ALGOL60, COBOL, J3B, J73,
                                -- J73/I, PASCAL
     FORM           : INTEGER;  -- J73/I
     FORMAT         : INTEGER;  -- J73/I, CMS-2, SPL/I, ALGOL68, PLC,
                                -- PL/I, FORTRAN
     FOUND          : INTEGER;  -- CMS-2
     FRAC           : INTEGER;  -- J73/I, SPL/I
     FREE           : INTEGER;  -- PLC, PL/I
     FROM           : INTEGER;  -- ALGOL68, CMS-2, COBOL, PL/I, SPL/I,
                                -- TACPOL
  -- FUNCTION       : INTEGER;  -- CMS-2, PASCAL, FORTRAN
     
BEGIN
     TEST ("A29002D", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002D;
