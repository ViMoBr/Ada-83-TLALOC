-- CC1221B.ADA

-- OBJECTIVE:
--     FOR A FORMAL INTEGER TYPE, CHECK THAT THE FOLLOWING BASIC
--     OPERATIONS ARE IMPLICITLY DECLARED AND ARE THEREFORE AVAILABLE
--     WITHIN THE GENERIC UNIT:  ATTRIBUTES 'FIRST, 'LAST, 'WIDTH,
--     'ADDRESS, AND 'SIZE.

-- HISTORY:
--     BCB 11/12/87  CREATED ORIGINAL TEST FROM SPLIT OF CC1221A.ADA.

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE CC1221B IS

     SUBTYPE SUBINT IS INTEGER RANGE -100 .. 100;
     SUBTYPE NOINT IS INTEGER RANGE 1 .. -1;
     TYPE NEWINT IS NEW INTEGER;
     TYPE INT IS RANGE -300 .. 300;
     SUBTYPE SINT1 IS INT
          RANGE INT (IDENT_INT (-4)) .. INT (IDENT_INT (4));
     SUBTYPE SINT2 IS INT RANGE 16#E#E1 .. 2#1111_1111#;
     TYPE INT2 IS RANGE 0E8 .. 1E3;

BEGIN
     TEST ( "CC1221B", "FOR A FORMAL INTEGER TYPE, CHECK THAT THE " &
                       "FOLLOWING BASIC OPERATIONS ARE IMPLICITLY " &
                       "DECLARED AND ARE THEREFORE AVAILABLE " &
                       "WITHIN THE GENERIC UNIT:  ATTRIBUTES 'FIRST, " &
                       "'LAST, 'WIDTH, 'ADDRESS, AND 'SIZE");

     DECLARE -- (B) CHECKS FOR BASIC OPERATIONS OF A DISCRETE TYPE.
             --     PART II.

          GENERIC
               TYPE T IS RANGE <>;
               F, L : T;
               W : INTEGER;
          PROCEDURE P (STR : STRING);

          PROCEDURE P (STR : STRING) IS
               I : INTEGER := F'SIZE;
               T1 : T;
               A : ADDRESS := T1'ADDRESS;

          BEGIN
               IF T'FIRST /= F THEN
                    FAILED ( "INCORRECT VALUE FOR " & STR & "'FIRST" );
               END IF;

               IF T'LAST /= L THEN
                    FAILED ( "INCORRECT VALUE FOR " & STR & "'LAST" );
               END IF;

               IF T'BASE'FIRST > T'FIRST THEN
                    FAILED ( "INCORRECT RESULTS WITH " & STR &
                             "'BASE'FIRST" );
               END IF;

               IF T'BASE'LAST < T'LAST THEN
                    FAILED ( "INCORRECT RESULTS WITH " & STR &
                             "'BASE'LAST" );
               END IF;

               IF T'WIDTH /= W THEN
                    FAILED ( "INCORRECT VALUE FOR " & STR &
                             "'WIDTH" );
               END IF;

               IF T'BASE'WIDTH < T'WIDTH THEN
                    FAILED ( "INCORRECT RESULTS WITH " & STR &
                             "'BASE'WIDTH" );
               END IF;

          END P;

          GENERIC
               TYPE T IS RANGE <>;
          PROCEDURE Q;

          PROCEDURE Q IS
          BEGIN
               IF T'FIRST /= 1 THEN
                    FAILED ( "INCORRECT VALUE FOR NOINT'FIRST" );
               END IF;

               IF T'LAST /= -1 THEN
                    FAILED ( "INCORRECT VALUE FOR NOINT'LAST" );
               END IF;

               IF T'BASE'FIRST > T'FIRST THEN
                    FAILED ( "INCORRECT RESULTS WITH " &
                             "NOINT'BASE'FIRST" );
               END IF;

               IF T'BASE'LAST < T'LAST THEN
                    FAILED ( "INCORRECT RESULTS WITH " &
                             "NOINT'BASE'LAST" );
               END IF;

               IF T'WIDTH /= 0 THEN
                    FAILED ( "INCORRECT VALUE FOR " &
                             "NOINT'WIDTH" );
               END IF;

               IF T'BASE'WIDTH < T'WIDTH THEN
                    FAILED ( "INCORRECT RESULTS WITH " &
                             "NOINT'BASE'WIDTH" );
               END IF;

          END Q;

          PROCEDURE P1 IS NEW P (INTEGER, INTEGER'FIRST, INTEGER'LAST,
                                 INTEGER'WIDTH);
          PROCEDURE P2 IS NEW P (SUBINT, -100, 100, 4);
          PROCEDURE P3 IS NEW P (NEWINT, NEWINT'FIRST, NEWINT'LAST,
                                 NEWINT'WIDTH);
          PROCEDURE P4 IS NEW P (SINT1, -4, 4, 2);
          PROCEDURE P5 IS NEW P (SINT2, 224, 255, 4);
          PROCEDURE P6 IS NEW P (INT2 , 0, 1000, 5);

          PROCEDURE Q1 IS NEW Q (NOINT);

     BEGIN
           P1 ( "INTEGER" );
           P2 ( "SUBINT" );
           P3 ( "NEWINT" );
           P4 ( "SINT1" );
           P5 ( "SINT2" );
           P6 ( "INT2" );

           Q1;

     END; -- (B).

     RESULT;
END CC1221B;
