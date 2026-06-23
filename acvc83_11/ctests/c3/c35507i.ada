-- C35507I.ADA

-- OBJECTIVE:
--     CHECK THAT THE ATTRIBUTES 'PRED' AND 'SUCC' YIELD THE CORRECT
--     RESULTS WHEN THE PREFIX IS A CHARACTER TYPE WITH AN ENUMERATION
--     REPRESENTATION CLAUSE.

-- HISTORY:
--     RJW 06/03/86  CREATED ORIGINAL TEST.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH REPORT; USE REPORT;

PROCEDURE  C35507I  IS

     TYPE CHAR IS ('A', B);
     FOR CHAR USE ('A' => 2, B => 5);

     TYPE NEWCHAR IS NEW CHAR;

     FUNCTION IDENT (CH : CHAR) RETURN CHAR IS
     BEGIN
          RETURN CHAR'VAL (IDENT_INT (CHAR'POS (CH)));
     END;

     FUNCTION IDENT (CH : NEWCHAR) RETURN NEWCHAR IS
     BEGIN
          RETURN NEWCHAR'VAL (IDENT_INT (NEWCHAR'POS (CH)));
     END;

BEGIN

     TEST( "C35507I" , "CHECK THAT THE ATTRIBUTES 'PRED' AND " &
                       "'SUCC' YIELD THE CORRECT RESULTS WHEN THE " &
                       "PREFIX IS A CHARACTER TYPE WITH AN " &
                       "ENUMERATION REPRESENTATION CLAUSE" );

     BEGIN
          IF CHAR'SUCC ('A') /= B THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'SUCC('A')" );
          END IF;

          IF CHAR'PRED (IDENT (B)) /= 'A' THEN
               FAILED ( "INCORRECT VALUE FOR CHAR'PRED (IDENT (B))" );
          END IF;
     END;

     BEGIN
          IF CHAR'PRED (IDENT ('A')) = 'A' THEN
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR CHAR'PRED (IDENT ('A')) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR CHAR'PRED (IDENT ('A')) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED " &
                        "FOR CHAR'PRED (IDENT ('A'))" );
     END;

     BEGIN
          IF CHAR'SUCC (IDENT (B)) = B THEN
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR CHAR'SUCC (IDENT (B)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR CHAR'SUCC (IDENT (B)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED " &
                        "FOR CHAR'SUCC (IDENT (B))" );
     END;

     BEGIN
          IF IDENT (NEWCHAR'SUCC ('A')) /= B THEN
               FAILED ( "INCORRECT VALUE FOR " &
                        "IDENT (NEWCHAR'SUCC('A'))" );
          END IF;

          IF NEWCHAR'PRED (B) /= 'A' THEN
               FAILED ( "INCORRECT VALUE FOR NEWCHAR'PRED(B)" );
          END IF;
     END;

     BEGIN
          IF NEWCHAR'PRED (IDENT ('A')) = 'A' THEN
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR NEWCHAR'PRED (IDENT ('A')) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR NEWCHAR'PRED (IDENT ('A')) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED " &
                        "FOR NEWCHAR'PRED (IDENT ('A'))" );
     END;

     BEGIN
          IF NEWCHAR'SUCC (IDENT (B)) IN NEWCHAR THEN
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR NEWCHAR'SUCC (IDENT (B)) - 1" );
          ELSE
               FAILED ( "NO EXCEPTION RAISED " &
                        "FOR NEWCHAR'SUCC (IDENT (B)) - 2" );
          END IF;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED " &
                        "FOR NEWCHAR'SUCC (IDENT (B))" );
     END;

     RESULT;
END C35507I;
