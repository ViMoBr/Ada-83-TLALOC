-- D29002K.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82

WITH REPORT;
PROCEDURE D29002K IS

     USE REPORT;

  -- ABORT          : INTEGER;  -- J73
  -- ABS            : INTEGER;  -- ALGOL68, J3B, J73, J73/I, PL/I,
                                -- TACPOL
  -- ACCEPT         : INTEGER;  -- COBOL
  -- ACCESS         : INTEGER;  -- COBOL
     ACOS           : INTEGER;  -- TACPOL
     ACTIVATE       : INTEGER;  -- SPL/I
     ADD            : INTEGER;  -- COBOL, PL/I
     ADDR           : INTEGER;  -- PL/I
     ADDREL         : INTEGER;  -- PL/I
     ADDRESSSIZE    : INTEGER;  -- J73/I
     ADVANCING      : INTEGER;  -- COBOL
     AFTER          : INTEGER;  -- COBOL, PL/I
     ALIGNED        : INTEGER;  -- TACPOL, PL/I
  -- ALL            : INTEGER;  -- COBOL, J73/I
     ALLOC          : INTEGER;  -- SPL/I
     ALLOCATE       : INTEGER;  -- PLC, PL/I
     ALLOCATION     : INTEGER;  -- PL/I
     ALPHABETIC     : INTEGER;  -- COBOL
     ALSO           : INTEGER;  -- COBOL
     ALTER          : INTEGER;  -- COBOL
     ALTERNATE      : INTEGER;  -- COBOL
  -- AND            : INTEGER;  -- ALGOL68, CMS-2, COBOL, J3B, J73,
                                -- J73/I, PASCAL, SPL/I, TACPOL
     ARE            : INTEGER;  -- COBOL
     AREA           : INTEGER;  -- COBOL, PL/I
     AREAS          : INTEGER;  -- COBOL
     ARG            : INTEGER;  -- ALGOL68
  -- ARRAY          : INTEGER;  -- ALGOL60, J3B, PASCAL, SPL/I
     ASCENDING      : INTEGER;  -- COBOL
     ASI            : INTEGER;  -- SPL/I
     ASIN           : INTEGER;  -- TACPOL
     ASSIGN         : INTEGER;  -- COBOL, FORTRAN
  -- AT             : INTEGER;  -- ALGOL68, COBOL
     ATAN           : INTEGER;  -- PL/I, TACPOL
     ATAND          : INTEGER;  -- PL/I
     ATANH          : INTEGER;  -- PL/I
     ATTRIBUTES     : INTEGER;  -- SPL/I
     AU             : INTEGER;  -- SPL/I
     AUTHOR         : INTEGER;  -- COBOL
     AUTOMATIC      : INTEGER;  -- PL/I
     AVAIL          : INTEGER;  -- TACPOL
     B              : INTEGER;  -- J73, J73/I, TACPOL
     BACK           : INTEGER;  -- TACPOL
     BACKSPACE      : INTEGER;  -- FORTRAN
     BASE           : INTEGER;  -- CMS-2
     BASED          : INTEGER;  -- PL/I
     BASENO         : INTEGER;  -- PL/I
     BASEPTR        : INTEGER;  -- PL/I
     BEFORE         : INTEGER;  -- PL/I, COBOL
  -- BEGIN          : INTEGER;  -- ALGOL68, ALGOL60, J3B, J73, J73/I,
                                -- PLC, PL/I, PASCAL, TACPOL
     BIN            : INTEGER;  -- ALGOL68, TACPOL
     BINARY         : INTEGER;  -- PL/I
     BIND           : INTEGER;  -- PL/I
     BIT            : INTEGER;  -- J3B, J73, J73/I, PL/I, SPL/I, TACPOL
     BITOF          : INTEGER;  -- J73/I
     BITS           : INTEGER;  -- ALGOL68
     BITSINBYTE     : INTEGER;  -- J73/I
     BITSINWORD     : INTEGER;  -- J73/I
     BITSIZE        : INTEGER;  -- J73, J73/I
     BLANK          : INTEGER;  -- COBOL
     BLOCK          : INTEGER;  -- COBOL, J3B, J73, J73/I
     BLOCKDATA      : INTEGER;  -- FORTRAN
     BOOL           : INTEGER;  -- ALGOL68, PL/I, SPL/I, TACPOL
     BOOLEAN        : INTEGER;  -- ALGOL60, PASCAL
     BOTTOM         : INTEGER;  -- COBOL
     BY             : INTEGER;  -- ALGOL68, CMS-2, COBOL, J3B, J73,
                                -- J73/I, PLC, TACPOL
     BYTE           : INTEGER;  -- J3B, J73, J73/I
     BYTES          : INTEGER;  -- ALGOL68
     BYTESINWORD    : INTEGER;  -- J73/I
     BYTESIZE       : INTEGER;  -- J73, J73/I
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
     TEST ("D29002K", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END D29002K;
