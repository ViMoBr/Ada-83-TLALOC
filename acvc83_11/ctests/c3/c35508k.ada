-- C35508K.ADA

-- CHECK THAT 'POS' AND 'VAL' YIELD THE CORRECT RESULTS WHEN THE 
-- PREFIX IS A BOOLEAN TYPE.

-- RJW 3/19/86

WITH REPORT; USE REPORT;

PROCEDURE C35508K IS

     TYPE NEWBOOL IS NEW BOOLEAN;

BEGIN
     TEST ("C35508K", "CHECK THAT 'POS' AND 'VAL' YIELD THE " &
                      "CORRECT RESULTS  WHEN THE PREFIX IS A " &
                      "BOOLEAN TYPE" );

     BEGIN
          IF BOOLEAN'POS (IDENT_BOOL(FALSE)) /= 0 THEN
               FAILED ( "WRONG POS FOR 'FALSE'" );
          END IF;
          IF BOOLEAN'POS (IDENT_BOOL(TRUE)) /= 1 THEN
               FAILED ( "WRONG POS FOR 'TRUE'" );
          END IF;

          IF BOOLEAN'VAL (IDENT_INT(0)) /= FALSE THEN
               FAILED ( "WRONG VAL FOR '0'" );
          END IF;
          IF BOOLEAN'VAL (IDENT_INT(1)) /= TRUE THEN
               FAILED ( "WRONG VAL FOR '1'" );
          END IF;
     END;

     BEGIN
          IF BOOLEAN'VAL (IDENT_INT(-1)) = TRUE THEN
               FAILED("'VAL(-1) WRAPPED AROUND TO TRUE");
          END IF;
          FAILED ( "NO EXCEPTION RAISED FOR VAL OF '-1'" );
     EXCEPTION     
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR VAL OF '-1'" );
     END;

     BEGIN
          IF BOOLEAN'VAL (IDENT_INT(2)) = FALSE THEN
               FAILED("BOOLEAN'VAL(2) WRAPPED AROUND TO FALSE");
          END IF;
          FAILED ( "NO EXCEPTION RAISED FOR VAL OF '2'" );
     EXCEPTION     
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR VAL OF '2'" );
     END;

     BEGIN
          IF NEWBOOL'POS (FALSE) /= 0 THEN
               FAILED ( "WRONG POS FOR NEWBOOL'(FALSE)" );
          END IF;
          IF NEWBOOL'POS (TRUE) /= 1 THEN
               FAILED ( "WRONG POS FOR NEWBOOL'(TRUE)" );
          END IF;

          IF NEWBOOL'VAL (0) /= FALSE THEN
               FAILED ( "WRONG NEWBOOL'VAL FOR '0'" );
          END IF;
          IF NEWBOOL'VAL (1) /= TRUE THEN
               FAILED ( "WRONG NEWBOOL'VAL FOR '1'" );
          END IF;
     END;

     BEGIN
          IF NEWBOOL'VAL (-1) = TRUE THEN
               FAILED("NEWBOOL'VAL(-1) WRAPPED AROUND TO TRUE"); 
          END IF;
          FAILED ( "NO EXCEPTION RAISED FOR NEWBOOL'VAL OF '-1'" );
     EXCEPTION     
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "NEWBOOL'VAL OF '-1'" );
     END;

     BEGIN
          IF NEWBOOL'VAL (2) = FALSE THEN
               FAILED("NEWBOOL'VAL(2) WRAPPED AROUND TO FALSE");
          END IF;
          FAILED ( "NO EXCEPTION RAISED FOR NEWBOOL'VAL OF '2'" );
     EXCEPTION     
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR " &
                        "NEWBOOL'VAL OF '2'" );
     END;

     RESULT;
END C35508K;
