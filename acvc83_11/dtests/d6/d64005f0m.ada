-- D64005F0M.ADA

-- CHECK THAT NESTED SUBPROGRAMS CAN BE CALLED RECURSIVELY AND THAT
-- NON-LOCAL VARIABLES AND FORMAL PARAMETERS ARE PROPERLY ACCESSED FROM
-- WITHIN RECURSIVE INVOCATIONS.  THIS TEST CHECKS THAT EVERY DISPLAY OR
-- STATIC CHAIN LEVEL CAN BE ACCESSED.

-- THIS TEST USES 10 LEVELS OF NESTED RECURSIVE PROCEDURES (SEPARATELY
-- COMPILED AS SUBUNITS).

-- SEPARATE FILES ARE:
--   D64005F0M THE MAIN PROCEDURE.
--   D64005FA  A RECURSIVE PROCEDURE SUBUNIT OF D64005F0M.
--   D64005FB  A RECURSIVE PROCEDURE SUBUNIT OF D64005FA.
--   D64005FC  A RECURSIVE PROCEDURE SUBUNIT OF D64005FB.
--   D64005FD  A RECURSIVE PROCEDURE SUBUNIT OF D64005FC.
--   D64005FE  A RECURSIVE PROCEDURE SUBUNIT OF D64005FD.
--   D64005FF  A RECURSIVE PROCEDURE SUBUNIT OF D64005FE.
--   D64005FG  A RECURSIVE PROCEDURE SUBUNIT OF D64005FF.
--   D64005FH  A RECURSIVE PROCEDURE SUBUNIT OF D64005FG.
--   D64005FI  A RECURSIVE PROCEDURE SUBUNIT OF D64005FH.
--   D64005FJ  A RECURSIVE PROCEDURE SUBUNIT OF D64005FI.

-- JRK 7/30/84
-- CPP 8/2/84

WITH REPORT; USE REPORT;

PROCEDURE D64005F0M IS

     SUBTYPE LEVEL IS CHARACTER RANGE 'A' .. 'J';
     SUBTYPE CALL IS CHARACTER RANGE '1' .. '3';

     MAX_LEV : CONSTANT := LEVEL'POS (LEVEL'LAST) -
                           LEVEL'POS (LEVEL'FIRST) + 1;
     T_LEN : CONSTANT := 2 * (1 + 3 * (MAX_LEV +
                                       MAX_LEV*(MAX_LEV+1)/2*2)) + 1;
     G_LEN : CONSTANT := 2 + 4 * MAX_LEV;

     TYPE TRACE IS
          RECORD
               E : NATURAL := 0;
               S : STRING (1 .. T_LEN);
          END RECORD;

     V : CHARACTER := IDENT_CHAR ('<');
     L : CHARACTER := IDENT_CHAR ('>');
     T : TRACE;
     G : STRING (1 .. G_LEN);

     PROCEDURE D64005FA (L : LEVEL; C : CALL; T : IN OUT TRACE) IS
          SEPARATE;

BEGIN
     TEST ("D64005F", "CHECK THAT NON-LOCAL VARIABLES AND FORMAL " &
                      "PARAMETERS AT ALL LEVELS OF NESTED " &
                      "RECURSIVE PROCEDURES ARE ACCESSIBLE (FOR " &
                      "10 LEVELS OF SEPARATELY COMPILED SUBUNITS)");

     -- APPEND V TO T.
     T.S (T.E+1) := V;
     T.E := T.E + 1;

     BEGIN
          D64005FA (IDENT_CHAR(LEVEL'FIRST), IDENT_CHAR('1'), T);
     EXCEPTION
          WHEN STORAGE_ERROR =>
               NOT_APPLICABLE ("STORAGE_ERROR RAISED");
               COMMENT ("FINAL CALL TRACE LENGTH IS: " &
                        INTEGER'IMAGE(T.E));
               COMMENT ("FINAL CALL TRACE IS: " & T.S(1..T.E));
               RESULT;
               RETURN;
     END;

     -- APPEND L TO T.
     T.S (T.E+1) := L;
     T.E := T.E + 1;

     COMMENT ("FINAL CALL TRACE LENGTH IS: " & INTEGER'IMAGE(T.E));
     COMMENT ("FINAL CALL TRACE IS: " & T.S(1..T.E));
     COMMENT ("GLOBAL SNAPSHOT IS: " & G);

     -- CHECK THAT T AND G ARE CORRECT BY COMPUTING THEM ITERATIVELY.

     DECLARE
          SUBTYPE LC_LEVEL IS CHARACTER RANGE ASCII.LC_A ..
               CHARACTER'VAL (CHARACTER'POS(ASCII.LC_A) + MAX_LEV - 1);

          CT : TRACE;
          CG : STRING (1 .. G_LEN);
     BEGIN
          COMMENT ("CORRECT FINAL CALL TRACE LENGTH IS: " &
                   INTEGER'IMAGE(T_LEN));

          IF T.E /= IDENT_INT (T_LEN) THEN
               FAILED ("WRONG FINAL CALL TRACE LENGTH");

          ELSE CT.S (CT.E+1) := '<';
               CT.E := CT.E + 1;

               FOR I IN LC_LEVEL LOOP
                    CT.S (CT.E+1) := '<';
                    CT.E := CT.E + 1;

                    FOR J IN LC_LEVEL'FIRST .. I LOOP
                         CT.S (CT.E+1) := J;
                         CT.S (CT.E+2) := '1';
                         CT.E := CT.E + 2;
                    END LOOP;
               END LOOP;

               FOR I IN LC_LEVEL LOOP
                    CT.S (CT.E+1) := '<';
                    CT.E := CT.E + 1;

                    FOR J IN LC_LEVEL'FIRST .. LC_LEVEL'PRED(I) LOOP
                         CT.S (CT.E+1) := J;
                         CT.S (CT.E+2) := '3';
                         CT.E := CT.E + 2;
                    END LOOP;

                    CT.S (CT.E+1) := I;
                    CT.S (CT.E+2) := '2';
                    CT.E := CT.E + 2;

                    CT.S (CT.E+1) := '<';
                    CT.E := CT.E + 1;

                    FOR J IN LC_LEVEL'FIRST .. I LOOP
                         CT.S (CT.E+1) := J;
                         CT.S (CT.E+2) := '3';
                         CT.E := CT.E + 2;
                    END LOOP;
               END LOOP;

               CT.S (CT.E+1) := '=';
               CT.E := CT.E + 1;

               FOR I IN REVERSE LEVEL LOOP
                    FOR J IN REVERSE LEVEL'FIRST .. I LOOP
                         CT.S (CT.E+1) := J;
                         CT.S (CT.E+2) := '3';
                         CT.E := CT.E + 2;
                    END LOOP;

                    CT.S (CT.E+1) := '>';
                    CT.E := CT.E + 1;

                    CT.S (CT.E+1) := I;
                    CT.S (CT.E+2) := '2';
                    CT.E := CT.E + 2;

                    FOR J IN REVERSE LEVEL'FIRST .. LEVEL'PRED(I) LOOP
                         CT.S (CT.E+1) := J;
                         CT.S (CT.E+2) := '3';
                         CT.E := CT.E + 2;
                    END LOOP;

                    CT.S (CT.E+1) := '>';
                    CT.E := CT.E + 1;
               END LOOP;

               FOR I IN REVERSE LEVEL LOOP
                    FOR J IN REVERSE LEVEL'FIRST .. I LOOP
                         CT.S (CT.E+1) := J;
                         CT.S (CT.E+2) := '1';
                         CT.E := CT.E + 2;
                    END LOOP;

                    CT.S (CT.E+1) := '>';
                    CT.E := CT.E + 1;
               END LOOP;

               CT.S (CT.E+1) := '>';
               CT.E := CT.E + 1;

               IF CT.E /= IDENT_INT (T_LEN) THEN
                    FAILED ("WRONG ITERATIVE TRACE LENGTH");

               ELSE COMMENT ("CORRECT FINAL CALL TRACE IS: " & CT.S);

                    IF T.S /= CT.S THEN
                         FAILED ("WRONG FINAL CALL TRACE");
                    END IF;
               END IF;
          END IF;

          DECLARE
               E : NATURAL := 0;
          BEGIN
               CG (1..2) := "<>";
               E := E + 2;

               FOR I IN LEVEL LOOP
                    CG (E+1) := LC_LEVEL'VAL (LEVEL'POS(I) -
                                              LEVEL'POS(LEVEL'FIRST) +
                                              LC_LEVEL'POS
                                                      (LC_LEVEL'FIRST));
                    CG (E+2) := '3';
                    CG (E+3) := I;
                    CG (E+4) := '3';
                    E := E + 4;
               END LOOP;

               COMMENT ("CORRECT GLOBAL SNAPSHOT IS: " & CG);

               IF G /= CG THEN
                    FAILED ("WRONG GLOBAL SNAPSHOT");
               END IF;
          END;
     END;

     RESULT;
END D64005F0M;
