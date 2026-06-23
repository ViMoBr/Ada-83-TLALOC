-- CB7003A.ADA

-- OBJECTIVE:
--     FOR SUPPRESS PRAGMAS WITH A FIRST ARGUMENT OF ACCESS_CHECK,
--     DISCRIMINANT_CHECK, INDEX_CHECK, LENGTH_CHECK, OR RANGE_CHECK,
--     CHECK THAT THE SECOND ARGUMENT MUST BE AN OBJECT NAME, TYPE
--     NAME OR A SUBTYPE NAME (ELSE THE PRAGMA IS IGNORED).

-- HISTORY:
--     DHH 03/31/88 CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE CB7003A IS

     X : INTEGER;

-----------------------------------------------------------------------
PRAGMA SUPPRESS(RANGE_CHECK, FR);

     PROCEDURE FR IS
          SUBTYPE FR IS INTEGER RANGE 1 .. 10;
          X : FR;
     BEGIN
          X := IDENT_INT(11);
          FAILED("EXCEPTION NOT RAISED ON RANGE_CHECK");
          COMMENT("X HAS THE VALUE " & INTEGER'IMAGE(X));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED ON RANGE_CHECK");
     END FR;
------------------------------------------------------------------------

PRAGMA SUPPRESS(ACCESS_CHECK, PACK);

     PROCEDURE PACK IS
          TYPE HEC IS
               RECORD
                    I : INTEGER;
                    J : CHARACTER;
               END RECORD;
          TYPE PTR IS ACCESS HEC;
          PACK : PTR;
          X : INTEGER;
     BEGIN
          X := IDENT_INT(1) * PACK.I;
          FAILED("EXCEPTION NOT RAISED ON ACCESS_CHECK");
          COMMENT("X HAS THE VALUE " & INTEGER'IMAGE(X));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED ON ACCESS_CHECK");
     END PACK;
-----------------------------------------------------------------------

PRAGMA SUPPRESS(DISCRIMINANT_CHECK, DIS);

     PROCEDURE DIS IS

          SUBTYPE INT IS INTEGER RANGE 1 .. 10;
          TYPE DIS(X : INT) IS
               RECORD
                    I : INT := X;
               END RECORD;

          TYPE PTR IS ACCESS DIS;
          REC : PTR;
     BEGIN
          REC := NEW DIS(11);
          FAILED("EXCEPTION NOT RAISED ON DISCRIMINANT_CHECK");
          COMMENT("REC.X HAS THE VALUE " & INTEGER'IMAGE(REC.X));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED ON " &
                      "DISCRIMINANT_CHECK");
     END DIS;
-----------------------------------------------------------------------

PRAGMA SUPPRESS(INDEX_CHECK, ARY);

     FUNCTION ARY(X : INTEGER) RETURN INTEGER IS
          TYPE ARRY IS ARRAY(1 .. 10) OF INTEGER;
          ARY : ARRY := (1 .. 10 => 4);
          TEMP : INTEGER;
     BEGIN
          TEMP := ARY(X);
          FAILED("EXCEPTION NOT RAISED ON INDEX_CHECK");
          COMMENT("ARY(X) HAS THE VALUE " & INTEGER'IMAGE(ARY(X)));
          RETURN IDENT_INT(TEMP);
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               RETURN 1;
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED ON INDEX_CHECK");
               RETURN 2;
     END ARY;

-----------------------------------------------------------------------

PRAGMA SUPPRESS(LENGTH_CHECK, COMP);

     PROCEDURE COMP IS
          SUBTYPE COMP IS STRING(1 .. 5);
          SUBTYPE CAMP IS STRING(1 .. 6);
          A : COMP;
          B : CAMP := "ABCDEF";
     BEGIN
          A := B;
          FAILED("EXCEPTION NOT RAISED AT LENGTH_CHECK");
          COMMENT("A(IDENT_INT(1)) HAS THE VALUE " &
                   A(IDENT_INT(1)));
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED("UNEXPECTED EXCEPTION RAISED ON LENGTH_CHECK");
      END COMP;

-----------------------------------------------------------------------

BEGIN
     TEST("CB7003A", "FOR SUPPRESS PRAGMAS WITH A FIRST ARGUMENT OF " &
                     "ACCESS_CHECK, DISCRIMINANT_CHECK, " &
                     "INDEX_CHECK, LENGTH_CHECK, OR RANGE_CHECK, " &
                     "CHECK THAT THE SECOND ARGUMENT MUST BE AN " &
                     "OBJECT NAME, TYPE NAME OR A SUBTYPE NAME " &
                     "(ELSE THE PRAGMA IS IGNORED)");
     FR;
     PACK;
     DIS;
     X := ARY(IDENT_INT(11));
     COMP;

     RESULT;
END CB7003A;
