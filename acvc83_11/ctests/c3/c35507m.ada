-- C35507M.ADA

-- OBJECTIVE:
--     CHECK THAT THE ATTRIBUTES 'POS' AND 'VAL' YIELD THE CORRECT
--     RESULTS WHEN THE PREFIX IS A CHARACTER TYPE WITH AN ENUMERATION
--     REPRESENTATION CLAUSE.

-- HISTORY:
--     RJW 06/03/86  CREATED ORIGINAL TEST
--     JLH 07/28/87  MODIFIED FUNCTION IDENT.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH REPORT; USE REPORT;

PROCEDURE C35507M  IS

     TYPE CHAR IS ('A', B);
     FOR CHAR USE ('A' => 4, B => 5);

     TYPE NEWCHAR IS NEW CHAR;

     FUNCTION IDENT (CH : CHAR) RETURN CHAR IS
     BEGIN
          IF EQUAL (3,3) THEN
               RETURN CH;
          ELSE
               RETURN 'A';
          END IF;
     END IDENT;

     FUNCTION IDENT (CH : NEWCHAR) RETURN NEWCHAR IS
     BEGIN
          IF EQUAL (3,3) THEN
               RETURN CH;
          ELSE
               RETURN 'A';
          END IF;
     END IDENT;

BEGIN

     TEST( "C35507M" , "CHECK THAT THE ATTRIBUTES 'POS' AND " &
                       "'VAL' YIELD THE CORRECT RESULTS WHEN THE " &
                       "PREFIX IS A CHARACTER TYPE WITH AN " &
                       "ENUMERATION REPESENTATION CLAUSE" );

     BEGIN
          IF CHAR'POS ('A') /= 0 THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'POS('A')" );
          END IF;

          IF CHAR'POS (B) /= 1 THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'POS(B)" );
          END IF;

          IF CHAR'VAL (0) /= 'A' THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'VAL(0)" );
          END IF;

          IF CHAR'VAL (1) /= B THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'VAL(1)" );
          END IF;
     END;

     BEGIN
          IF NEWCHAR'POS ('A') /= 0 THEN
               FAILED ( "INCORRECT VALUE FOR NEWCHAR'POS('A')" );
          END IF;

          IF NEWCHAR'POS (B) /= 1 THEN
               FAILED ( "INCORRECT VALUE FOR NEWCHAR'POS(B)" );
          END IF;

          IF NEWCHAR'VAL (0) /= 'A' THEN
               FAILED ( "INCORRECT VALUE FOR NEWCHAR'VAL(0)" );
          END IF;

          IF NEWCHAR'VAL (1) /= B THEN
               FAILED ( "INCORRECT VALUE FOR NEWCHAR'VAL(1)" );
          END IF;
     END;

     BEGIN
          IF CHAR'POS (IDENT ('A')) /= 0 THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'POS('A') WITH " &
                        "IDENT" );
          END IF;

          IF NEWCHAR'POS (IDENT (B)) /= 1 THEN
               FAILED ( "INCORRECT VALUE FOR NEWCHAR'POS(B) WITH " &
                        "IDENT" );
          END IF;

          IF IDENT (NEWCHAR'VAL (IDENT_INT(0))) /= 'A' THEN
               FAILED ( "INCORRECT VALUE FOR NEWCHAR'VAL(0) WITH " &
                        "IDENT" );
          END IF;

          IF IDENT (CHAR'VAL (IDENT_INT(1))) /= B THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'VAL(1) WITH IDENT" );
          END IF;
     END;

     BEGIN
          IF CHAR'VAL (IDENT_INT(2)) = B THEN
               FAILED ( "NO EXCEPTION RAISED FOR " &
                        "CHAR'VAL (IDENT_INT(2)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED FOR " &
                        "CHAR'VAL (IDENT_INT(2)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "CHAR'VAL (IDENT_INT(2))" );
     END;

     BEGIN
          IF NEWCHAR'VAL (IDENT_INT (-1)) = 'A' THEN
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR NEWCHAR'VAL (IDENT_INT (-1)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR NEWCHAR'VAL (IDENT_INT (-1)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED " &
                        "FOR NEWCHAR'VAL (IDENT_INT (-1))" );
     END;

     RESULT;
END C35507M;
