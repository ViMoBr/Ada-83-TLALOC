-- C36303A.ADA

-- CHECK THAT A STRING LITERAL CAN BE WRITTEN WHOSE UPPER BOUND IS
-- SYSTEM.MAX_INT OR INTEGER'LAST.

-- L.BROWN  08/14/86

WITH REPORT; USE REPORT;
WITH SYSTEM; USE SYSTEM;
PROCEDURE  C36303A  IS

     TYPE LG_INT IS RANGE MAX_INT-4 .. MAX_INT;
     TYPE STR IS ARRAY(LG_INT RANGE <>) OF CHARACTER;
     SUBTYPE LG_STR1 IS STR(MAX_INT-4 .. MAX_INT);
     SUBTYPE LG_STR2 IS STRING(INTEGER'LAST-4 .. INTEGER'LAST);
BEGIN
     TEST("C36303A","WRITE STRING LITERALS THAT HAVE UPPER BOUNDS " &
                    "OF SYSTEM.MAX_INT OR INTEGER'LAST");

     BEGIN
          DECLARE
               OBJ1 : LG_STR1 := "TESTS";
          BEGIN
               IF OBJ1 /= "TESTS"  THEN
                    FAILED("STRING LITERAL WITH UPPER BOUND OF " &
                           "SYSTEM.MAX_INT HAS INCORRECT VALUE 1");
               END IF;
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED("CONSTRAINT_ERROR RAISED FOR STRING LITERAL " &
                      "WITH UPPER BOUND OF SYSTEM.MAX_INT 1");
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED FOR STRING LITERAL WITH " &
                      "UPPER BOUND OF SYSTEM.MAX_INT 1");
     END;

     BEGIN
          DECLARE
               OBJ2 : LG_STR2 := "TESTS";
          BEGIN
               IF OBJ2 /= "TESTS"  THEN
                    FAILED("STRING LITERAL WITH UPPER BOUND OF " &
                           "INTEGER'LAST HAS INCORRECT VALUE 1");
               END IF;
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED("CONSTRAINT_ERROR RAISED FOR STRING LITERAL " &
                      "WITH UPPER BOUND OF INTEGER'LAST 1");
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED FOR STRING LITERAL WITH " &
                      "UPPER BOUND OF INTEGER'LAST 1");
     END;

     DECLARE
          OBJ3 : LG_STR1 ;

          FUNCTION FUN RETURN LG_STR1 IS
               BEGIN
                    RETURN "TESTS";
               END FUN;
     BEGIN
          OBJ3 := FUN;
          IF OBJ3 /= "TESTS"  THEN
               FAILED("STRING LITERAL WITH UPPER BOUND OF " &
                      "SYSTEM.MAX_INT HAS INCORRECT VALUE 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED("CONSTRAINT_ERROR RAISED FOR STRING LITERAL " &
                      "WITH UPPER BOUND OF SYSTEM.MAX_INT 2");
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED FOR STRING LITERAL WITH " &
                      "UPPER BOUND OF SYSTEM.MAX_INT 2");
     END;

     DECLARE
          OBJ4 : LG_STR2 ;

          FUNCTION FUN RETURN STRING IS
               BEGIN
                    RETURN "TESTS";
               END FUN;
     BEGIN
          OBJ4 := FUN;
          IF OBJ4 /= "TESTS"  THEN
               FAILED("STRING LITERAL WITH UPPER BOUND OF " &
                      "INTEGER'LAST HAS INCORRECT VALUE 2");
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED("CONSTRAINT_ERROR RAISED FOR STRING LITERAL " &
                      "WITH UPPER BOUND OF INTEGER'LAST 2");
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED FOR STRING LITERAL WITH " &
                      "UPPER BOUND OF INTEGER'LAST 2");
     END;

     DECLARE
          PROCEDURE FUN2 (OBJ5 : IN LG_STR1) IS
               BEGIN
                    IF OBJ5 /= "TESTS"  THEN
                         FAILED("STRING LITERAL WITH UPPER BOUND OF " &
                                "SYSTEM.MAX_INT HAS INCORRECT VALUE 3");
                    END IF;
               END FUN2;
     BEGIN
          FUN2("TESTS");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED("CONSTRAINT_ERROR RAISED FOR STRING LITERAL " &
                      "WITH UPPER BOUND OF SYSTEM.MAX_INT 3");
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED FOR STRING LITERAL WITH " &
                      "UPPER BOUND OF SYSTEM.MAX_INT 3");
     END;

     DECLARE
          PROCEDURE FUN2 (OBJ6 : IN LG_STR2) IS
               BEGIN
                    IF OBJ6 /= "TESTS"  THEN
                         FAILED("STRING LITERAL WITH UPPER BOUND OF " &
                                "INTEGER'LAST HAS INCORRECT VALUE 3");
                    END IF;
               END FUN2;
     BEGIN
          FUN2("TESTS");
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               FAILED("CONSTRAINT_ERROR RAISED FOR STRING LITERAL " &
                      "WITH UPPER BOUND OF INTEGER'LAST 3");
          WHEN OTHERS =>
               FAILED("EXCEPTION RAISED FOR STRING LITERAL WITH " &
                      "UPPER BOUND OF INTEGER'LAST 3");
     END;

RESULT;

END C36303A;
