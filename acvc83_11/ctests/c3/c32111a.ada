-- C32111A.ADA

-- OBJECTIVE:
-- CHECK THAT WHEN A VARIABLE OR CONSTANT HAVING AN ENUMERATION,
--    INTEGER, FLOAT OR FIXED TYPE IS DECLARED WITH AN INITIAL VALUE,
--    CONSTRAINT_ERROR IS RAISED IF THE INITIAL VALUE LIES OUTSIDE THE
--    RANGE OF THE SUBTYPE.

-- HISTORY:
--    RJW 07/20/86  CREATED ORIGINAL TEST.
--    JET 08/04/87  IMPROVED DEFEAT OF COMPILER OPTIMIZATION.

WITH REPORT; USE REPORT;

PROCEDURE C32111A IS

     TYPE WEEKDAY IS (MON, TUES, WED, THURS, FRI);
     SUBTYPE MIDWEEK IS WEEKDAY RANGE WED .. WED;

     SUBTYPE DIGIT IS CHARACTER RANGE '0' .. '9';

     SUBTYPE SHORT IS INTEGER RANGE -100 .. 100;

     TYPE INT IS RANGE -10 .. 10;
     SUBTYPE PINT IS INT RANGE 1 .. 10;

     TYPE FLT IS DIGITS 3 RANGE -5.0 .. 5.0;
     SUBTYPE SFLT IS FLT RANGE -5.0 .. 0.0;

     TYPE FIXED IS DELTA 0.5 RANGE -5.0 .. 5.0;
     SUBTYPE SFIXED IS FIXED RANGE 0.0 .. 5.0;

BEGIN
     TEST ("C32111A", "CHECK THAT WHEN A VARIABLE OR CONSTANT " &
                      "HAVING AN ENUMERATION, INTEGER, FLOAT OR " &
                      "FIXED TYPE IS DECLARED WITH AN INITIAL " &
                      "VALUE, CONSTRAINT_ERROR IS RAISED IF THE " &
                      "INITIAL VALUE LIES OUTSIDE THE RANGE OF THE " &
                      "SUBTYPE" );

     BEGIN
          DECLARE
               D : MIDWEEK := WEEKDAY'VAL (IDENT_INT (1));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'D'" );
               IF D = TUES THEN
                    COMMENT ("VARIABLE 'D' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'D'" );
     END;

     BEGIN
          DECLARE
               D : CONSTANT WEEKDAY RANGE WED .. WED :=
                   WEEKDAY'VAL (IDENT_INT (3));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'D'" );
               IF D = TUES THEN
                    COMMENT ("INITIALIZE VARIABLE 'D'");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'D'" );
     END;

     BEGIN
          DECLARE
               P : CONSTANT DIGIT := IDENT_CHAR ('/');
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'P'" );
               IF P = '0' THEN
                    COMMENT ("VARIABLE 'P' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'P'" );
     END;

     BEGIN
          DECLARE
               Q : CHARACTER RANGE 'A' .. 'E' := IDENT_CHAR ('F');
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'Q'" );
               IF Q = 'A' THEN
                    COMMENT ("VARIABLE 'Q' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'Q'" );
     END;

     BEGIN
          DECLARE
               I  :  SHORT := IDENT_INT (-101);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'I'" );
               IF I = 1 THEN
                    COMMENT ("VARIABLE 'I' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'I'" );
     END;

     BEGIN
          DECLARE
               J  : CONSTANT INTEGER RANGE 0 .. 100 := IDENT_INT (101);
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'J'" );
               IF J = -1 THEN
                    COMMENT ("VARIABLE 'J' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'J'" );
     END;

     BEGIN
          DECLARE
               K  : INT RANGE 0 .. 1 := INT (IDENT_INT (2));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'K'" );
               IF K = 2 THEN
                    COMMENT ("VARIABLE 'K' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'K'" );
     END;

     BEGIN
          DECLARE
               L  : CONSTANT PINT := INT (IDENT_INT (0));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'L'" );
               IF L = 1 THEN
                    COMMENT ("VARIABLE 'L' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'L'" );
     END;

     BEGIN
          DECLARE
               FL : SFLT := FLT (IDENT_INT (1));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'FL'" );
               IF FL = 3.14 THEN
                    COMMENT ("VARIABLE 'FL' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'FL'" );
     END;

     BEGIN
          DECLARE
               FL1 : CONSTANT FLT RANGE 0.0 .. 0.0 :=
                     FLT (IDENT_INT (-1));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'FL1'" );
               IF FL1 = 0.0 THEN
                    COMMENT ("VARIABLE 'FL1' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'FL1'" );
     END;

     BEGIN
          DECLARE
               FI : FIXED RANGE 0.0 .. 0.0 := IDENT_INT (1) * 0.5;
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'FI'" );
               IF FI = 0.5 THEN
                    COMMENT ("VARIABLE 'FI' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF VARIABLE 'FI'" );
     END;

     BEGIN
          DECLARE
               FI1 : CONSTANT SFIXED := IDENT_INT (-1) * 0.5;
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'FI1'" );
               IF FI1 = 0.5 THEN
                    COMMENT ("VARIABLE 'FI1' INITIALIZED");
               END IF;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                        "OF CONSTANT 'FI1'" );
     END;

     RESULT;
END C32111A;
