-- C36301A.ADA

-- CHECK THAT PREDEFINED POSITIVE AND STRING TYPES
-- ARE CORRECTLY DEFINED.

-- DAT 2/17/81
-- JBG 12/27/82
-- RJW 1/20/86 - CHANGED 'NATURAL' TO 'POSITIVE'.  ADDED ADDITIONAL 
--               CASES, INCLUDING A CHECK FOR STRINGS WITH BOUNDS
--               OF INTEGER'FIRST AND INTEGER'LAST.  

WITH REPORT; USE REPORT;

PROCEDURE C36301A IS
     
BEGIN
     TEST ( "C36301A", "CHECK ATTRIBUTES OF PREDEFINED POSITIVE " &
                       "AND STRING" );

     BEGIN
          IF POSITIVE'FIRST /= 1 THEN
               FAILED ( "POSITIVE'FIRST IS WRONG" );
          END IF;

          IF POSITIVE'LAST /= INTEGER'LAST THEN
               FAILED ( "POSITIVE'LAST IS WRONG" );
          END IF;
     END;

     DECLARE

          C : STRING (1..2) := ( 'A', 'B' );

     BEGIN
          IF C'LENGTH /= 2  THEN
               FAILED ( "LENGTH OF C IS WRONG" );
          END IF;

          IF C'FIRST /= 1 THEN
               FAILED ( "C'FIRST IS WRONG" );
          END IF;

          IF C'LAST /= 2 THEN
               FAILED ( "C'LAST IS WRONG" );
          END IF;
     END;

     DECLARE

          SUBTYPE LARGE IS STRING ( INTEGER'LAST - 3 .. INTEGER'LAST );

     BEGIN
          IF LARGE'LENGTH /= 4  THEN
               FAILED ( "LENGTH OF LARGE IS WRONG" );
          END IF;

          IF LARGE'FIRST /= INTEGER'LAST - 3  THEN
               FAILED ( "LARGE'FIRST IS WRONG" );
          END IF;

          IF LARGE'LAST /= INTEGER'LAST THEN
               FAILED ( "LARGE'LAST IS WRONG" );
          END IF;
     END;

     DECLARE

          SUBTYPE LARGER IS STRING ( 1 .. INTEGER'LAST );

     BEGIN
          IF LARGER'LENGTH /= INTEGER'LAST THEN
               FAILED ( "LENGTH OF LARGER IS WRONG" );
          END IF;

          IF LARGER'FIRST /= 1 THEN
               FAILED ( "LARGER'FIRST IS WRONG" );
          END IF;

          IF LARGER'LAST /= INTEGER'LAST THEN
               FAILED ( "LARGER'LAST IS WRONG" );
          END IF;
     END;

     BEGIN
          DECLARE

               D : STRING ( INTEGER'FIRST .. INTEGER'FIRST + 3 );

          BEGIN
               FAILED ( "NO EXCEPTION RAISED" );
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED" );
     END;

     BEGIN
          DECLARE

               E : STRING ( -1 .. INTEGER'FIRST );
          
          BEGIN
               IF E'LENGTH /= 0 THEN
                    FAILED ( "LENGTH OF E IS WRONG" );
               END IF;

               IF E'FIRST /= -1 THEN
                    FAILED ( "E'FIRST IS WRONG" );
               END IF;

               IF E'LAST /= INTEGER'FIRST THEN
                    FAILED ( "E'LAST IS WRONG" );
               END IF;
          END;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ( "EXCEPTION RAISED FOR NULL STRING" );
     END;

     RESULT;
END C36301A;
