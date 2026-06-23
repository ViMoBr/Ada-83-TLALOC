-- C32117A.ADA

-- CHECK WHETHER ALL DEFAULT INITIALIZATION EXPRESSIONS ARE EVALUATED
-- BEFORE ANY VALUE IS CHECKED TO SEE IF IT BELONGS TO A COMPONENT'S
-- SUBTYPE.

-- RJW 8/5/86

WITH REPORT; USE REPORT;

PROCEDURE C32117A IS

     ARR : ARRAY (1 .. 4) OF INTEGER := (0, 0, 0, 0);

     FUNCTION SIDE_EFFECT (X : INTEGER) RETURN INTEGER IS
     BEGIN
          ARR (X) := IDENT_INT (1);
          RETURN IDENT_INT (0);
     END SIDE_EFFECT;
          
BEGIN
     TEST ( "C32117A", "CHECK WHETHER ALL DEFAULT INITIALIZATION " &
                       "EXPRESSIONS ARE EVALUATED BEFORE ANY " &
                       "VALUE IS CHECKED TO SEE IF IT BELONGS " &
                       "TO A COMPONENT'S SUBTYPE" );
     
     BEGIN -- (A).

          DECLARE
               TYPE REC (D : NATURAL := 0) IS
                    RECORD
                         A : INTEGER := SIDE_EFFECT (1);
                         B : STRING (D .. 10);
                         C : INTEGER := SIDE_EFFECT (2);
                    END RECORD;
               
               X : REC;
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR THE DECLARATION " &
                        "OF X - (A), THE LOWER BOUND OF X.B IS " &
                         INTEGER'IMAGE (X.B'FIRST));
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF ARR (1 .. 2) = (1, 1) THEN
                    COMMENT ( "ALL INITIALIZATIONS COMPLETED BEFORE " &
                              "CONSTRAINT_ERROR RAISED IN (A)" );
               ELSE
                    COMMENT ( "CONSTRAINT_ERROR RAISED BEFORE " &
                              "INITIALIZATIONS COMPLETED IN (A)" );
               END IF;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR DECLARATION " &
                        "OF X - (A)" );
     END;

     ARR (1 .. 2) := (0, 0);

     BEGIN -- (B).

          DECLARE

               SUBTYPE SMALL IS INTEGER RANGE -5 .. 5;
               
               TYPE INTARR IS ARRAY (1 .. 2) OF INTEGER;

               TYPE REC IS
                    RECORD
                         A : INTARR := (SIDE_EFFECT (1), 
                                        SIDE_EFFECT (2));
                         B : SMALL  := IDENT_INT(-10);
                         C : INTARR := (SIDE_EFFECT (3),
                                        SIDE_EFFECT (4));
                    END RECORD;
               
               X : REC;
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR THE DECLARATION " &
                        "OF X - (B)" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF ARR (1 .. 4) = (1, 1, 1, 1) THEN
                    COMMENT ( "ALL INITIALIZATIONS COMPLETED BEFORE " &
                              "CONSTRAINT_ERROR RAISED IN (B)" );
               ELSE
                    COMMENT ( "CONSTRAINT_ERROR RAISED BEFORE " &
                              "INITIALIZATIONS COMPLETED IN (B)" );
               END IF;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR DECLARATION " &
                        "OF X - (B)" );
     END;

     ARR (1 .. 4) := (0, 0, 0, 0);

     BEGIN -- (C).

          DECLARE
               TYPE INREC (D : INTEGER) IS
                    RECORD
                         I : INTEGER := SIDE_EFFECT (IDENT_INT (D));
                    END RECORD;
               
               TYPE OUTREC IS
                    RECORD
                         A : INREC (1);
                         B : POSITIVE := IDENT_INT (-1);
                         C : INREC (2);
                    END RECORD;
               
               X : OUTREC;
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR THE DECLARATION " &
                        "OF X - (C)" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF ARR (1 .. 2) = (1, 1) THEN
                    COMMENT ( "ALL INITIALIZATIONS COMPLETED BEFORE " &
                              "CONSTRAINT_ERROR RAISED IN (C)" );
               ELSE
                    COMMENT ( "CONSTRAINT_ERROR RAISED BEFORE " &
                              "INITIALIZATIONS COMPLETED IN (C)" );
               END IF;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR DECLARATION " &
                        "OF X - (C)" );
     END;

     ARR (1 .. 2) := (0, 0);

     BEGIN -- (D).

          DECLARE
               SUBTYPE SMALL IS INTEGER RANGE -5 .. 5;
               
               TYPE SMALLARR IS ARRAY (1 .. 3) OF SMALL;

               X : SMALLARR := (SIDE_EFFECT (1), IDENT_INT (-10),
                                SIDE_EFFECT (2));
          BEGIN
               FAILED ( "NO EXCEPTION RAISED FOR THE DECLARATION " &
                        "OF X - (D)" );
          END;

     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               IF ARR (1 .. 2) = (1, 1) THEN
                    COMMENT ( "ALL INITIALIZATIONS COMPLETED BEFORE " &
                              "CONSTRAINT_ERROR RAISED IN (D)" );
               ELSE
                    COMMENT ( "CONSTRAINT_ERROR RAISED BEFORE " &
                              "INITIALIZATIONS COMPLETED IN (D)" );
               END IF;
          WHEN OTHERS =>
               FAILED ( "WRONG EXCEPTION RAISED FOR DECLARATION " &
                        "OF X - (D)" );
     END;

     RESULT;
END C32117A;
