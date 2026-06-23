-- C45344A.ADA

-- CHECK THAT THE CORRECT RESULT IS PRODUCED WHEN A FUNCTION RETURNS 
-- THE RESULT OF A CATENATION WHOSE BOUNDS ARE NOT DEFINED STATICALLY.

-- R.WILLIAMS 9/1/86

WITH REPORT; USE REPORT;
PROCEDURE C45344A IS

BEGIN
     TEST ( "C45344A", "CHECK THAT THE CORRECT RESULT IS PRODUCED " &
                       "WHEN A FUNCTION RETURNS THE RESULT OF A " &
                       "CATENATION WHOSE BOUNDS ARE NOT DEFINED " &
                       "STATICALLY" );

     DECLARE
          SUBTYPE INT IS INTEGER RANGE IDENT_INT (1) .. IDENT_INT (30);

          TYPE ARR IS ARRAY (INT RANGE <>) OF INTEGER;
          SUBTYPE CARR IS ARR (1 .. 9);
          C : CARR;
          
          AR1 : ARR (IDENT_INT (2) .. IDENT_INT (4)) :=
                    (IDENT_INT (2) .. IDENT_INT (4) => 1);

          AR2 : ARR (IDENT_INT (6) .. IDENT_INT (6)) :=
                    (IDENT_INT (6) .. IDENT_INT (6) => 2);

          AR3 : ARR (IDENT_INT (4) .. IDENT_INT (2));
     
          FUNCTION F (A, B : ARR; N : NATURAL) RETURN ARR IS
          BEGIN
               IF N = 0 THEN
                    RETURN A & B;
               ELSE
                    RETURN F (A & B, B, N - 1);
               END IF;
          END F;
     
          FUNCTION G (A : INTEGER; B : ARR; N : NATURAL) RETURN ARR IS
          BEGIN
               IF N = 0 THEN
                    RETURN A & B;
               ELSE
                    RETURN G (A, A & B, N - 1);
               END IF;
          END G;

          FUNCTION H (A : ARR; B : INTEGER; N : NATURAL) RETURN ARR IS
          BEGIN
               IF N = 0 THEN
                    RETURN A & B;
               ELSE
                    RETURN H (A & B, B, N - 1);
               END IF;
          END H;
     
          PROCEDURE CHECK (X, Y : ARR; F, L : INTEGER; STR : STRING) IS
               OK : BOOLEAN := TRUE;
          BEGIN
               IF X'FIRST /= F AND X'LAST /= L THEN
                    FAILED ( "INCORRECT RANGE FOR " & STR);
               ELSE
                    FOR I IN F .. L LOOP
                         IF X (I) /= Y (I) THEN
                              OK := FALSE;
                         END IF;
                    END LOOP;
     
                    IF NOT OK THEN
                         FAILED ( "INCORRECT VALUE FOR " & STR);
                    END IF;
               END IF;
          END CHECK;

     BEGIN
          C := (1 .. 4 => 1, 5 .. 9 => 2);
          CHECK (F (AR1, AR2, IDENT_INT (3)), C, 2, 8, "F - 1" );
          CHECK (F (AR3, AR2, IDENT_INT (3)), C, 6, 9, "F - 2" );
          CHECK (F (AR2, AR3, IDENT_INT (3)), C, 6, 6, "F - 3" );

          C := (1 ..4 => 5, 5 .. 9 => 1);
          CHECK (G (5, AR1, IDENT_INT (3)), C, 1, 7, "G - 1" );
          CHECK (G (5, AR3, IDENT_INT (3)), C, 1, 4, "G - 2" );

          CHECK (H (AR3, 5, IDENT_INT (3)), C, 1, 4, "H - 1" );

          C := (1 ..4 => 1, 5 .. 9 => 5);
          CHECK (H (AR1, 5, IDENT_INT (3)), C, 2, 8, "H - 2" );
     END;

     RESULT;
END C45344A;
