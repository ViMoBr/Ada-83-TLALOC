-- C35508L.ADA

-- CHECK THAT 'POS' AND 'VAL' YIELD THE CORRECT RESULTS WHEN THE 
-- PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER IS A 
-- BOOLEAN TYPE.

-- RJW 3/24/86

WITH REPORT; USE REPORT;

PROCEDURE C35508L IS

BEGIN
     TEST ("C35508L", "CHECK THAT 'POS' AND 'VAL' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS A " &
                      "FORMAL DISCRETE TYPE WHOSE ACTUAL PARAMETER " &
                      "IS A BOOLEAN TYPE" );

     DECLARE
          TYPE NEWBOOL IS NEW BOOLEAN;

          GENERIC 
               TYPE BOOL IS (<>);
          PROCEDURE P (STR : STRING; B : BOOL; I : INTEGER);

          PROCEDURE P (STR : STRING; B : BOOL; I : INTEGER) IS
               SUBTYPE SBOOL IS BOOL 
               RANGE BOOL'VAL (IDENT_INT(0)) .. BOOL'VAL (IDENT_INT(0));
          BEGIN
               IF BOOL'POS (B) /= I THEN
                    FAILED ( "WRONG " & STR & "'POS FOR " &
                              BOOL'IMAGE (B) & " - 1" );
               END IF;
               IF BOOL'VAL (I) /= B THEN
                    FAILED ( "WRONG " & STR & "'VAL FOR " &
                              INTEGER'IMAGE (I) & " - 1" );
               END IF;

               IF SBOOL'POS (B) /= I THEN
                    FAILED ( "WRONG " & STR & "'POS FOR " &
                              BOOL'IMAGE (B) & " - 2" );
               END IF;

               IF SBOOL'VAL (I) /= B THEN
                    FAILED ( "WRONG " & STR & "'VAL FOR " &
                              INTEGER'IMAGE (I) & " - 2" );
               END IF;
          END P;

          GENERIC 
               TYPE BOOL IS (<>);
          PROCEDURE Q (STR : STRING; B : BOOL; I : INTEGER);

          PROCEDURE Q (STR : STRING; B : BOOL; I : INTEGER) IS
               SUBTYPE SBOOL IS BOOL 
               RANGE BOOL'VAL (IDENT_INT(0)) .. BOOL'VAL (IDENT_INT(0));
          BEGIN
               BEGIN
                    IF BOOL'VAL (I) = B THEN
                         FAILED (STR & "'VAL OF " & INTEGER'IMAGE (I) &
                                       " = " & BOOL'IMAGE (B));
                    END IF;
                    FAILED ( "NO EXCEPTION RAISED FOR " & STR & 
                             "'VAL OF " & INTEGER'IMAGE (I) );
               EXCEPTION     
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED FOR " & STR &
                                  "'VAL " & "OF " &
                                   INTEGER'IMAGE (I) );
               END;
          
               BEGIN
                    IF SBOOL'VAL (I) = B THEN
                         FAILED (STR & " SBOOL'VAL OF " & 
                                 INTEGER'IMAGE(I) & " = " &
                                 BOOL'IMAGE (B) );
                         END IF;
                         FAILED( "NO EXCEPTION RAISED FOR VAL OF " &
                                  INTEGER'IMAGE (I)  &
                                 "WITH SBOOL OF " & STR);
               EXCEPTION
                    WHEN CONSTRAINT_ERROR =>
                         NULL;
                    WHEN OTHERS =>
                         FAILED ( "WRONG EXCEPTION RAISED FOR " & STR &
                                  "'VAL " & "OF " &
                                   INTEGER'IMAGE (I) &
                                  "WITH SBOOL " );  
               END;
          END Q;

          PROCEDURE NP1 IS NEW P ( BOOL => BOOLEAN );
          PROCEDURE NP2 IS NEW P ( BOOL => NEWBOOL );
          PROCEDURE NQ1 IS NEW Q ( BOOL => BOOLEAN );
          PROCEDURE NQ2 IS NEW Q ( BOOL => NEWBOOL );
     BEGIN
          NP1 ( "BOOLEAN", IDENT_BOOL(FALSE) , IDENT_INT(0) );
          NP1 ( "BOOLEAN", IDENT_BOOL(TRUE) , IDENT_INT(1) );
          NP2 ( "NEWBOOL", FALSE , 0 );
          NP2 ( "NEWBOOL", TRUE , 1 );
          NQ1 ( "BOOLEAN", IDENT_BOOL(FALSE) , IDENT_INT(-1) );
          NQ1 ( "BOOLEAN", IDENT_BOOL(TRUE) , IDENT_INT(2) );
          NQ2 ( "NEWBOOL", FALSE , -1 );
          NQ2 ( "NEWBOOL", TRUE , 2 );
     END;

     RESULT;
END C35508L;
