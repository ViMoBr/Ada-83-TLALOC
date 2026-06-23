-- C37211A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED BY A DISCRIMINANT CONSTRAINT 
-- IF A VALUE SPECIFIED FOR A DISCRIMINANT DOES NOT LIE IN THE RANGE
-- OF THE DISCRIMINANT. THIS TEST CONTAINS CHECKS FOR SUBTYPE 
-- INDICATIONS WHERE THE TYPE MARK DENOTES A RECORD TYPE.

-- R.WILLIAMS 8/28/86

WITH REPORT; USE REPORT;
PROCEDURE C37211A IS

     TYPE REC (D : POSITIVE) IS
          RECORD
               NULL;
          END RECORD;
     
BEGIN
     TEST ( "C37211A", "CHECK THAT CONSTRAINT_ERROR IS RAISED BY " &
                       "A DISCRIMINANT CONSTRAINT IF A VALUE " &
                       "SPECIFIED FOR A DISCRIMINANT DOES NOT LIE " &
                       "IN THE RANGE OF THE DISCRIMINANT WHERE THE " &
                       "TYPE MARK DENOTES A RECORD TYPE" );
                         
     BEGIN
          DECLARE
               SUBTYPE SUBREC IS REC (IDENT_INT (-1));
          BEGIN
               DECLARE
                    SR : SUBREC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF SUBTYPE SUBREC" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT SR" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "SUBTYPE SUBREC" );
     END;

     BEGIN
          DECLARE
               TYPE ARR IS ARRAY (1 .. 10) OF REC (IDENT_INT (-1));
          BEGIN
               DECLARE
                    AR : ARR;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF TYPE ARR" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT AR" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "TYPE ARR" );
     END;
          
     BEGIN
          DECLARE
               TYPE REC1 IS 
                    RECORD
                         X : REC (IDENT_INT (-1));
                    END RECORD;

          BEGIN
               DECLARE
                    R1 : REC1;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF TYPE REC1" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT R1" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "TYPE REC1" );
     END;
          
     BEGIN
          DECLARE
               TYPE ACCREC IS ACCESS REC (IDENT_INT (-1));
          BEGIN
               DECLARE
                    ACR : ACCREC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF TYPE ACCREC" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT ACR" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "TYPE ACCREC" );
     END;
          
     BEGIN
          DECLARE
               TYPE NEWREC IS NEW REC (IDENT_INT (-1));
          BEGIN
               DECLARE
                    NR : NEWREC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF TYPE NEWREC" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT NR" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "TYPE NEWREC" );
     END;

     BEGIN
          DECLARE
               R : REC (IDENT_INT (-1));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED AT THE DECLARATION OF " &
                        "R" );
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED INSIDE BLOCK " &
                             "CONTAINING R" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT DECLARATION OF " &
                        "R" );
     END;

     BEGIN
          DECLARE
               TYPE REC_NAME IS ACCESS REC;
          BEGIN
               DECLARE
                    RN : REC_NAME := NEW REC (IDENT_INT (-1));
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "DECLARATION OF OBJECT RN" );
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;               
               WHEN OTHERS => 
                    FAILED ( "WRONG EXCEPTION RAISED AT DECLARATION " &
                             "OF OBJECT RN" );
          END;
     EXCEPTION
          WHEN OTHERS => 
               FAILED ( "EXCEPTION RAISED AT ELABORATION OF TYPE " &
                        "REC_NAME" );
     END;

     BEGIN
          DECLARE
               TYPE BAD_REC (D : POSITIVE := IDENT_INT (-1)) IS
                    RECORD
                         NULL;
                    END RECORD;
          BEGIN
               DECLARE
                    BR : BAD_REC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "DECLARATION OF OBJECT BR" );
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;               
               WHEN OTHERS => 
                    FAILED ( "WRONG EXCEPTION RAISED AT DECLARATION " &
                             "OF OBJECT BR" );
          END;
     EXCEPTION
          WHEN OTHERS => 
               FAILED ( "EXCEPTION RAISED AT ELABORATION OF TYPE " &
                        "BAD_REC" );
     END;

     RESULT;
END C37211A;
