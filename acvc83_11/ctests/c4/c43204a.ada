-- C43204A.ADA

-- OBJECTIVE:
--     CHECK THAT AN ARRAY AGGREGATE WITH AN OTHERS CHOICE CAN APPEAR
--     (AND BOUNDS ARE DETERMINED CORRECTLY) AS AN ACTUAL PARAMETER OF
--     A SUBPROGRAM CALL WHEN THE FORMAL PARAMETER IS CONSTRAINED.

-- HISTORY:
--     JET 08/04/88  CREATED ORIGINAL TEST.

WITH REPORT; USE REPORT;
PROCEDURE C43204A IS

     TYPE ARR10 IS ARRAY(IDENT_INT(1)..IDENT_INT(0)) OF INTEGER;
     TYPE ARR11 IS ARRAY(INTEGER RANGE -3..3) OF INTEGER;
     TYPE ARR12 IS ARRAY(IDENT_INT(-3)..IDENT_INT(3)) OF INTEGER;

     TYPE ARR20 IS ARRAY(IDENT_INT(1)..IDENT_INT(0),
                         IDENT_INT(0)..IDENT_INT(-1)) OF INTEGER;
     TYPE ARR21 IS ARRAY(INTEGER RANGE -1..1,
                         INTEGER RANGE -1..1) OF INTEGER;
     TYPE ARR22 IS ARRAY(IDENT_INT(-1)..IDENT_INT(1),
                         IDENT_INT(-1)..IDENT_INT(1)) OF INTEGER;
     TYPE ARR23 IS ARRAY(INTEGER'(-1)..1,
                         IDENT_INT(-1)..IDENT_INT(1)) OF INTEGER;

     PROCEDURE PROC10 (A : ARR10) IS
     BEGIN
          IF A'LENGTH /= IDENT_INT(0) THEN
               FAILED ("PROC10 ARRAY IS NOT NULL");
          END IF;
     END PROC10;

     PROCEDURE PROC11 (A : ARR11; C : INTEGER) IS
     BEGIN
          IF A'LENGTH /= IDENT_INT(7) OR
             A'FIRST /= IDENT_INT(-3) OR
             A'LAST /= IDENT_INT(3)   THEN
               FAILED ("INCORRECT LENGTH IN PROC11 CALL NUMBER" &
                       INTEGER'IMAGE(C));
          END IF;

          FOR I IN IDENT_INT(-3)..IDENT_INT(3) LOOP
               IF IDENT_INT(A(I)) /= C THEN
                    FAILED ("INCORRECT VALUE OF COMPONENT " &
                            INTEGER'IMAGE(I) & ", PROC11 CALL NUMBER" &
                            INTEGER'IMAGE(C));
               END IF;
          END LOOP;
     END PROC11;

     PROCEDURE PROC12 (A : ARR12) IS
     BEGIN
          IF A'LENGTH /= IDENT_INT(7) THEN
               FAILED ("INCORRECT LENGTH IN PROC12");
          END IF;

          FOR I IN IDENT_INT(-3)..IDENT_INT(3) LOOP
               IF IDENT_INT(A(I)) /= 3 THEN
                    FAILED ("INCORRECT VALUE OF COMPONENT " &
                            INTEGER'IMAGE(I) & ", PROC12");
               END IF;
          END LOOP;
     END PROC12;

     PROCEDURE PROC20 (A : ARR20) IS
     BEGIN
          IF A'LENGTH(1) /= IDENT_INT(0) OR
             A'LENGTH(2) /= IDENT_INT(0) THEN
               FAILED ("PROC20 ARRAY IS NOT NULL");
          END IF;
     END PROC20;

     PROCEDURE PROC21 (A : ARR21; C : INTEGER) IS
     BEGIN
          FOR I IN INTEGER'(-1)..1 LOOP
               FOR J IN INTEGER'(-1)..1 LOOP
                    IF IDENT_INT(A(I,J)) /= C THEN
                         FAILED ("INCORRECT VALUE OF COMPONENT (" &
                                 INTEGER'IMAGE(I) & "," &
                                 INTEGER'IMAGE(J) & "), PROC21 CALL " &
                                 "NUMBER" & INTEGER'IMAGE(C));
                    END IF;
               END LOOP;
          END LOOP;
     END PROC21;

     PROCEDURE PROC22 (A : ARR22) IS
     BEGIN
          FOR I IN INTEGER'(-1)..1 LOOP
               FOR J IN INTEGER'(-1)..1 LOOP
                    IF IDENT_INT(A(I,J)) /= 5 THEN
                         FAILED ("INCORRECT VALUE OF COMPONENT (" &
                                 INTEGER'IMAGE(I) & "," &
                                 INTEGER'IMAGE(J) & "), PROC22");
                    END IF;
               END LOOP;
          END LOOP;
     END PROC22;

     PROCEDURE PROC23 (A : ARR23) IS
     BEGIN
          FOR I IN INTEGER'(-1)..1 LOOP
               FOR J IN INTEGER'(-1)..1 LOOP
                    IF IDENT_INT(A(I,J)) /= 7 THEN
                         FAILED ("INCORRECT VALUE OF COMPONENT (" &
                                 INTEGER'IMAGE(I) & "," &
                                 INTEGER'IMAGE(J) & "), PROC23");
                    END IF;
               END LOOP;
          END LOOP;
     END PROC23;

BEGIN
     TEST ("C43204A", "CHECK THAT AN ARRAY AGGREGATE WITH AN OTHERS " &
                      "CHOICE CAN APPEAR (AND BOUNDS ARE DETERMINED " &
                      "CORRECTLY) AS AN ACTUAL PARAMETER OF A " &
                      "SUBPROGRAM CALL WHEN THE FORMAL PARAMETER IS " &
                      "CONSTRAINED");

     PROC11 ((1,1,1, OTHERS => 1), 1);
     PROC11 ((2 => 2, 3 => 2, OTHERS => 2), 2);
     PROC12 ((OTHERS => 3));
     PROC10 ((OTHERS => 4));

     PROC21 (((1,1,1), OTHERS => (1,1,1)), 1);
     PROC21 ((1 => (2,2,2), OTHERS => (2,2,2)), 2);
     PROC21 (((3,OTHERS => 3), (3,OTHERS => 3), (3,3,OTHERS => 3)), 3);
     PROC21 (((-1 => 4, OTHERS => 4), (0 => 4, OTHERS => 4),
              (1 => 4, OTHERS => 4)), 4);
     PROC22 ((OTHERS => (OTHERS => 5)));
     PROC20 ((OTHERS => (OTHERS => 6)));
     PROC23 ((OTHERS => (7,7,7)));

     RESULT;
END C43204A;
