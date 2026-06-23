-- AD1A01A.ADA

-- OBJECTIVE:
--     CHECK WHETHER AN IMPLEMENTATION GIVES DIFFERENT SIZES TO OBJECTS
--     HAVING THE SAME BASE TYPE.

--     THIS TEST IS FOR INTEGER TYPES.

-- HISTORY:
--     RJW 10/23/86  CREATED ORIGINAL TEST.
--     CJJ 06/04/87  CORRECTED DECLARATION OF INT TYPE TO USE A RANGE
--                   OF -128..127; CHANGED RANGE ON THE SINT3 SUBTYPE
--                   TO BE -8..7 INSTEAD OF A FORMULA; REMOVED
--                   P PROCEDURE WHICH WAS NO LONGER NECESSARY.


WITH REPORT; USE REPORT;
PROCEDURE AD1A01A IS

     I : INTEGER := 0;

     TYPE INT IS RANGE -128 .. 127;
     J : INT := 0;

BEGIN
     TEST ("AD1A01A", "CHECK WHETHER AN IMPLEMENTATION GIVES " &
                      "DIFFERENT SIZES TO OBJECTS HAVING THE SAME " &
                      "BASE TYPE. THIS TEST IS FOR INTEGER TYPES");

     DECLARE  -- TEST SMALL AND LARGE VALUES FOR SUBTYPE OF INTEGER

          SUBTYPE SINTEGER1 IS INTEGER RANGE 0 .. 3;
          I1 : SINTEGER1 := 0;

          SUBTYPE SINTEGER2 IS INTEGER RANGE 0 .. INTEGER'LAST;
          I2 : SINTEGER2 := 0;

     BEGIN
          IF I1'SIZE < I'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                         "I1'SIZE IS LESS THAN I'SIZE" );
          ELSIF I1'SIZE = I'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                         "I1'SIZE IS EQUAL TO I'SIZE" );
          ELSE
               COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                         "I1'SIZE IS GREATER THAN I'SIZE" );
          END IF;

          IF I2'SIZE < I'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                         "I2'SIZE IS LESS THAN I'SIZE" );
          ELSIF I2'SIZE = I'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                         "I2'SIZE IS EQUAL TO I'SIZE" );
          ELSE
               COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                         "I2'SIZE IS GREATER THAN I'SIZE" );
          END IF;

     END;

     DECLARE  -- CHECK SMALL AND LARGE VALUES FOR A SUBTYPE OF INTEGER
              -- PROCEDURE P WAS NECESSARY TO GUARD AGAINST
              -- IMPLEMENTATIONS WHICH DO NOT SUPPORT 'SIZE AND
              -- GIVE IT A VALUE ZERO

          PROCEDURE P IS
               SUBTYPE SINTEGER3 IS
                    INTEGER RANGE -(2 ** (INTEGER'SIZE / 2 - 1)) ..
                                   (2 ** (INTEGER'SIZE / 2 - 1)) - 1;

                    I3 : SINTEGER3 := 0;

          BEGIN
               IF I3'SIZE < I'SIZE THEN
                    COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                              "I3'SIZE IS LESS THAN I'SIZE" );
               ELSIF I3'SIZE = I'SIZE THEN
                    COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                              "I3'SIZE IS EQUAL TO I'SIZE" );
               ELSE
                    COMMENT ( "FOR SUBTYPES OF INTEGER, " &
                              "I3'SIZE IS GREATER THAN I'SIZE" );
               END IF;
          END P;

     BEGIN
          IF INTEGER'SIZE >= 3 THEN
               P;
          ELSE
               COMMENT ( "INTEGER'SIZE IS EQUAL TO " &
                         INTEGER'IMAGE (INTEGER'SIZE));
          END IF;
     END;

     DECLARE  -- TEST SMALL AND LARGE VALUES FOR SUBTYPE
              -- OF DERIVED TYPE INT

          SUBTYPE SINT1 IS INT RANGE 0 .. 3;
          J1 : SINT1 := 0;

          SUBTYPE SINT2 IS INT RANGE 0 .. INT'LAST;
          J2 : SINT2 := 0;

     BEGIN
          IF J1'SIZE < J'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INT, " &
                         "J1'SIZE IS LESS THAN J'SIZE" );
          ELSIF J1'SIZE = J'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INT, " &
                         "J1'SIZE IS EQUAL TO J'SIZE" );
          ELSE
               COMMENT ( "FOR SUBTYPES OF INT, " &
                         "J1'SIZE IS GREATER THAN J'SIZE" );
          END IF;

          IF J2'SIZE < J'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INT, " &
                         "J2'SIZE IS LESS THAN J'SIZE" );
          ELSIF J2'SIZE = J'SIZE THEN
               COMMENT ( "FOR SUBTYPES OF INT, " &
                         "J2'SIZE IS EQUAL TO J'SIZE" );
          ELSE
               COMMENT ( "FOR SUBTYPES OF INT, " &
                         "J2'SIZE IS GREATER THAN J'SIZE" );
          END IF;

     END;

     DECLARE  -- TEST VERY SMALL VALUES FOR SUBTYPE OF DERIVED TYPE INT

          SUBTYPE SINT3 IS
             INT RANGE -8 .. 7;

          J3 : SINT3 := 0;


     BEGIN
          IF J3'SIZE < J'SIZE THEN
                    COMMENT ( "FOR SUBTYPES OF INT, " &
                              "J3'SIZE IS LESS THAN J'SIZE" );
          ELSIF J3'SIZE = J'SIZE THEN
                    COMMENT ( "FOR SUBTYPES OF INT, " &
                              "J3'SIZE IS EQUAL TO J'SIZE" );
          ELSE
                    COMMENT ( "FOR SUBTYPES OF INT, " &
                              "J3'SIZE IS GREATER THAN J'SIZE" );
          END IF;
     END;

     RESULT;

END AD1A01A;
