-- C35502J.ADA

-- OBJECTIVE:
--     CHECK THAT 'PRED' AND 'SUCC' YIELD THE CORRECT RESULTS WHEN
--     THE PREFIX IS A FORMAL DISCRETE TYPE WHOSE ACTUAL ARGUMENT IS
--     AN ENUMERATION TYPE, OTHER THAN A BOOLEAN OR A CHARACTER TYPE,
--     WITH AN ENUMERATION REPRESENTATION CLAUSE.

-- HISTORY:
--     RJW 05/27/86  CREATED ORIGINAL TEST.
--     BCB 01/04/88  MODIFIED HEADER.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

WITH REPORT; USE REPORT;

PROCEDURE C35502J IS
          TYPE ENUM IS (A, BC, ABC, A_B_C, ABCD);
          FOR ENUM USE (A => 2, BC => 4, ABC => 6,
                        A_B_C => 8, ABCD => 10);

          TYPE NEWENUM IS NEW ENUM;

BEGIN
     TEST ("C35502J", "CHECK THAT 'PRED' AND 'SUCC' YIELD THE " &
                      "CORRECT RESULTS WHEN THE PREFIX IS " &
                      "A FORMAL DISCRETE TYPE WHOSE ACTUAL " &
                      "ARGUMENT IS AN ENUMERATION TYPE, OTHER THAN " &
                      "A CHARACTER OR A BOOLEAN TYPE, WITH AN " &
                      "ENUMERATION REPRESENTATION CLAUSE" );

     DECLARE
          GENERIC
               TYPE E IS (<>);
               STR : STRING;
          PROCEDURE P;

          PROCEDURE P IS
               SUBTYPE SE IS E RANGE E'VAL(0) .. E'VAL(1);

          BEGIN
               FOR I IN E'VAL (1) .. E'VAL (4)
                    LOOP
                         IF SE'PRED (I) /=
                            E'VAL (E'POS (I) - 1) THEN
                              FAILED ("INCORRECT " & STR & "'PRED(" &
                                       E'IMAGE (I) & ")" );
                         END IF;
                    END LOOP;

               FOR I IN E'VAL (0) .. E'VAL (3)
                    LOOP
                         IF SE'SUCC (I) /=
                            E'VAL (E'POS (I) + 1) THEN
                              FAILED ("INCORRECT " & STR & "'SUCC(" &
                                       E'IMAGE (I) & ")" );
                         END IF;
                    END LOOP;

     END P;

     PROCEDURE PE IS NEW P ( ENUM, "ENUM" );
     PROCEDURE PN IS NEW P ( NEWENUM, "NEWENUM" );

     BEGIN
          PE;
          PN;
     END;

     RESULT;
END C35502J;
