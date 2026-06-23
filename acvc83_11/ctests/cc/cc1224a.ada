-- CC1224A.ADA

-- FOR ARRAY TYPES WITH A NONLIMITED COMPONENT TYPE (OF A FORMAL AND 
-- NONFORMAL GENERIC TYPE), CHECK THAT THE FOLLOWING OPERATIONS ARE 
-- IMPLICITY DECLARED AND ARE, THEREFORE, AVAILABLE WITHIN THE GENERIC
-- UNIT: ASSIGNMENT, THE OPERATION ASSOCIATED WITH AGGREGATE NOTATION,
-- MEMBERSHIP TESTS, THE OPERATION ASSOCIATED WITH INDEXED COMPONENTS,
-- QUALIFICATION, EXPLICIT CONVERSION, 'BASE, 'SIZE, 'ADDRESS, 'FIRST,
-- 'FIRST (N), 'LAST, 'LAST (N), 'RANGE, 'RANGE (N), 'LENGTH, 
-- 'LENGTH (N).

-- R.WILLIAMS 10/6/86

WITH SYSTEM; USE SYSTEM;
WITH REPORT; USE REPORT;
PROCEDURE CC1224A IS

BEGIN
     TEST ( "CC1224A", "FOR ARRAY TYPES WITH A NONLIMITED COMPONENT " &
                       "TYPE (OF A FORMAL AND NONFORMAL GENERIC " &
                       "TYPE), CHECK THAT THE FOLLOWING OPERATIONS " &
                       "ARE IMPLICITY DECLARED AND ARE, THEREFORE, " &
                       "AVAILABLE WITHIN THE GENERIC -- UNIT: " &
                       "ASSIGNMENT, THE OPERATION ASSOCIATED WITH " &
                       "AGGREGATE NOTATION, MEMBERSHIP TESTS, THE " &
                       "OPERATION ASSOCIATED WITH INDEXED " &
                       "COMPONENTS, QUALIFICATION, EXPLICIT " &
                       "CONVERSION, 'BASE, 'SIZE, 'ADDRESS, 'FIRST, " &
                       "'FIRST (N), 'LAST, 'LAST (N), 'RANGE, " &
                       "'RANGE (N), 'LENGTH, 'LENGTH (N)" );

     DECLARE
          
          TYPE REC IS
               RECORD
                    B : BOOLEAN := TRUE;
               END RECORD;

          R : REC;

          SUBTYPE SUBINT IS 
               INTEGER RANGE IDENT_INT (1) .. IDENT_INT (6);

          TYPE ARRA IS ARRAY (SUBINT) OF SUBINT;
          A1 : ARRA := (IDENT_INT (1) .. IDENT_INT (6) => 1);
          A2 : ARRA := (A1'RANGE => 2);

          TYPE ARRB IS ARRAY (SUBINT RANGE <>) OF REC;
          A3 : ARRB (1 .. 6) := (IDENT_INT (1) .. IDENT_INT (6) => R);
          
          TYPE ARRC IS ARRAY (SUBINT RANGE <>, SUBINT RANGE <>) 
               OF SUBINT;
          A4 : CONSTANT ARRC := (1 .. 6 => (1 .. 6 => 4));

          TYPE ARRD IS ARRAY (SUBINT, SUBINT) OF SUBINT;
          A5 : ARRD := (A4'RANGE (1) => (A4'RANGE (2) => 5));
 
          TYPE ARRE IS ARRAY (SUBINT) OF REC;
          A6 : ARRE := (A1'RANGE => R);

          GENERIC
               TYPE T1 IS (<>);
               TYPE T2 IS PRIVATE;
               X2 : T2;

               TYPE FARR1 IS ARRAY (SUBINT) OF T1;
               FA1 : FARR1;

               TYPE FARR2 IS ARRAY (SUBINT) OF SUBINT;
               FA2 : FARR2;

               TYPE FARR3 IS ARRAY (SUBINT RANGE <>) OF T2;
               FA3 : FARR3;

               TYPE FARR4 IS ARRAY (SUBINT RANGE <>, SUBINT RANGE <>) 
                    OF T1;
               FA4 : FARR4;

               TYPE FARR5 IS ARRAY (SUBINT, SUBINT) OF SUBINT;
               FA5 : FARR5;
               
               TYPE FARR6 IS ARRAY (T1) OF T2;
               FA6 : FARR6;
 
               TYPE FARR7 IS ARRAY (T1) OF T2;
               FA7 : FARR7;
 
          PROCEDURE P;

          PROCEDURE P IS
               
               AD1 : ADDRESS := FA1'ADDRESS;
               AD2 : ADDRESS := FA2'ADDRESS;
               AD3 : ADDRESS := FA3'ADDRESS;
               AD4 : ADDRESS := FA4'ADDRESS;
               AD5 : ADDRESS := FA5'ADDRESS;
               AD6 : ADDRESS := FA6'ADDRESS;

               IN1 : INTEGER := FA1'SIZE;
               IN2 : INTEGER := FA2'SIZE;
               IN3 : INTEGER := FA3'SIZE;
               IN4 : INTEGER := FA4'SIZE;
               IN5 : INTEGER := FA5'SIZE;
               IN6 : INTEGER := FA6'SIZE;

               B1 : FARR1;

               B2 : FARR2;

               SUBTYPE SARR3 IS FARR3 (FA3'RANGE);
               B3 : SARR3;

               SUBTYPE SARR4 IS FARR4 (FA4'RANGE (1), FA4'RANGE (2));
               B4 : SARR4;

               B5 : FARR5;

               B6 : FARR6;
          BEGIN
               B1 := FA1;

               IF B1 /= FARR1 (FA1) THEN
                    FAILED ( "INCORRECT RESULTS - 1" );
               END IF;

               B2 := FA2;

               IF B2 /= FARR2 (A2) THEN
                    FAILED ( "INCORRECT RESULTS - 2" );
               END IF;

               B3 := FA3;

               IF B3 /= FARR3 (FA3) THEN
                    FAILED ( "INCORRECT RESULTS - 3" );
               END IF;

               B4 := FA4;

               IF B4 /= FARR4 (FA4) THEN
                    FAILED ( "INCORRECT RESULTS - 4" );
               END IF;

               B5 := FA5;

               IF B5 /= FARR5 (A5) THEN
                    FAILED ( "INCORRECT RESULTS - 5" );
               END IF;

               B6 := FA6;

               IF B6 /= FARR6 (FA6) THEN
                    FAILED ( "INCORRECT RESULTS - 6" );
               END IF;

               IF FA7 /= FARR7 (FA6) THEN
                    FAILED ( "INCORRECT RESULTS - 7" );
               END IF;

               B1 := FARR1'(FA1'RANGE => T1'VAL (1));
               
               IF B1 (1) /= FA1 (1) THEN
                    FAILED ( "INCORRECT RESULTS - 8" );
               END IF;

               B1 := FARR1'(1 => T1'VAL (1), 2 => T1'VAL (1), 
                            3 .. 6 => T1'VAL (2));
               
               IF B1 (1) /= FA1 (1) THEN
                    FAILED ( "INCORRECT RESULTS - 9" );
               END IF;

               B2 := FARR2'(FA2'RANGE => 2);
               
               IF B2 (2) /= FA2 (2) THEN
                    FAILED ( "INCORRECT RESULTS - 10" );
               END IF;

               B3 := FARR3'(1|2|3 => X2, 4|5|6 => X2);
               
               IF B3 (3) /= FA3 (3) THEN
                    FAILED ( "INCORRECT RESULTS - 11" );
               END IF;

               B4 := 
                FARR4'(FA5'RANGE (1) => (FA5'RANGE (2) => T1'VAL (4)));
               
               IF B4 (4, 4) /= FA4 (4, 4) THEN
                    FAILED ( "INCORRECT RESULTS - 12" );
               END IF;

               B5 := FARR5'(IDENT_INT (1) .. IDENT_INT (6) => 
                            (1 .. 6 => 5));

               IF B5 (5, 5) /= FA5 (5, 5) THEN
                    FAILED ( "INCORRECT RESULTS - 13" );
               END IF;

               B6 := FARR6'(FA6'RANGE => X2);

               IF B6 (T1'FIRST) /= FA6 (T1'FIRST) THEN
                    FAILED ( "INCORRECT RESULTS - 14" );
               END IF;

               IF B1 IN FARR1 THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT RESULTS - 15" );
               END IF;

               IF FA2 NOT IN FARR2 THEN
                    FAILED ( "INCORRECT RESULTS - 16" );
               END IF;

               IF FA3 IN FARR3 THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT RESULTS - 17" );
               END IF;

               IF B4 NOT IN FARR4 THEN
                    FAILED ( "INCORRECT RESULTS - 18" );
               END IF;

               IF B5 IN FARR5 THEN
                    NULL;
               ELSE
                    FAILED ( "INCORRECT RESULTS - 19" );
               END IF;

               IF FA6 NOT IN FARR6 THEN
                    FAILED ( "INCORRECT RESULTS - 20" );
               END IF;
                                             
               IF FARR1'BASE'SIZE < FARR1'SIZE THEN
                    FAILED ( "INCORRECT RESULTS - 21" );
               END IF;

               IF FARR2'BASE'SIZE < FARR2'SIZE THEN
                    FAILED ( "INCORRECT RESULTS - 22" );
               END IF;

               IF FARR3'BASE'SIZE < FARR3'SIZE THEN
                    FAILED ( "INCORRECT RESULTS - 23" );
               END IF;

               IF FARR4'BASE'SIZE < FARR4'SIZE THEN
                    FAILED ( "INCORRECT RESULTS - 24" );
               END IF;

               IF FARR5'BASE'SIZE < FARR5'SIZE THEN
                    FAILED ( "INCORRECT RESULTS - 25" );
               END IF;

               IF FARR6'BASE'SIZE < FARR6'SIZE THEN
                    FAILED ( "INCORRECT RESULTS - 26" );
               END IF;

               IF FA1'LENGTH /= FA1'LAST - FA1'FIRST + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 27" );
               END IF;

               IF FA2'LENGTH /= FA2'LAST - FA2'FIRST + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 28" );
               END IF;

               IF FA3'LENGTH /= FA3'LAST - FA3'FIRST + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 29" );
               END IF;

               IF FA4'LENGTH /= FA4'LAST - FA4'FIRST + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 30" );
               END IF;

               IF FA4'LENGTH (2) /= 
                  FA4'LAST (2) - FA4'FIRST (2) + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 31" );
               END IF;

               IF FA5'LENGTH /= FA5'LAST - FA5'FIRST + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 32" );
               END IF;

               IF FA5'LENGTH (2) /= 
                  FA5'LAST (2) - FA5'FIRST (2) + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 33" );
               END IF;

               IF FA6'LENGTH /= 
                  T1'POS (FA6'LAST) - T1'POS (FA6'FIRST) + 1 THEN
                    FAILED ( "INCORRECT RESULTS - 34" );
               END IF;
          END P;

          PROCEDURE NP IS NEW P (SUBINT, REC, R, ARRA, A1, ARRA, A2,
                                 ARRB, A3, ARRC, A4, ARRD, A5, ARRE,
                                 A6, ARRE, A6);
     BEGIN
          NP;
     END;

     RESULT;
END CC1224A;
