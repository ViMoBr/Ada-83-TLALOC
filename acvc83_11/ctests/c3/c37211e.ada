-- C37211E.ADA

-- CHECK THAT CONSTRAINT_ERROR IS RAISED BY A DISCRIMINANT CONSTRAINT 
-- IF A VALUE SPECIFIED FOR A DISCRIMINANT DOES NOT LIE IN THE RANGE
-- OF THE DISCRIMINANT. THIS TEST CONTAINS CHECKS FOR SUBTYPE 
-- INDICATIONS WHERE THE TYPE MARK DENOTES AN ACCESS TYPE.

-- R.WILLIAMS 8/28/86

WITH REPORT; USE REPORT;
PROCEDURE C37211E IS

     TYPE REC (D : POSITIVE) IS
          RECORD
               NULL;
          END RECORD;
     
     TYPE ACC IS ACCESS REC;
BEGIN
     TEST ( "C37211E", "CHECK THAT CONSTRAINT_ERROR IS RAISED BY " &
                       "A DISCRIMINANT CONSTRAINT IF A VALUE " &
                       "SPECIFIED FOR A DISCRIMINANT DOES NOT LIE " &
                       "IN THE RANGE OF THE DISCRIMINANT WHERE THE " &
                       "TYPE MARK DENOTES AN ACCESS TYPE" );
                         
     BEGIN
          DECLARE
               SUBTYPE SUBACC IS ACC (IDENT_INT (-1));
          BEGIN
               DECLARE
                    SA : SUBACC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF SUBTYPE SUBACC" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT SA" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "SUBTYPE SUBACC" );
     END;

     BEGIN
          DECLARE
               TYPE ARR IS ARRAY (1 .. 10) OF ACC (IDENT_INT (-1));
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
                         X : ACC (IDENT_INT (-1));
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
               TYPE ACCA IS ACCESS ACC (IDENT_INT (-1));
          BEGIN
               DECLARE
                    ACA : ACCA;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF TYPE ACCA" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT ACA" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "TYPE ACCA" );
     END;
          
     BEGIN
          DECLARE
               TYPE NEWACC IS NEW ACC (IDENT_INT (-1));
          BEGIN
               DECLARE
                    NA : NEWACC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "ELABORATION OF TYPE NEWACC" );
               END;
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED AT DECLARATION OF " &
                             "OBJECT NA" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT ELABORATION OF " &
                        "TYPE NEWACC" );
     END;

     BEGIN
          DECLARE
               A : ACC (IDENT_INT (-1));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED AT THE DECLARATION OF " &
                        "A" );
          EXCEPTION
               WHEN OTHERS => 
                    FAILED ( "EXCEPTION RAISED INSIDE BLOCK " &
                             "CONTAINING A" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED AT DECLARATION OF " &
                        "A" );
     END;

     BEGIN
          DECLARE
               TYPE ACC_NAME IS ACCESS ACC;
          BEGIN
               DECLARE
                    AN : ACC_NAME := NEW ACC (IDENT_INT (-1));
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "DECLARATION OF OBJECT AN" );
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;               
               WHEN OTHERS => 
                    FAILED ( "WRONG EXCEPTION RAISED AT DECLARATION " &
                             "OF OBJECT AN" );
          END;
     EXCEPTION
          WHEN OTHERS => 
               FAILED ( "EXCEPTION RAISED AT ELABORATION OF TYPE " &
                        "ACC_NAME" );
     END;

     BEGIN
          DECLARE
               TYPE BAD_ACC (D : POSITIVE := IDENT_INT (-1)) IS
                    RECORD
                         NULL;
                    END RECORD;
          BEGIN
               DECLARE
                    BAC : BAD_ACC;
               BEGIN
                    FAILED ( "NO EXCEPTION RAISED AT THE " &
                             "DECLARATION OF OBJECT BAC" );
               END;
          EXCEPTION
               WHEN CONSTRAINT_ERROR =>
                    NULL;               
               WHEN OTHERS => 
                    FAILED ( "WRONG EXCEPTION RAISED AT DECLARATION " &
                             "OF OBJECT BAC" );
          END;
     EXCEPTION
          WHEN OTHERS => 
               FAILED ( "EXCEPTION RAISED AT ELABORATION OF TYPE " &
                        "BAD_ACC" );
     END;

     RESULT;
END C37211E;
