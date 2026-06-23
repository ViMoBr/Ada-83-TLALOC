-- CC1004A.ADA

-- OBJECTIVE:
--     CHECK THAT THE ELABORATION OF A GENERIC DECLARATION
--     DOES NOT ELABORATE THE SUBPROGRAM OR PACKAGE SPECIFICATION.

-- HISTORY:
--     DAT 07/31/81  CREATED ORIGINAL TEST.
--     SPS 10/18/82
--     SPS 02/09/83
--     JET 01/07/88  UPDATED HEADER FORMAT AND ADDED CODE TO
--                   PREVENT OPTIMIZATION.

WITH REPORT; USE REPORT;

PROCEDURE CC1004A IS
BEGIN
     TEST ("CC1004A", "THE SPECIFICATION PART OF A GENERIC " &
                      "SUBPROGRAM IS NOT ELABORATED AT THE " &
                      "ELABORATION OF THE DECLARATION");

     BEGIN
          DECLARE
               SUBTYPE I1 IS INTEGER RANGE 1 .. 1;

               GENERIC
               PROCEDURE PROC (P1: I1 := IDENT_INT(2));

               PROCEDURE PROC (P1: I1 := IDENT_INT(2)) IS
               BEGIN
                    IF NOT EQUAL (P1,P1) THEN
                         COMMENT ("DON'T OPTIMIZE THIS");
                    END IF;
               END PROC;
          BEGIN
               BEGIN
                    DECLARE
                         PROCEDURE P IS NEW PROC;
                    BEGIN
                         IF NOT EQUAL(3,3) THEN
                              P(1);
                         END IF;
                    END;
               EXCEPTION
                    WHEN OTHERS =>
                         FAILED ("INSTANTIATION ELABORATES SPEC");
               END;

          END;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("DECL ELABORATED SPEC PART - 1");
     END;

     BEGIN
          DECLARE
               SUBTYPE I1 IS INTEGER RANGE 1 .. 1;

               GENERIC
               PACKAGE PKG IS
                    X : INTEGER := I1(IDENT_INT(2));
               END PKG;
          BEGIN
               BEGIN
                    DECLARE
                         PACKAGE P IS NEW PKG;
                    BEGIN
                         FAILED ("PACKAGE INSTANTIATION FAILED");
                         IF NOT EQUAL(P.X,P.X) THEN
                              COMMENT("DON'T OPTIMIZE THIS");
                         END IF;
                    END;
               EXCEPTION
                    WHEN CONSTRAINT_ERROR => NULL;
                    WHEN OTHERS => FAILED ("WRONG EXCEPTION - 2");
               END;

          END;
     EXCEPTION
          WHEN OTHERS =>
               FAILED ("DECL ELABORATED SPEC PART - 2");
     END;

     RESULT;

END CC1004A;
