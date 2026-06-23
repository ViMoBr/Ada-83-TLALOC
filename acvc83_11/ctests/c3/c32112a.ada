-- C32112A.ADA

-- CHECK THAT WHEN A VARIABLE OR CONSTANT HAVING A NON-NULL ARRAY
-- SUBTYPE IS DECLARED WITH AN INITIAL VALUE, CONSTRAINT_ERROR IS
-- RAISED IF THE CORRESPONDING DIMENSIONS OF THE INITIAL VALUE AND THE
-- SUBTYPE DO NOT HAVE THE SAME LENGTH.

-- RJW 7/20/86
-- GMT 7/01/87  ADDED CODE TO PREVENT DEAD VARIABLE OPTIMIZATION.

WITH REPORT; USE REPORT;

PROCEDURE C32112A IS

     TYPE ARR1 IS ARRAY (NATURAL RANGE <>) OF INTEGER;
     SUBTYPE SARR1 IS ARR1 (IDENT_INT (1) .. IDENT_INT (2));

     TYPE ARR2 IS ARRAY (NATURAL RANGE <>, NATURAL RANGE <>)
          OF INTEGER;
     SUBTYPE SARR2 IS ARR2 (IDENT_INT (1) .. IDENT_INT (2),
                            IDENT_INT (0) .. IDENT_INT (0));

BEGIN
     TEST ("C32112A", "CHECK THAT WHEN A VARIABLE OR CONSTANT " &
                      "HAVING A NON-NULL ARRAY SUBTYPE IS DECLARED " &
                      "WITH AN INITIAL VALUE, CONSTRAINT_ERROR IS " &
                      "RAISED IF THE CORRESPONDING DIMENSIONS OF " &
                      "THE INITIAL VALUE AND THE SUBTYPE DO NOT " &
                      "HAVE THE SAME LENGTH");

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (1) .. IDENT_INT (1));
               A1A : SARR1 := (A'RANGE => 1);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1A'.  COMPONENT A1A(1) IS " &
                       INTEGER'IMAGE(A1A(IDENT_INT(1))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1A'" );
     END;

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (1) .. IDENT_INT (1));
               A1B : CONSTANT SARR1 := (A'RANGE => 0);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A1B'.  COMPONENT A1B(1) IS " &
                       INTEGER'IMAGE(A1B(IDENT_INT(1))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A1B'");
     END;

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (2) .. IDENT_INT (4));
               A1C : CONSTANT SARR1 := (A'RANGE => 0);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A1C'.  COMPONENT A1C(2) IS " &
                       INTEGER'IMAGE(A1C(IDENT_INT(2))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION" &
                       "OF CONSTANT 'A1C'");
     END;

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (6) .. IDENT_INT (8));
               A1D : SARR1 := (A'RANGE => 0);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1D'.  COMPONENT A1D(7) IS " &
                       INTEGER'IMAGE(A1D(IDENT_INT(7))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1D'");
     END;

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (2) .. IDENT_INT (1));
               A1E : SARR1 := (A'RANGE => 0);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1E'.  COMPONENT A1E(2) IS " &
                       INTEGER'IMAGE(A1E(IDENT_INT(2))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1E'");
     END;

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (2) .. IDENT_INT (1));
               A1F : CONSTANT SARR1 := (A'RANGE => 0);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A1F'.  COMPONENT A1F(2) IS " &
                       INTEGER'IMAGE(A1F(IDENT_INT(2))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A1F'");
     END;

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (1) .. IDENT_INT (1));
               A1G : ARR1 (IDENT_INT (1) .. IDENT_INT (2)) :=
                     (A'RANGE => 0);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1G'.  COMPONENT A1G(1) IS " &
                       INTEGER'IMAGE(A1G(IDENT_INT(1))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A1G'");
     END;

     BEGIN
          DECLARE
               A   : ARR1 (IDENT_INT (1) .. IDENT_INT (3));
               A1H : CONSTANT ARR1 (IDENT_INT (1) .. IDENT_INT (2)) :=
                     (A'RANGE => 0);
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A1H'.  COMPONENT A1H(2) IS " &
                       INTEGER'IMAGE(A1H(IDENT_INT(2))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A1H'");
     END;

     BEGIN
          DECLARE
               A   : ARR2 (IDENT_INT (0) .. IDENT_INT (0),
                           IDENT_INT (1) .. IDENT_INT (2));
               A2A : CONSTANT SARR2 := (A'RANGE => (A'RANGE (2) => 0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A2A'.  COMPONENT A2A(0,1) IS " &
                       INTEGER'IMAGE(A2A(IDENT_INT(0),IDENT_INT(1))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A2A'");
     END;

     BEGIN
          DECLARE
               A   : ARR2 (IDENT_INT (0) .. IDENT_INT (0),
                           IDENT_INT (1) .. IDENT_INT (2));
               A2B : SARR2 := (A'RANGE => (A'RANGE (2) => 0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A2B'.  COMPONENT A2B(0,1) IS " &
                       INTEGER'IMAGE(A2B(IDENT_INT(0),IDENT_INT(1))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A2B'");
     END;

     BEGIN
          DECLARE
               A   : ARR2 (IDENT_INT (2) .. IDENT_INT (1),
                           IDENT_INT (0) .. IDENT_INT (0));
               A2C : CONSTANT SARR2 := (A'RANGE => (A'RANGE (2) => 0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION" &
                       "OF CONSTANT 'A2C'.  COMPONENT A2C(2,0) IS " &
                       INTEGER'IMAGE(A2C(IDENT_INT(2),IDENT_INT(0))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A2C'");
     END;

     BEGIN
          DECLARE
               A   : ARR2 (IDENT_INT (2) .. IDENT_INT (1),
                           IDENT_INT (0) .. IDENT_INT (0));
               A2D : SARR2 := (A'RANGE => (A'RANGE (2) => 0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A2D'.  COMPONENT A2D(2,0) IS " &
                       INTEGER'IMAGE(A2D(IDENT_INT(2),IDENT_INT(0))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A2D'");
     END;

     BEGIN
          DECLARE
               A   : ARR2 (IDENT_INT (1) .. IDENT_INT (2),
                           IDENT_INT (0) .. IDENT_INT (1));
               A2E : CONSTANT ARR2 (IDENT_INT (1) .. IDENT_INT (2),
                                    IDENT_INT (0) .. IDENT_INT (0)) :=
                                    (A'RANGE => (A'RANGE (2) => 0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A2E'.  COMPONENT A2E(2,0) IS " &
                       INTEGER'IMAGE(A2E(IDENT_INT(2),IDENT_INT(0))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF CONSTANT 'A2E'");
     END;

     BEGIN
          DECLARE
               A   : ARR2 (IDENT_INT (0) .. IDENT_INT (2),
                           IDENT_INT (0) .. IDENT_INT (0));
               A2F : ARR2 (IDENT_INT (1) .. IDENT_INT (2),
                           IDENT_INT (0) .. IDENT_INT (0)) :=
                           (A'RANGE => (A'RANGE (2) => 0));
          BEGIN
               FAILED ("NO EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A2F'.  COMPONENT A2F(1,0) IS " &
                       INTEGER'IMAGE(A2F(IDENT_INT(1),IDENT_INT(0))));
          END;
     EXCEPTION
          WHEN CONSTRAINT_ERROR =>
               NULL;
          WHEN OTHERS =>
               FAILED ("WRONG EXCEPTION RAISED FOR INITIALIZATION " &
                       "OF VARIABLE 'A2F'");
     END;

     RESULT;
END C32112A;
