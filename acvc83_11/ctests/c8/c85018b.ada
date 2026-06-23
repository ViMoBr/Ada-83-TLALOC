-- C85018B.ADA

-- OBJECTIVE:
--     CHECK THAT WHEN AN ENTRY FAMILY MEMBER IS RENAMED THE FORMAL
--     PARAMETER CONSTRAINTS FOR THE NEW NAME ARE IGNORED IN
--     FAVOR OF THE CONSTRAINTS ASSOCIATED WITH THE RENAMED ENTITY.

-- HISTORY:
--     RJW 06/03/86 CREATED ORIGINAL TEST.
--     DHH 10/15/87 CORRECTED RANGE ERRORS.

WITH REPORT; USE REPORT;

PROCEDURE C85018B IS

BEGIN

     TEST( "C85018B", "CHECK THAT WHEN AN ENTRY FAMILY MEMBER IS " &
                      "RENAMED THE FORMAL PARAMETER CONSTRAINTS "  &
                      "FOR THE NEW NAME ARE IGNORED IN FAVOR OF " &
                      "THE CONSTRAINTS ASSOCIATED WITH THE RENAMED " &
                      "ENTITY" );

     DECLARE
          TYPE INT IS RANGE 1 .. 10;
          SUBTYPE INT1 IS INT RANGE 1 .. 5;
          SUBTYPE INT2 IS INT RANGE 6 .. 10;

          OBJ1 : INT1 := 5;
          OBJ2 : INT2 := 6;

          SUBTYPE SHORTCHAR IS CHARACTER RANGE 'A' .. 'C';

          TASK T IS
               ENTRY ENT1 (SHORTCHAR)
                    (A : INT1; OK : BOOLEAN);
          END T;

          PROCEDURE ENT2 (A : INT2; OK : BOOLEAN)
               RENAMES T.ENT1 ('C');

          TASK BODY T IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT ENT1 ('C')
                                     (A : INT1; OK : BOOLEAN) DO
                              IF NOT OK THEN
                                   FAILED ( "WRONG CALL EXECUTED " &
                                            "WITH INTEGER TYPE" );
                              END IF;
                         END;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END T;
     BEGIN
          BEGIN
               ENT2 (OBJ1, TRUE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    FAILED ( "CONSTRAINT_ERROR RAISED WITH " &
                             "INTEGER TYPE" );
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "INTEGER TYPE - 1" );
          END;

          BEGIN
               ENT2 (OBJ2, FALSE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "INTEGER TYPE - 2" );
          END;
     END;

     DECLARE
          TYPE REAL IS DIGITS 3;
          SUBTYPE REAL1 IS REAL RANGE -2.0 .. 0.0;
          SUBTYPE REAL2 IS REAL RANGE  0.0 .. 2.0;

          OBJ1 : REAL1 := -0.25;
          OBJ2 : REAL2 :=  0.25;

          SUBTYPE SHORTINT IS INTEGER RANGE 9 .. 11;

          TASK T IS
               ENTRY ENT1 (SHORTINT)
                    (A : REAL1; OK : BOOLEAN);
          END T;

          PROCEDURE ENT2 (A : REAL2; OK : BOOLEAN)
               RENAMES T.ENT1 (10);

          TASK BODY T IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT ENT1 (10)
                                     (A : REAL1; OK : BOOLEAN) DO
                              IF NOT OK THEN
                                   FAILED ( "WRONG CALL EXECUTED " &
                                            "WITH FLOATING POINT " &
                                            "TYPE" );
                              END IF;
                         END;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END T;
     BEGIN
          BEGIN
               ENT2 (OBJ1, TRUE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    FAILED ( "CONSTRAINT_ERROR RAISED WITH " &
                             "FLOATING POINT " &
                             "TYPE" );
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "FLOATING POINT " &
                             "TYPE - 1" );
          END;

          BEGIN
               ENT2 (OBJ2, FALSE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "FLOATING POINT " &
                             "TYPE - 2" );
          END;
     END;

     DECLARE
          TYPE COLOR IS (RED, YELLOW, BLUE, GREEN);

          TYPE FIXED IS DELTA  0.125 RANGE -1.0 .. 1.0;
          SUBTYPE FIXED1 IS FIXED RANGE  0.0 .. 0.5;
          SUBTYPE FIXED2 IS FIXED RANGE -0.5 .. 0.0;

          OBJ1 : FIXED1 :=  0.125;
          OBJ2 : FIXED2 := -0.125;

          TASK T IS
               ENTRY ENT1 (COLOR)
                    (A : FIXED1; OK : BOOLEAN);
          END T;

          PROCEDURE ENT2 (A : FIXED2; OK : BOOLEAN)
               RENAMES T.ENT1 (BLUE);

          TASK BODY T IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT ENT1 (BLUE)
                                     (A : FIXED1; OK : BOOLEAN) DO
                              IF NOT OK THEN
                                   FAILED ( "WRONG CALL EXECUTED " &
                                            "WITH FIXED POINT " &
                                            "TYPE" );
                              END IF;
                         END;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END T;
     BEGIN
          BEGIN
               ENT2 (OBJ1, TRUE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    FAILED ( "CONSTRAINT_ERROR RAISED WITH " &
                             "FIXED POINT " &
                             "TYPE" );
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "FIXED POINT " &
                             "TYPE - 1" );
          END;

          BEGIN
               ENT2 (OBJ2, FALSE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "FIXED POINT " &
                             "TYPE - 2" );
          END;
     END;

     DECLARE
          TYPE TA IS ARRAY (INTEGER RANGE <>) OF INTEGER;
          SUBTYPE STA1 IS TA(1 .. 5);
          SUBTYPE STA2 IS TA(6 .. 10);

          OBJ1 : STA1 := (1, 2, 3, 4, 5);
          OBJ2 : STA2 := (6, 7, 8, 9, 10);

          TASK T IS
               ENTRY ENT1 (BOOLEAN)
                    (A : STA1; OK : BOOLEAN);
          END T;

          PROCEDURE ENT2 (A : STA2; OK : BOOLEAN)
               RENAMES T.ENT1 (FALSE);

          TASK BODY T IS
          BEGIN
               LOOP
                    SELECT
                         ACCEPT ENT1 (FALSE)
                                     (A : STA1; OK : BOOLEAN) DO
                              IF NOT OK THEN
                                   FAILED ( "WRONG CALL EXECUTED " &
                                            "WITH CONSTRAINED " &
                                            "ARRAY" );
                              END IF;
                         END;
                    OR
                         TERMINATE;
                    END SELECT;
               END LOOP;
          END T;
     BEGIN
          BEGIN
               ENT2 (OBJ1, TRUE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR  =>
                    FAILED ( "CONSTRAINT_ERROR RAISED WITH " &
                             "CONSTRAINED ARRAY" );
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "CONSTRAINED ARRAY - 1" );
          END;

          BEGIN
               ENT2 (OBJ2, FALSE);
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "OTHER EXCEPTION RAISED WITH " &
                             "CONSTRAINED ARRAY - 2" );
          END;
     END;

     RESULT;

END C85018B;
