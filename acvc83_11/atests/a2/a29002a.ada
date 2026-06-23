-- A29002A.ADA

-- CHECK THAT KEYWORDS OF OTHER LANGUAGES WHICH ARE NOT KEYWORDS
--    IN ADA CAN BE USED AS VARIABLE NAMES.

-- CHECKS KEYWORDS BEGINNING WITH A - B.

-- DCB 6/6/80
-- JRK 7/3/80
-- SPS 10/21/82
-- SPS 2/11/83

WITH REPORT;
PROCEDURE A29002A IS

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
     
BEGIN
     TEST ("A29002A", "NO ADDITIONAL RESERVED WORDS");
     RESULT;
END A29002A;
