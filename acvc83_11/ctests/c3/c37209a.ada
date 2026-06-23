-- C37209A.ADA

-- CHECK THAT CONSTRAINT_ERROR IS NOT RAISED FOR A CONSTANT OBJECT 
-- DECLARATION WHOSE SUBTYPE INDICATION SPECIFIES AN UNCONSTRAINED
-- TYPE WITH DEFAULT DISCRIMINANT VALUES AND WHOSE INITIALIZATION
-- EXPRESSION SPECIFIES A VALUE WHOSE DISCRIMINANTS ARE NOT EQUAL TO
-- THE DEFAULT VALUE.

-- R.WILLIAMS 8/25/86

WITH REPORT; USE REPORT;
PROCEDURE C37209A IS
     
BEGIN
     TEST ( "C37209A", "CHECK THAT CONSTRAINT_ERROR IS NOT RAISED " &
                       "FOR A CONSTANT OBJECT DECLARATION WHOSE " &
                       "SUBTYPE INDICATION SPECIFIES AN " &
                       "UNCONSTRAINED TYPE WITH DEFAULT " &
                       "DISCRIMINANT VALUES AND WHOSE " &
                       "INITIALIZATION EXPRESSION SPECIFIES A VALUE " &
                       "WHOSE DISCRIMINANTS ARE NOT EQUAL TO THE " &
                       "DEFAULT VALUE" );
     DECLARE

          TYPE REC1 (D : INTEGER := IDENT_INT (5)) IS
               RECORD
                    NULL;
               END RECORD;
               
     BEGIN
          DECLARE 
               R1 : CONSTANT REC1 := (D => IDENT_INT (10));     
          BEGIN
               COMMENT ( "NO EXCEPTION RAISED AT DECLARATION OF R1" );
          EXCEPTION
               WHEN OTHERS =>
                    FAILED ( "EXCEPTION FOR R1 RAISED INSIDE BLOCK" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               FAILED ( "CONSTRAINT_ERROR RAISED AT DECLARATION OF " &
                        "R1" );
          WHEN OTHERS =>
               FAILED ( "OTHER EXCEPTION RAISED AT DECLARATION OF " &
                        "R1" );
     END;          
     

     BEGIN
          DECLARE     
               PACKAGE PRIV IS
                    TYPE REC2 (D : INTEGER:= IDENT_INT (5)) IS PRIVATE;
                    R2 : CONSTANT REC2;

               PRIVATE
                    TYPE REC2 (D : INTEGER := IDENT_INT (5)) IS
                         RECORD
                              NULL;
                         END RECORD;

                    R2 : CONSTANT REC2 := (D => IDENT_INT (10));
               END PRIV;
          
               USE PRIV;
               
          BEGIN
               DECLARE 
                    I : INTEGER := R2.D;                    
               BEGIN
                    COMMENT ( "NO EXCEPTION RAISED AT DECLARATION " &
                              "OF R2" );
              END;
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               FAILED ( "CONSTRAINT_ERROR RAISED AT DECLARATION OF " &
                         "R2" );
          WHEN OTHERS =>
               FAILED ( "OTHER EXCEPTION RAISED AT DECLARATION " &
                        "OF R2" );
     END;

     BEGIN
          DECLARE     
               PACKAGE LPRIV IS
                    TYPE REC3 (D : INTEGER:= IDENT_INT (5)) IS 
                         LIMITED PRIVATE;

                    R3 : CONSTANT REC3;

               PRIVATE
                    TYPE REC3 (D : INTEGER := IDENT_INT (5)) IS
                         RECORD
                              NULL;
                         END RECORD;

                    R3 : CONSTANT REC3 := (D => IDENT_INT (10));
               END LPRIV;
          
               USE LPRIV;

          BEGIN
               DECLARE
                    I : INTEGER;
               BEGIN
                    I := R3.D;
                    COMMENT ( "NO EXCEPTION RAISED AT DECLARATION " &
                              "OF R3" );
              END;
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR => 
               FAILED ( "CONSTRAINT_ERROR RAISED AT DECLARATION OF " &
                         "R3" );
          WHEN OTHERS =>
               FAILED ( "OTHER EXCEPTION RAISED AT DECLARATION " &
                        "OF R3" );
     END;

     RESULT;
END C37209A;
