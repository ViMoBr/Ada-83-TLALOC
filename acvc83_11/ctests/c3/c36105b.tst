-- C36105B.TST

-- OBJECTIVE:
--     IN LOOP PARAMETERS, ENTRY FAMILY DEFINITIONS, OR ARRAY TYPE
--     DEFINITIONS OF THE FORM L .. R, CHECK THAT NUMERIC_ERROR OR
--     CONSTRAINT_ERROR IS RAISED IF L AND R ARE NUMERIC LITERALS OR
--     NAMED NUMBERS, AND AT LEAST ONE OF THEM IS NOT IN THE RANGE OF
--     INTEGER VALUES.

-- MACRO SUBSTITUTION:
--     $INTEGER_LAST_PLUS_1 IS AN INTEGER LITERAL WHOSE VALUE IS
--     INTEGER'LAST + 1.

-- HISTORY:
--     BCB 07/08/88  CREATED ORIGINAL TEST.
--     PWB 05/19/89  ENSURED THAT ALL BOUNDS ARE UNIVERSAL INTEGERS.

WITH SYSTEM;
WITH REPORT; USE REPORT;

PROCEDURE C36105B IS

     INTLAST1 : CONSTANT := $INTEGER_LAST_PLUS_1;
     INT : INTEGER;
     INTLAST_MINUS_1 : CONSTANT := 2*(2**(INTEGER'SIZE - 2) - 1) + 1;

BEGIN
     TEST ("C36105B", "IN LOOP PARAMETERS, ENTRY FAMILY DEFINITIONS, " &
                      "OR ARRAY TYPE DEFINITIONS OF THE FORM L .. R, " &
                      "CHECK THAT NUMERIC_ERROR OR CONSTRAINT_ERROR " &
                      "IS RAISED IF L AND R ARE NUMERIC LITERALS OR " &
                      "NAMED NUMBERS, AND AT LEAST ONE " &
                      "OF THEM IS NOT IN THE RANGE OF INTEGER VALUES");

     BEGIN
          FOR I IN INTLAST_MINUS_1 .. $INTEGER_LAST_PLUS_1 LOOP
               BEGIN
                    FAILED ("NO EXCEPTION RAISED - NUMERIC LITERAL, " &
                            "LOOP PARAMETER");
                    INT := IDENT_INT (I);
                    EXIT;
               END;
          END LOOP;
     EXCEPTION
          WHEN CONSTRAINT_ERROR | NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - NUMERIC LITERAL, " &
                       "LOOP PARAMETER");
     END;

     BEGIN
          FOR J IN INTLAST_MINUS_1 .. INTLAST1 LOOP
               BEGIN
                    FAILED ("NO EXCEPTION RAISED - NAMED NUMBER, " &
                            "LOOP PARAMETER");
                    INT := IDENT_INT (J);
                    EXIT;
               END;
          END LOOP;
     EXCEPTION
          WHEN CONSTRAINT_ERROR | NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - NAMED NUMBER, LOOP " &
                       "PARAMETER");
     END;


     BEGIN
          DECLARE
               TASK T1 IS
                    ENTRY ONE(INTLAST_MINUS_1 .. $INTEGER_LAST_PLUS_1);
               END T1;

               TASK BODY T1 IS
               BEGIN
                    ACCEPT ONE(IDENT_INT(INTEGER'LAST));
                    FAILED ("TASK T1 ACTIVATED");
               END T1;
          BEGIN
               T1.ONE(IDENT_INT(INTEGER'LAST));
          END;
          FAILED ("NO EXCEPTION RAISED - NUMERIC LITERAL, ENTRY " &
                  "FAMILY DEFINITION");
     EXCEPTION
          WHEN CONSTRAINT_ERROR | NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - NUMERIC LITERAL, " &
                       "ENTRY FAMILY DEFINITION");
     END;

     BEGIN
          DECLARE
               TASK T2 IS
                    ENTRY TWO(INTLAST_MINUS_1 .. INTLAST1);
               END T2;

               TASK BODY T2 IS
               BEGIN
                    ACCEPT TWO(IDENT_INT(INTEGER'LAST));
                    FAILED ("TASK T2 ACTIVATED");
               END T2;
          BEGIN
               T2.TWO(IDENT_INT(INTEGER'LAST));
          END;
          FAILED ("NO EXCEPTION RAISED - NAMED NUMBER, ENTRY FAMILY " &
                  "DEFINITION");
     EXCEPTION
          WHEN CONSTRAINT_ERROR | NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - NAMED NUMBER, ENTRY " &
                       "FAMILY DEFINITION");
     END;


     BEGIN
          DECLARE
               TYPE A1 IS ARRAY(INTLAST_MINUS_1 .. $INTEGER_LAST_PLUS_1)
                    OF INTEGER;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - NUMERIC LITERAL, " &
                       "ARRAY TYPE DEFINITION");
               DECLARE
                    A : A1 := (A1'RANGE => 5);
               BEGIN
                    A := (A1'RANGE => IDENT_INT (5));
               END;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR | NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - NUMERIC LITERAL, " &
                       "ARRAY TYPE DEFINTION");
     END;

     BEGIN
          DECLARE
               TYPE A2 IS ARRAY(INTLAST_MINUS_1 .. INTLAST1) OF INTEGER;
          BEGIN
               FAILED ("NO EXCEPTION RAISED - NAMED NUMBER, " &
                       "ARRAY TYPE DEFINITION");
               DECLARE
                    A : A2 := (A2'RANGE => 5);
               BEGIN
                    A := (A2'RANGE => IDENT_INT (5));
               END;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR | NUMERIC_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("OTHER EXCEPTION RAISED - NAMED NUMBER, ARRAY " &
                       "TYPE DEFINITION");
     END;


     RESULT;

END C36105B;
