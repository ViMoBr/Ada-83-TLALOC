-- C45113A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED WHEN THE OPERANDS OF LOGICAL
-- OPERATORS HAVE DIFFERENT LENGTHS.

-- RJW  1/15/86

WITH REPORT; USE REPORT; 

PROCEDURE C45113A IS

BEGIN

     TEST( "C45113A" , "CHECK ON LOGICAL OPERATORS WITH " &
                       "OPERANDS OF DIFFERENT LENGTHS" );
     
     DECLARE

          TYPE ARR IS ARRAY ( INTEGER RANGE <> ) OF BOOLEAN;
     
          A : ARR( IDENT_INT(1) .. IDENT_INT(2) ) := ( TRUE, FALSE );
          B : ARR( IDENT_INT(1) .. IDENT_INT(3) ) := ( TRUE, FALSE, 
                                                       TRUE );

     BEGIN

          BEGIN -- TEST FOR 'AND'.
               IF (A AND B) = B THEN
                    FAILED ( "A AND B = B" );
               END IF;
               FAILED ( "NO EXCEPTION RAISED FOR 'AND'" );
          EXCEPTION
               WHEN CONSTRAINT_ERROR => 
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED FOR 'AND'" );
          END;           


          BEGIN -- TEST FOR 'OR'.
               IF (A OR B) = B THEN
                    FAILED ( "A OR B = B" );
               END IF;
               FAILED ( "NO EXCEPTION RAISED FOR 'OR'" );
          EXCEPTION
               WHEN CONSTRAINT_ERROR => 
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED FOR 'OR'" );
          END;           


          BEGIN -- TEST FOR 'XOR'.
               IF (A XOR B) = B THEN
                    FAILED ( "A XOR B = B" );
               END IF;
               FAILED ( "NO EXCEPTION RAISED FOR 'XOR'" );
          EXCEPTION
               WHEN CONSTRAINT_ERROR => 
                    NULL;
               WHEN OTHERS =>
                    FAILED ( "WRONG EXCEPTION RAISED FOR 'XOR'" );
          END;           

     END;

     RESULT;

END C45113A;
